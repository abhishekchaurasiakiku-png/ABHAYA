const Incident = require('../models/Incident');
const User = require('../models/User');
const { sendSosNotification } = require('../services/fcmService');
const { sendSosSms, sendSosEmail } = require('../services/notificationService');

const generateEmailHtml = (user, type, triggerType, mapsUrl) => {
  const isSos = type === 'SOS';
  const color = isSos ? '#ff0033' : '#00bfa5';
  const title = isSos ? '🚨 URGENT SOS ALERT' : '📍 Live Location Shared';
  
  return `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 2px solid ${color}; border-radius: 10px; overflow: hidden;">
      <div style="background-color: ${color}; color: white; padding: 15px; text-align: center;">
        <h2 style="margin: 0;">${title}</h2>
      </div>
      <div style="padding: 20px;">
        <p style="font-size: 16px;"><strong>${user.name}</strong> ${isSos ? 'has triggered an emergency alarm' : 'is sharing their live location with you'}.</p>
        
        <h3 style="color: ${color}; border-bottom: 1px solid #ccc; padding-bottom: 5px;">User Condition & Details</h3>
        <ul style="list-style: none; padding: 0;">
          ${isSos ? `<li style="margin-bottom: 8px;"><strong>Trigger Reason:</strong> ${triggerType}</li>` : ''}
          <li style="margin-bottom: 8px;"><strong>Phone Number:</strong> ${user.phone || 'Not provided'}</li>
          <li style="margin-bottom: 8px;"><strong>Blood Group:</strong> ${user.bloodGroup || 'Not specified'}</li>
          <li style="margin-bottom: 8px;"><strong>Medical Notes:</strong> ${user.medicalDetails || 'None provided'}</li>
          <li style="margin-bottom: 8px;"><strong>Home Address:</strong> ${user.homeAddress || 'Not specified'}</li>
        </ul>

        <div style="text-align: center; margin-top: 25px;">
          <a href="${mapsUrl}" style="background-color: ${color}; color: white; padding: 12px 25px; text-decoration: none; border-radius: 5px; font-weight: bold; display: inline-block;">View Live Location on Google Maps</a>
        </div>
      </div>
      <div style="background-color: #f4f4f4; padding: 10px; text-align: center; font-size: 12px; color: #666;">
        SafeHer-AI Automated Emergency System
      </div>
    </div>
  `;
};

exports.triggerSos = async (req, res) => {
  const startTime = Date.now();

  try {
    const { triggerType, location, timestamp, contactPhones } = req.body;

    const incident = new Incident({
      userId: req.userId,
      triggerType,
      timestamp: timestamp || new Date(),
      location: location || { type: 'Point', coordinates: [0, 0] },
      status: 'Active',
    });

    const [savedIncident, user] = await Promise.all([
      incident.save(),
      User.findById(req.userId),
    ]);

    if (user && user.emergencyContacts.length > 0) {
      const mapsUrl = location?.coordinates
        ? `https://maps.google.com/?q=${location.coordinates[1]},${location.coordinates[0]}`
        : '';
        
      const smsMessage = `SOS ALERT: ${user.name} has triggered an emergency alarm. Last known location: ${mapsUrl}`;
      const emailHtml = generateEmailHtml(user, 'SOS', triggerType, mapsUrl);

      for (const contact of user.emergencyContacts) {
        if (!contact.notifyOnSos) continue;
        
        if (contact.fcmToken) {
          sendSosNotification(contact.fcmToken, {
            userName: user.name,
            incidentId: savedIncident._id.toString(),
            triggerType,
            mapsUrl,
          }).catch(err => console.error('[SOS] FCM failed for contact:', err.message));
        }
        
        if (contact.phone) {
          sendSosSms(contact.phone, smsMessage);
        }
        
        if (contact.email) {
          sendSosEmail(contact.email, `URGENT: SOS Alert from ${user.name}`, emailHtml);
        }
      }

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

exports.shareLiveLocation = async (req, res) => {
  try {
    const { location } = req.body;
    
    if (!location || !location.coordinates) {
      return res.status(400).json({ error: 'Location is required' });
    }

    const user = await User.findById(req.userId);
    if (!user || user.emergencyContacts.length === 0) {
      return res.status(400).json({ error: 'No emergency contacts found' });
    }

    const mapsUrl = `https://maps.google.com/?q=${location.coordinates[1]},${location.coordinates[0]}`;
    const emailHtml = generateEmailHtml(user, 'SHARE', null, mapsUrl);
    const smsMessage = `${user.name} is sharing their live location: ${mapsUrl}`;

    for (const contact of user.emergencyContacts) {
      if (contact.email) {
        sendSosEmail(contact.email, `Live Location Update from ${user.name}`, emailHtml);
      }
      if (contact.phone) {
        sendSosSms(contact.phone, smsMessage);
      }
    }

    res.json({ message: 'Live location shared successfully' });
  } catch (err) {
    console.error('[SOS] Share location error:', err.message);
    res.status(500).json({ error: 'Failed to share live location' });
  }
};
