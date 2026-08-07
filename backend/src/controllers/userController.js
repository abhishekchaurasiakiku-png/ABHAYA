const User = require('../models/User');

/**
 * GET /api/users/profile
 */
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user.toSafeJSON());
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
};

/**
 * PUT /api/users/profile
 */
exports.updateProfile = async (req, res) => {
  try {
    const { name, phone, profileImage } = req.body;
    const updateFields = {};
    if (name !== undefined) updateFields.name = name;
    if (phone !== undefined) updateFields.phone = phone;
    if (profileImage !== undefined) updateFields.profileImage = profileImage;

    const user = await User.findByIdAndUpdate(
      req.userId,
      { $set: updateFields },
      { new: true, runValidators: true }
    );
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user.toSafeJSON());
  } catch (err) {
    res.status(500).json({ error: 'Failed to update profile' });
  }
};

/**
 * PUT /api/users/contacts
 */
exports.updateContacts = async (req, res) => {
  try {
    const { emergencyContacts } = req.body;
    const user = await User.findByIdAndUpdate(
      req.userId,
      { $set: { emergencyContacts } },
      { new: true }
    );
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user.toSafeJSON());
  } catch (err) {
    res.status(500).json({ error: 'Failed to update contacts' });
  }
};

/**
 * PUT /api/users/ai-settings
 */
exports.updateAiSettings = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.userId,
      { $set: { aiSettings: req.body } },
      { new: true }
    );
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user.toSafeJSON());
  } catch (err) {
    res.status(500).json({ error: 'Failed to update AI settings' });
  }
};

/**
 * PUT /api/users/fcm-token
 *
 * Register/update the user's FCM device token for push notifications.
 * Called by the Flutter app after obtaining the FCM token.
 */
exports.updateFcmToken = async (req, res) => {
  try {
    const { fcmToken } = req.body;
    const user = await User.findByIdAndUpdate(
      req.userId,
      { $set: { fcmToken } },
      { new: true }
    );
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ message: 'FCM token updated', fcmToken: user.fcmToken });
  } catch (err) {
    res.status(500).json({ error: 'Failed to update FCM token' });
  }
};
