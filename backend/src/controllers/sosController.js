const Incident = require('../models/Incident');
const User = require('../models/User');
const { sendSosNotification } = require('../services/fcmService');

/**
 * POST /api/sos/trigger
 * 
 * Receives SOS alert, creates incident, and dispatches FCM
 * notifications to guardians. Target: < 2 seconds total latency.
 */
exports.triggerSos = async (req, res) => {
  const startTime = Date.now();

  try {
    const { triggerType, location, timestamp, contactPhones } = req.body;

    // Create incident
    const incident = new Incident({
      userId: req.userId,
      triggerType,
      timestamp: timestamp || new Date(),
      location: location || { type: 'Point', coordinates: [0, 0] },
      status: 'Active',
    });

    // Save incident and fetch user data in parallel for speed
    const [savedIncident, user] = await Promise.all([
      incident.save(),
      User.findById(req.userId),
    ]);

    // Dispatch FCM notifications to emergency contacts (non-blocking)
    if (user && user.emergencyContacts.length > 0) {
      const notifyPromises = user.emergencyContacts
        .filter(c => c.notifyOnSos && c.fcmToken)
        .map(contact =>
          sendSosNotification(contact.fcmToken, {
            userName: user.name,
            incidentId: savedIncident._id.toString(),
            triggerType,
            location: location?.coordinates
              ? `${location.coordinates[1]},${location.coordinates[0]}`
              : 'Unknown',
            mapsUrl: location?.coordinates
              ? `https://maps.google.com/?q=${location.coordinates[1]},${location.coordinates[0]}`
              : '',
          }).catch(err => console.error('[SOS] FCM failed for contact:', err.message))
        );

      // Don't await — fire and forget for speed
      Promise.all(notifyPromises);

      // Log notified contacts
      savedIncident.notifiedContacts = user.emergencyContacts
        .filter(c => c.notifyOnSos)
        .map(c => ({
          phone: c.phone,
          notifiedAt: new Date(),
          method: c.fcmToken ? 'push' : 'sms',
        }));
      await savedIncident.save();
    }

    const latency = Date.now() - startTime;
    console.log(`[SOS] ✅ Triggered in ${latency}ms (target: <2000ms)`);

    res.status(201).json({
      _id: savedIncident._id,
      userId: savedIncident.userId,
      triggerType: savedIncident.triggerType,
      timestamp: savedIncident.timestamp,
      location: savedIncident.location,
      status: savedIncident.status,
      latencyMs: latency,
    });
  } catch (err) {
    console.error('[SOS] Trigger error:', err.message);
    res.status(500).json({ error: 'Failed to trigger SOS' });
  }
};

/**
 * PUT /api/sos/:id/resolve
 */
exports.resolveSos = async (req, res) => {
  try {
    const { status, resolvedAt, notes } = req.body;

    const incident = await Incident.findOneAndUpdate(
      { _id: req.params.id, userId: req.userId },
      {
        status: status || 'Resolved',
        resolvedAt: resolvedAt || new Date(),
        notes,
      },
      { new: true }
    );

    if (!incident) {
      return res.status(404).json({ error: 'Incident not found' });
    }

    console.log(`[SOS] ✅ Incident ${req.params.id} resolved`);
    res.json(incident);
  } catch (err) {
    console.error('[SOS] Resolve error:', err.message);
    res.status(500).json({ error: 'Failed to resolve SOS' });
  }
};

/**
 * GET /api/sos/active
 */
exports.getActiveSos = async (req, res) => {
  try {
    const incidents = await Incident.find({
      userId: req.userId,
      status: 'Active',
    }).sort({ timestamp: -1 });

    res.json({ incidents });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch active incidents' });
  }
};
