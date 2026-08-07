const router = require('express').Router();
const sosController = require('../controllers/sosController');
const authMiddleware = require('../middleware/authMiddleware');
const { sosLimiter } = require('../middleware/rateLimiter');
const {
  validateSosTrigger,
  validateSosResolve,
} = require('../middleware/validation');

router.use(authMiddleware);

router.post('/trigger', sosLimiter, validateSosTrigger, sosController.triggerSos);
router.put('/:id/resolve', validateSosResolve, sosController.resolveSos);
router.get('/active', sosController.getActiveSos);

module.exports = router;
