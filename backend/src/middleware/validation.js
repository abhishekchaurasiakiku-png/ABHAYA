const { body, query, param, validationResult } = require('express-validator');

/**
 * Middleware that checks for validation errors and returns 400 if any exist.
 */
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array().map(e => ({
        field: e.path,
        message: e.msg,
      })),
    });
  }
  next();
};

// ─── Auth Validators ──────────────────────────────────────────

const validateRegister = [
  body('name')
    .trim()
    .notEmpty().withMessage('Name is required')
    .isLength({ min: 2, max: 100 }).withMessage('Name must be 2-100 characters'),
  body('phone')
    .trim()
    .notEmpty().withMessage('Phone number is required')
    .matches(/^\+?[\d\s\-()]{7,20}$/).withMessage('Invalid phone number format'),
  body('email')
    .trim()
    .isEmail().withMessage('Valid email is required')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
    .isLength({ max: 128 }).withMessage('Password must be at most 128 characters'),
  handleValidationErrors,
];

const validateLogin = [
  body('email')
    .trim()
    .isEmail().withMessage('Valid email is required')
    .normalizeEmail(),
  body('password')
    .notEmpty().withMessage('Password is required'),
  handleValidationErrors,
];

const validateRefreshToken = [
  body('refreshToken')
    .notEmpty().withMessage('Refresh token is required'),
  handleValidationErrors,
];

// ─── SOS Validators ───────────────────────────────────────────

const validateSosTrigger = [
  body('triggerType')
    .notEmpty().withMessage('Trigger type is required')
    .isIn(['Voice', 'Motion', 'Manual', 'Multi-Modal']).withMessage('Invalid trigger type'),
  body('location.type')
    .optional()
    .equals('Point').withMessage('Location type must be Point'),
  body('location.coordinates')
    .optional()
    .isArray({ min: 2, max: 2 }).withMessage('Coordinates must be [longitude, latitude]'),
  body('location.coordinates.*')
    .optional()
    .isFloat().withMessage('Coordinates must be numbers'),
  handleValidationErrors,
];

const validateSosResolve = [
  param('id')
    .isMongoId().withMessage('Invalid incident ID'),
  body('status')
    .optional()
    .isIn(['Resolved', 'False Alarm']).withMessage('Status must be Resolved or False Alarm'),
  body('notes')
    .optional()
    .isLength({ max: 1000 }).withMessage('Notes must be under 1000 characters'),
  handleValidationErrors,
];

// ─── User Validators ──────────────────────────────────────────

const validateUpdateProfile = [
  body('name')
    .optional()
    .trim()
    .isLength({ min: 2, max: 100 }).withMessage('Name must be 2-100 characters'),
  body('phone')
    .optional()
    .trim()
    .matches(/^\+?[\d\s\-()]{7,20}$/).withMessage('Invalid phone number format'),
  body('profileImage')
    .optional()
    .isString().withMessage('Profile image must be a string'),
  handleValidationErrors,
];

const validateUpdateContacts = [
  body('emergencyContacts')
    .isArray().withMessage('Emergency contacts must be an array'),
  body('emergencyContacts.*.name')
    .trim()
    .notEmpty().withMessage('Contact name is required'),
  body('emergencyContacts.*.phone')
    .trim()
    .notEmpty().withMessage('Contact phone is required'),
  handleValidationErrors,
];

const validateUpdateAiSettings = [
  body('voiceSensitivity')
    .optional()
    .isFloat({ min: 0, max: 1 }).withMessage('Voice sensitivity must be 0-1'),
  body('motionSensitivity')
    .optional()
    .isFloat({ min: 0, max: 1 }).withMessage('Motion sensitivity must be 0-1'),
  body('voiceDetectionEnabled')
    .optional()
    .isBoolean().withMessage('voiceDetectionEnabled must be a boolean'),
  body('motionDetectionEnabled')
    .optional()
    .isBoolean().withMessage('motionDetectionEnabled must be a boolean'),
  handleValidationErrors,
];

const validateFcmToken = [
  body('fcmToken')
    .notEmpty().withMessage('FCM token is required')
    .isString().withMessage('FCM token must be a string'),
  handleValidationErrors,
];

// ─── Safety Validators ────────────────────────────────────────

const validateNearbyZones = [
  query('lat')
    .notEmpty().withMessage('Latitude is required')
    .isFloat({ min: -90, max: 90 }).withMessage('Latitude must be between -90 and 90'),
  query('lng')
    .notEmpty().withMessage('Longitude is required')
    .isFloat({ min: -180, max: 180 }).withMessage('Longitude must be between -180 and 180'),
  query('radius')
    .optional()
    .isInt({ min: 100, max: 50000 }).withMessage('Radius must be 100-50000 meters'),
  handleValidationErrors,
];

const validateSafeRoute = [
  query('fromLat').notEmpty().isFloat({ min: -90, max: 90 }).withMessage('fromLat required'),
  query('fromLng').notEmpty().isFloat({ min: -180, max: 180 }).withMessage('fromLng required'),
  query('toLat').notEmpty().isFloat({ min: -90, max: 90 }).withMessage('toLat required'),
  query('toLng').notEmpty().isFloat({ min: -180, max: 180 }).withMessage('toLng required'),
  handleValidationErrors,
];

const validateSafetyReport = [
  body('location.coordinates')
    .isArray({ min: 2, max: 2 }).withMessage('Coordinates must be [longitude, latitude]'),
  body('location.coordinates.*')
    .isFloat().withMessage('Coordinates must be numbers'),
  body('description')
    .optional()
    .isLength({ max: 1000 }).withMessage('Description must be under 1000 characters'),
  handleValidationErrors,
];

// ─── Incident Validators ──────────────────────────────────────

const validateIncidentId = [
  param('id')
    .isMongoId().withMessage('Invalid incident ID'),
  handleValidationErrors,
];

module.exports = {
  // Auth
  validateRegister,
  validateLogin,
  validateRefreshToken,
  // SOS
  validateSosTrigger,
  validateSosResolve,
  // User
  validateUpdateProfile,
  validateUpdateContacts,
  validateUpdateAiSettings,
  validateFcmToken,
  // Safety
  validateNearbyZones,
  validateSafeRoute,
  validateSafetyReport,
  // Incident
  validateIncidentId,
};
