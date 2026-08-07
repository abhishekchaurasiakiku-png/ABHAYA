const router = require('express').Router();
const safetyController = require('../controllers/safetyController');
const authMiddleware = require('../middleware/authMiddleware');
const {
  validateNearbyZones,
  validateSafeRoute,
  validateSafetyReport,
} = require('../middleware/validation');

router.use(authMiddleware);

router.get('/zones', validateNearbyZones, safetyController.getNearbyZones);
router.get('/route', validateSafeRoute, safetyController.getSafeRoute);
router.post('/report', validateSafetyReport, safetyController.reportIncident);

module.exports = router;
