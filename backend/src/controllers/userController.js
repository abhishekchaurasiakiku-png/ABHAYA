const User = require('../models/User');


exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user.toSafeJSON());
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
};


exports.updateProfile = async (req, res) => {
  try {
    const { name, phone, profileImage, bloodGroup, medicalDetails, homeAddress, workAddress } = req.body;
    const updateFields = {};
    if (name !== undefined) updateFields.name = name;
    if (phone !== undefined) updateFields.phone = phone;
    if (profileImage !== undefined) updateFields.profileImage = profileImage;
    if (bloodGroup !== undefined) updateFields.bloodGroup = bloodGroup;
    if (medicalDetails !== undefined) updateFields.medicalDetails = medicalDetails;
    if (homeAddress !== undefined) updateFields.homeAddress = homeAddress;
    if (workAddress !== undefined) updateFields.workAddress = workAddress;

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


exports.uploadProfileImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image file uploaded' });
    }

    const imageUrl = `/uploads/${req.file.filename}`;

    const user = await User.findByIdAndUpdate(
      req.userId,
      { $set: { profileImage: imageUrl } },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ message: 'Profile image uploaded successfully', profileImage: imageUrl });
  } catch (err) {
    console.error('[User] Image upload error:', err.message);
    res.status(500).json({ error: 'Failed to upload profile image' });
  }
};
