const jwt = require('jsonwebtoken');
const User = require('../models/User');

/**
 * Helper to safely sanitize and validate timespan strings from environment variables
 * (strips extraneous quotes/whitespace, defaults if invalid).
 */
const getExpiry = (envVal, fallback) => {
  if (!envVal) return fallback;
  const cleaned = String(envVal).trim().replace(/^["']|["']$/g, '');
  try {
    // Test if jsonwebtoken accepts this timespan format without throwing
    jwt.sign({ test: 1 }, 'test-secret', { expiresIn: cleaned });
    return cleaned;
  } catch (err) {
    console.warn(`[Auth] Invalid expiresIn value "${envVal}" in env, falling back to "${fallback}"`);
    return fallback;
  }
};

/**
 * Generate JWT access and refresh tokens.
 */
const generateTokens = (userId) => {
  const secret = process.env.JWT_SECRET || 'default-secret-key-change-in-prod';
  const accessExpiry = getExpiry(process.env.JWT_EXPIRES_IN, '7d');
  const refreshExpiry = getExpiry(process.env.JWT_REFRESH_EXPIRES_IN, '30d');

  const token = jwt.sign(
    { userId },
    secret,
    { expiresIn: accessExpiry }
  );

  const refreshToken = jwt.sign(
    { userId, type: 'refresh' },
    secret,
    { expiresIn: refreshExpiry }
  );

  return { token, refreshToken };
};

/**
 * POST /api/auth/register
 */
exports.register = async (req, res) => {
  try {
    const { name, phone, email, password } = req.body;

    // Validate required fields
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Name, email, and password are required' });
    }

    // Check if email already exists
    const existing = await User.findOne({ email: email.toLowerCase() });
    if (existing) {
      return res.status(409).json({ error: 'Email already registered' });
    }

    // Create user — passwordHash will be hashed by pre-save hook
    const user = new User({
      name,
      phone: phone || '',
      email: email.toLowerCase(),
      passwordHash: password,
    });

    // Save user (first save: hashes password and creates user in DB)
    await user.save();

    // Generate tokens using the saved user's _id
    const { token, refreshToken } = generateTokens(user._id);

    // Update only the refreshToken field using findByIdAndUpdate
    // to avoid triggering the pre-save hook again (prevents any
    // chance of double-hashing the password)
    await User.findByIdAndUpdate(user._id, { refreshToken });

    console.log(`[Auth] User registered successfully: ${user.email}`);

    res.status(201).json({
      token,
      refreshToken,
      user: user.toSafeJSON(),
    });
  } catch (err) {
    console.error('[Auth] Register error:', err.message, err.stack);

    // Handle MongoDB duplicate key error
    if (err.code === 11000) {
      return res.status(409).json({ error: 'Email already registered' });
    }

    // Handle validation errors
    if (err.name === 'ValidationError') {
      const messages = Object.values(err.errors).map(e => e.message);
      return res.status(400).json({ error: messages.join(', ') });
    }

    res.status(500).json({ error: 'Registration failed. Please try again.' });
  }
};

/**
 * POST /api/auth/login
 */
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      console.log(`[Auth] Login failed — email not found: ${email}`);
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      console.log(`[Auth] Login failed — wrong password for: ${email}`);
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Generate tokens
    const { token, refreshToken } = generateTokens(user._id);

    // Update refreshToken without triggering pre-save hook
    await User.findByIdAndUpdate(user._id, { refreshToken });

    console.log(`[Auth] User logged in: ${user.email}`);

    res.json({
      token,
      refreshToken,
      user: user.toSafeJSON(),
    });
  } catch (err) {
    console.error('[Auth] Login error:', err.message, err.stack);
    res.status(500).json({ error: 'Login failed. Please try again.' });
  }
};

/**
 * POST /api/auth/refresh
 */
exports.refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ error: 'Refresh token required' });
    }

    const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId);

    if (!user || user.refreshToken !== refreshToken) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }

    const tokens = generateTokens(user._id);

    // Update refreshToken without triggering pre-save hook
    await User.findByIdAndUpdate(user._id, { refreshToken: tokens.refreshToken });

    res.json(tokens);
  } catch (err) {
    console.error('[Auth] Refresh token error:', err.message);
    res.status(401).json({ error: 'Invalid refresh token' });
  }
};
