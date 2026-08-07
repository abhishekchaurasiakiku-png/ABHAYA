const express = require('express');
const router = express.Router();
const alertController = require('../controllers/alertController');

// POST /api/v1/alerts/trigger
router.post('/trigger', alertController.triggerSOS);

// POST /api/v1/alerts/:id/resolve
router.post('/:id/resolve', alertController.resolveAlert);

module.exports = router;
