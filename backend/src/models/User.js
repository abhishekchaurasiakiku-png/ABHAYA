const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const emergencyContactSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phone: { type: String, required: true },
  email: { type: String },
  relationship: { type: String, default: 'Other' },
  notifyOnSos: { type: Boolean, default: true },
  fcmToken: { type: String },
});

const aiSettingsSchema = new mongoose.Schema({
  voiceSensitivity: { type: Number, default: 0.75, min: 0, max: 1 },
  motionSensitivity: { type: Number, default: 0.70, min: 0, max: 1 },
  voiceDetectionEnabled: { type: Boolean, default: true },
  motionDetectionEnabled: { type: Boolean, default: true },
  distressKeywords: {
    type: [String],
    default: ['help me', 'save me', 'bachao', 'please help', 'somebody help'],
  },
}, { _id: false });

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Name is required'],
    trim: true,
  },
  phone: {
    type: String,
    required: [true, 'Phone number is required'],
    trim: true,
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    trim: true,
  },
  profileImage: {
    type: String,
  },
  passwordHash: {
    type: String,
    required: true,
  },
  emergencyContacts: [emergencyContactSchema],
  trustedDevices: [String],
  aiSettings: {
    type: aiSettingsSchema,
    default: () => ({}),
  },
  fcmToken: { type: String },
  refreshToken: { type: String },
}, {
  timestamps: true,
});

// Hash password before saving
userSchema.pre('save', async function (next) {
  if (!this.isModified('passwordHash')) return next();
  // Safety check: if already hashed (bcrypt hash starts with $2b$), skip
  if (this.passwordHash && this.passwordHash.startsWith('$2b$')) return next();
  this.passwordHash = await bcrypt.hash(this.passwordHash, 12);
  next();
});

// Compare password
userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.passwordHash);
};

// Remove sensitive data when converting to JSON
userSchema.methods.toSafeJSON = function () {
  const obj = this.toObject();
  delete obj.passwordHash;
  delete obj.refreshToken;
  delete obj.__v;
  return obj;
};

module.exports = mongoose.model('User', userSchema);
