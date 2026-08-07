const mongoose = require('mongoose');

const safetyZoneSchema = new mongoose.Schema({
  polygon: {
    type: {
      type: String,
      enum: ['Polygon'],
      default: 'Polygon',
    },
    coordinates: {
      type: [[[Number]]], // Array of LinearRings, each an array of [lng, lat] pairs
      required: true,
    },
  },
  riskScore: {
    type: Number,
    required: true,
    min: 1,
    max: 10,
    index: true,
  },
  reportedIncidents: {
    type: Number,
    default: 0,
  },
  name: { type: String },
  description: { type: String },
  metadata: {
    hasStreetLighting: { type: Boolean, default: false },
    hasCCTV: { type: Boolean, default: false },
    userDensity: { type: Number }, // Estimated users per sq km
    lastUpdated: { type: Date, default: Date.now },
  },
}, {
  timestamps: true,
});

// 2dsphere index for geospatial queries
safetyZoneSchema.index({ polygon: '2dsphere' });

module.exports = mongoose.model('SafetyZone', safetyZoneSchema);
