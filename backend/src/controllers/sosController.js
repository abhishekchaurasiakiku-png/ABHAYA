const Incident = require('../models/Incident');
const User = require('../models/User');
const { sendSosNotification } = require('../services/fcmService');
const { sendSosSms, sendSosEmail } = require('../services/notificationService');
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

    // Dispatch notifications to emergency contacts
    if (user && user.emergencyContacts.length > 0) {
      const mapsUrl = location?.coordinates
        ? `https://maps.google.com/?q=${location.coordinates[1]},${location.coordinates[0]}`
        : '';
        
      const smsMessage = `SOS ALERT: ${user.name} has triggered an emergency alarm. Last known location: ${mapsUrl}`;
      const emailHtml = `<h2>SOS ALERT: ${user.name}</h2><p>${user.name} has triggered an emergency alarm.</p><p>Location: <a href="${mapsUrl}">${mapsUrl}</a></p>`;

      for (const contact of user.emergencyContacts) {
        if (!contact.notifyOnSos) continue;
        
        // FCM push
        if (contact.fcmToken) {
          sendSosNotification(contact.fcmToken, {
            userName: user.name,
            incidentId: savedIncident._id.toString(),
            triggerType,
            mapsUrl,
          }).catch(err => console.error('[SOS] FCM failed for contact:', err.message));
        }
        
        // SMS
        if (contact.phone) {
          sendSosSms(contact.phone, smsMessage);
        }
        
        // Email
        if (contact.email) {
          sendSosEmail(contact.email, `URGENT: SOS Alert from ${user.name}`, emailHtml);
        }
      }

      // Log notified contacts
      savedIncident.notifiedContacts = user.emergencyContacts
        .filter(c => c.notifyOnSos)
        .map(c => ({
          phone: c.phone,
          notifiedAt: new Date(),
          method: 'sms', // Simplified since we are now sending via multiple channels
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
 * PUT /api/sos/:id/location
 * Updates real-time location for an active SOS
 */
exports.updateLocation = async (req, res) => {
  try {
    const { coordinates } = req.body; // [lng, lat]
    if (!coordinates || coordinates.length !== 2) {
      return res.status(400).json({ error: 'Invalid coordinates' });
    }

    const incident = await Incident.findOneAndUpdate(
      { _id: req.params.id, userId: req.userId, status: 'Active' },
      {
        $set: { location: { type: 'Point', coordinates } },
        $push: { locationHistory: { coordinates, timestamp: new Date() } }
      },
      { new: true }
    );

    if (!incident) {
      return res.status(404).json({ error: 'Active incident not found' });
    }

    res.json({ message: 'Location updated' });
  } catch (err) {
    console.error('[SOS] Location update error:', err.message);
    res.status(500).json({ error: 'Failed to update location' });
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
