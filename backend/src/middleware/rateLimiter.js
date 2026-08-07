const rateLimit = require('express-rate-limit');

/**
 * Rate limiters for SafeHer-AI API endpoints.
 *
 * Different tiers for different sensitivity levels:
 * - Auth: moderate (prevents brute-force but allows reasonable usage)
 * - SOS: permissive (allows rapid retries for emergencies)
 * - General: permissive
 */

// ─── Auth Rate Limiter ────────────────────────────────────────
// 30 attempts per 15 minutes per IP (allows for retries during cold starts)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 30,
  message: {
    error: 'Too many authentication attempts. Please try again in 15 minutes.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// ─── SOS Rate Limiter ─────────────────────────────────────────
// 10 per minute per IP (allows rapid retries but prevents abuse)
const sosLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 10,
  message: {
    error: 'Too many SOS requests. Please wait before retrying.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// ─── General API Rate Limiter ─────────────────────────────────
// 200 per 15 minutes per IP
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: {
    error: 'Too many requests. Please slow down.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

module.exports = {
  authLimiter,
  sosLimiter,
  generalLimiter,
};
