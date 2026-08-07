const mongoose = require('mongoose');

const incidentSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  triggerType: {
    type: String,
    enum: ['Voice', 'Motion', 'Manual', 'Multi-Modal'],
    required: true,
  },
  timestamp: {
    type: Date,
    default: Date.now,
    index: true,
  },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point',
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      required: true,
    },
  },
  status: {
    type: String,
    enum: ['Active', 'Resolved', 'False Alarm'],
    default: 'Active',
  },
  mediaLinks: [String],
  resolvedAt: { type: Date },
  notes: { type: String },
  // Contacts notified during this incident
  notifiedContacts: [{
    phone: String,
    notifiedAt: Date,
    method: { type: String, enum: ['push', 'sms'], default: 'push' },
  }],
}, {
  timestamps: true,
});

// 2dsphere index for geospatial queries
incidentSchema.index({ location: '2dsphere' });

// Compound index for user-specific queries
incidentSchema.index({ userId: 1, timestamp: -1 });

module.exports = mongoose.model('Incident', incidentSchema);
