const router = require('express').Router();
const incidentController = require('../controllers/incidentController');
const authMiddleware = require('../middleware/authMiddleware');
const { validateIncidentId } = require('../middleware/validation');

router.use(authMiddleware);

router.get('/', incidentController.getIncidents);
router.get('/:id', validateIncidentId, incidentController.getIncidentDetail);
router.post('/:id/media', validateIncidentId, incidentController.upload.single('file'), incidentController.uploadMedia);

module.exports = router;
