const User = require('../models/User');
const Alert = require('../models/Alert');

/**
 * TRIGGER SOS
 * Route: POST /api/v1/alerts/trigger
 * 
 * Logic:
 * 1. Create a new Alert in ACTIVE status.
 * 2. Simulate notifying the user's personal emergency contacts.
 * 3. Perform a geospatial $near query to find active Guardians within 500m.
 * 4. Dispatch the alert to matched Guardians.
 */
exports.triggerSOS = async (req, res) => {
  try {
    const { user_id, latitude, longitude, battery_level, severity = 'HIGH' } = req.body;

    // Validate Input
    if (!user_id || !latitude || !longitude) {
      return res.status(400).json({ error: 'user_id, latitude, and longitude are required.' });
    }

    // 1. Fetch User (to check settings and contacts)
    const user = await User.findById(user_id);
    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }

    // 2. Create the Alert
    const newAlert = new Alert({
      user_id,
      severity,
      location_history: [{
        type: 'Point',
        coordinates: [longitude, latitude] // Note: GeoJSON is [longitude, latitude]
      }]
    });

    // 3. Notify Emergency Contacts (Simulation)
    console.log(`[SYS] Notifying ${user.emergency_contacts.length} emergency contacts for user ${user.phone}...`);
    // Example: Twilio API call would go here to send SMS.

    let dispatchedGuardians = [];

    // 4. Guardian Network Proximity Search
    if (user.trust_level === 'CONTACTS_AND_GUARDIANS') {
      console.log(`[SYS] Scanning for Guardians within 500 meters...`);
      
      const maxDistance = 500; // in meters
      
      const nearbyGuardians = await User.find({
        role: 'GUARDIAN',
        is_verified_guardian: true,
        _id: { $ne: user._id }, // Don't notify the user themselves
        location: {
          $near: {
            $geometry: {
              type: 'Point',
              coordinates: [longitude, latitude]
            },
            $maxDistance: maxDistance
          }
        }
      });

      console.log(`[SYS] Found ${nearbyGuardians.length} nearby guardians.`);
      
      // Dispatch alert to guardians (Simulation)
      dispatchedGuardians = nearbyGuardians.map(g => g._id);
      
      // Add dispatched guardians to the alert record
      newAlert.dispatched_guardians = dispatchedGuardians;
      
      // Example: Send Push Notifications via Firebase/Socket.io here.
    }

    await newAlert.save();

    return res.status(201).json({
      message: 'SOS Alert triggered successfully.',
      alert_id: newAlert._id,
      notified_contacts_count: user.emergency_contacts.length,
      dispatched_guardians_count: dispatchedGuardians.length,
      battery_level_noted: battery_level
    });

  } catch (error) {
    console.error('Error triggering SOS:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
};

/**
 * RESOLVE ALERT
 * Route: POST /api/v1/alerts/:id/resolve
 */
exports.resolveAlert = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body; // 'RESOLVED' or 'FALSE_ALARM'

    if (!['RESOLVED', 'FALSE_ALARM'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status. Must be RESOLVED or FALSE_ALARM' });
    }

    const alert = await Alert.findByIdAndUpdate(
      id, 
      { status }, 
      { new: true }
    );

    if (!alert) {
      return res.status(404).json({ error: 'Alert not found.' });
    }

    // Stand down simulation
    console.log(`[SYS] Alert ${id} marked as ${status}. Sending stand-down notification to Guardians.`);

    return res.status(200).json({
      message: `Alert marked as ${status}`,
      alert
    });

  } catch (error) {
    console.error('Error resolving alert:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
};
