const jwt = require('jsonwebtoken');
const User = require('../models/User');
const config = require('../config/env');

const getExpiry = (envVal, fallback) => {
  if (!envVal) return fallback;
  const cleaned = String(envVal).trim().replace(/^["']|["']$/g, '');
  try {
    jwt.sign({ test: 1 }, 'test-secret', { expiresIn: cleaned });
    return cleaned;
  } catch (err) {
    console.warn(`[Auth] Invalid expiresIn value "${envVal}" in env, falling back to "${fallback}"`);
    return fallback;
  }
};

const generateTokens = (userId) => {
  const secret = config.jwt.secret;
  const accessExpiry = getExpiry(config.jwt.expiresIn, '7d');
  const refreshExpiry = getExpiry(config.jwt.refreshExpiresIn, '30d');

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

exports.register = async (req, res) => {
  try {
    const { name, phone, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Name, email, and password are required' });
    }

    const existing = await User.findOne({ email: email.toLowerCase() });
    if (existing) {
      return res.status(409).json({ error: 'Email already registered' });
    }

    const user = new User({
      name,
      phone: phone || '',
      email: email.toLowerCase(),
      passwordHash: password,
    });

    await user.save();

    const { token, refreshToken } = generateTokens(user._id);

    await User.findByIdAndUpdate(user._id, { refreshToken });

    console.log(`[Auth] User registered successfully: ${user.email}`);

    res.status(201).json({
      token,
      refreshToken,
      user: user.toSafeJSON(),
    });
  } catch (err) {
    console.error('[Auth] Register error:', err.message, err.stack);

    if (err.code === 11000) {
      return res.status(409).json({ error: 'Email already registered' });
    }

    if (err.name === 'ValidationError') {
      const messages = Object.values(err.errors).map(e => e.message);
      return res.status(400).json({ error: messages.join(', ') });
    }

    res.status(500).json({ error: 'Registration failed. Please try again.' });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

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

    const { token, refreshToken } = generateTokens(user._id);

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

exports.refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ error: 'Refresh token required' });
    }

    const decoded = jwt.verify(refreshToken, config.jwt.secret);
    const user = await User.findById(decoded.userId);

    if (!user || user.refreshToken !== refreshToken) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }

    const tokens = generateTokens(user._id);

    await User.findByIdAndUpdate(user._id, { refreshToken: tokens.refreshToken });

    res.json(tokens);
  } catch (err) {
    console.error('[Auth] Refresh token error:', err.message);
    res.status(401).json({ error: 'Invalid refresh token' });
  }
};
