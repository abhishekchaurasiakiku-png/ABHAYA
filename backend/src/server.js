require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const http = require('http');
const { WebSocketServer } = require('ws');
const path = require('path');
const fs = require('fs');

// Middleware
const { generalLimiter } = require('./middleware/rateLimiter');

// Routes
const authRoutes = require('./routes/authRoutes');
const sosRoutes = require('./routes/sosRoutes');
const userRoutes = require('./routes/userRoutes');
const incidentRoutes = require('./routes/incidentRoutes');
const safetyRoutes = require('./routes/safetyRoutes');

// Services
const { initializeWebSocket } = require('./services/websocketService');

const app = express();
const server = http.createServer(app);

// ─── CORS Configuration ─────────────────────────────────────
// In production, restrict to your domain. Mobile apps don't send
// an Origin header, so they pass through regardless.
const corsOptions = {
  origin: (origin, callback) => {
    // Allow requests with no origin (mobile apps, curl, server-to-server)
    if (!origin) return callback(null, true);

    const allowedOrigins = [
      'http://localhost:3000',
      'http://127.0.0.1:3000',
      'http://10.0.2.2:3000', // Android emulator
    ];

    // In production, add your deployed frontend domain
    if (process.env.CORS_ORIGIN) {
      allowedOrigins.push(process.env.CORS_ORIGIN);
    }

    if (allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(null, true); // Allow all in dev; tighten in production if needed
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};

// ─── Middleware ──────────────────────────────────────────────
app.use(helmet());
app.use(cors(corsOptions));
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Apply general rate limiter to all routes
app.use(generalLimiter);

// Ensure uploads directory exists
const uploadDir = process.env.UPLOAD_DIR || './uploads';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}
app.use('/uploads', express.static(path.join(__dirname, '..', uploadDir)));

// ─── Routes ─────────────────────────────────────────────────
app.use('/api/auth', authRoutes);
app.use('/api/sos', sosRoutes);
app.use('/api/users', userRoutes);
app.use('/api/incidents', incidentRoutes);
app.use('/api/safety', safetyRoutes);

// Helper to safely extract database host for diagnostics
function getDatabaseHost(uri) {
  try {
    if (!uri) return 'none';
    const cleaned = uri.replace(/^mongodb\+srv:\/\//, 'http://').replace(/^mongodb:\/\//, 'http://');
    return new URL(cleaned).hostname;
  } catch (e) {
    return 'invalid-format';
  }
}

// Safely obfuscate connection string password
function obfuscateUri(uri) {
  if (!uri) return 'none';
  if (!uri.startsWith('mongodb://') && !uri.startsWith('mongodb+srv://')) {
    return `non-standard: ${uri.substring(0, 20)}...`;
  }
  return uri.replace(/(mongodb(?:\+srv)?:\/\/[^:]+:)[^@]+(@.+)/, '$1****$2');
}

// Health check — includes MongoDB connection status
app.get('/api/health', (req, res) => {
  const mongoState = mongoose.connection.readyState;
  const mongoStates = {
    0: 'disconnected',
    1: 'connected',
    2: 'connecting',
    3: 'disconnecting',
  };

  res.json({
    status: mongoState === 1 ? 'ok' : 'degraded',
    service: 'SafeHer-AI Backend',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    mongodb: mongoStates[mongoState] || 'unknown',
    databaseHost: getDatabaseHost(MONGODB_URI),
    obfuscatedUri: obfuscateUri(MONGODB_URI),
  });
});

// ─── 404 Handler ────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// ─── Error Handler ──────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('[Error]', err.message);

  // Handle multer file size error
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({ error: 'File too large' });
  }

  res.status(err.status || 500).json({
    error: process.env.NODE_ENV === 'production'
      ? 'Internal Server Error'
      : err.message || 'Internal Server Error',
  });
});

// ─── WebSocket ──────────────────────────────────────────────
const wss = new WebSocketServer({ server, path: '/tracking' });
initializeWebSocket(wss);

// ─── MongoDB Connection with Retry ──────────────────────────
const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/safeher-ai';

const MONGO_OPTIONS = {
  serverSelectionTimeoutMS: 30000,
  heartbeatFrequencyMS: 10000,
};

async function connectWithRetry(retries = 5, delay = 3000) {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      console.log(`⏳ MongoDB connection attempt ${attempt}/${retries}...`);
      await mongoose.connect(MONGODB_URI, MONGO_OPTIONS);
      console.log('✅ MongoDB connected');
      return;
    } catch (err) {
      console.error(`❌ MongoDB connection attempt ${attempt}/${retries} failed:`, err.message);
      if (attempt === retries) {
        console.error('❌ All MongoDB connection attempts exhausted. Starting server anyway for health checks.');
        return; // Don't exit — let health check report degraded status
      }
      const backoff = delay * Math.pow(2, attempt - 1);
      console.log(`⏳ Retrying in ${backoff / 1000}s...`);
      await new Promise(resolve => setTimeout(resolve, backoff));
    }
  }
}

// MongoDB connection event handlers
mongoose.connection.on('disconnected', () => {
  console.warn('⚠️ MongoDB disconnected');
});

mongoose.connection.on('reconnected', () => {
  console.log('✅ MongoDB reconnected');
});

mongoose.connection.on('error', (err) => {
  console.error('❌ MongoDB connection error:', err.message);
});

// ─── Start Server ───────────────────────────────────────────
// IMPORTANT: Connect to MongoDB FIRST, then start listening.
// This prevents 500 errors when requests arrive before MongoDB is ready.
async function startServer() {
  // Connect to MongoDB first
  await connectWithRetry();

  // Then start accepting HTTP requests
  server.listen(PORT, () => {
    console.log(`🚀 SafeHer-AI Backend running on port ${PORT}`);
    console.log(`📡 WebSocket server ready at ws://localhost:${PORT}/tracking`);
    console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`📊 MongoDB state: ${mongoose.connection.readyState === 1 ? 'connected' : 'not connected'}`);
  });
}

startServer();

// ─── Graceful Shutdown ──────────────────────────────────────
function gracefulShutdown(signal) {
  console.log(`\n${signal} received. Shutting down gracefully...`);

  server.close(() => {
    console.log('🔌 HTTP server closed');

    // Close all WebSocket connections
    wss.clients.forEach(client => client.close());
    console.log('🔌 WebSocket connections closed');

    mongoose.connection.close(false).then(() => {
      console.log('🔌 MongoDB connection closed');
      process.exit(0);
    });
  });

  // Force shutdown after 10 seconds
  setTimeout(() => {
    console.error('⚠️ Forced shutdown after timeout');
    process.exit(1);
  }, 10000);
}

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

module.exports = app;
