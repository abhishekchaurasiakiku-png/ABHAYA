const mongoose = require('mongoose');

const emergencyContactSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phone: { type: String, required: true },
  relation: { type: String }
});

const userSchema = new mongoose.Schema({
  phone: { type: String, required: true, unique: true },
  role: { 
    type: String, 
    enum: ['STANDARD', 'GUARDIAN'], 
    default: 'STANDARD' 
  },
  emergency_contacts: [emergencyContactSchema],
  trust_level: {
    type: String,
    enum: ['CONTACTS_ONLY', 'CONTACTS_AND_GUARDIANS'],
    default: 'CONTACTS_AND_GUARDIANS'
  },
  is_verified_guardian: { type: Boolean, default: false },
  
  // Geospatial field for finding nearby guardians
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      default: [0, 0]
    }
  },
  last_location_update: { type: Date, default: Date.now }
}, { timestamps: true });

// Crucial: Create a 2dsphere index on the location field for $near queries
userSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('User', userSchema);
