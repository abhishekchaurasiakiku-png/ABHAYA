require('dotenv').config();

const requiredInProd = ['JWT_SECRET', 'MONGODB_URI'];

if (process.env.NODE_ENV === 'production') {
  for (const key of requiredInProd) {
    if (!process.env[key]) {
      console.error(`❌ FATAL ERROR: Missing required environment variable: ${key}`);
      process.exit(1);
    }
  }
}

const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT, 10) || 3000,
  mongodbUri: process.env.MONGODB_URI || 'mongodb://localhost:27017/ABHAYA',
  jwt: {
    secret: process.env.JWT_SECRET || 'default-secret-key-change-in-prod',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
  },
  corsOrigin: process.env.CORS_ORIGIN || null,
  uploadDir: process.env.UPLOAD_DIR || './uploads',
  smtp: {
    user: process.env.SMTP_USER || null,
    pass: process.env.SMTP_PASS || null,
  },
  twilio: {
    sid: process.env.TWILIO_SID || null,
    authToken: process.env.TWILIO_AUTH_TOKEN || null,
    fromNumber: process.env.TWILIO_FROM_NUMBER || null,
  },
};

module.exports = config;
