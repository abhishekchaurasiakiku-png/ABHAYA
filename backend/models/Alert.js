const mongoose = require('mongoose');

const pointSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['Point'],
    required: true,
    default: 'Point'
  },
  coordinates: {
    type: [Number], // [longitude, latitude]
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

const alertSchema = new mongoose.Schema({
  user_id: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  status: { 
    type: String, 
    enum: ['ACTIVE', 'RESOLVED', 'FALSE_ALARM'], 
    default: 'ACTIVE' 
  },
  severity: { 
    type: String, 
    enum: ['LOW', 'HIGH', 'CRITICAL'], 
    default: 'HIGH' 
  },
  
  // Track the history of the user's location during the alert
  location_history: [pointSchema],
  
  // Store the IDs of Guardians who were dispatched/notified
  dispatched_guardians: [{ 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User' 
  }],
  
  // Array of secure URLs pointing to AWS S3 / Cloud storage
  evidence_links: [{
    url: String,
    hash: String, // SHA-256 hash to ensure tamper-evidence
    timestamp: { type: Date, default: Date.now }
  }]
}, { timestamps: true });

module.exports = mongoose.model('Alert', alertSchema);
