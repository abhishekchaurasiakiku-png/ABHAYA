const router = require('express').Router();
const authController = require('../controllers/authController');
const { authLimiter } = require('../middleware/rateLimiter');
const {
  validateRegister,
  validateLogin,
  validateRefreshToken,
} = require('../middleware/validation');

// Apply auth rate limiter to all auth routes
router.use(authLimiter);

router.post('/register', validateRegister, authController.register);
router.post('/login', validateLogin, authController.login);
router.post('/refresh', validateRefreshToken, authController.refreshToken);

module.exports = router;
