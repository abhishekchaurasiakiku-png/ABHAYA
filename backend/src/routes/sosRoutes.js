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
router.post('/share-location', sosController.shareLiveLocation);
router.put('/:id/resolve', validateSosResolve, sosController.resolveSos);
router.put('/:id/location', sosController.updateLocation);
router.get('/active', sosController.getActiveSos);

module.exports = router;
