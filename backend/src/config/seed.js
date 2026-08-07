const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const SafetyZone = require('../models/SafetyZone');
const Incident = require('../models/Incident');

/**
 * Seeds initial database collections (users, safetyzones, incidents)
 * according to the SafeHer-AI / ABHAYA application requirements.
 */
async function seedDatabase() {
  try {
    const userCount = await User.countDocuments();
    const safetyZoneCount = await SafetyZone.countDocuments();
    const incidentCount = await Incident.countDocuments();

    console.log(`📊 Database Status — Users: ${userCount}, SafetyZones: ${safetyZoneCount}, Incidents: ${incidentCount}`);

    let demoUser;
    if (userCount === 0) {
      console.log('🌱 Seeding initial Users collection...');
      const hashedPassword = await bcrypt.hash('password123', 12);
      demoUser = await User.create({
        name: 'Priya Sharma',
        email: 'priya@example.com',
        phone: '+919876543210',
        passwordHash: hashedPassword,
        emergencyContacts: [
          {
            name: 'Rahul Sharma (Brother)',
            phone: '+919876543211',
            email: 'rahul@example.com',
            relationship: 'Family',
            notifyOnSos: true,
          },
          {
            name: 'Anjali Verma (Friend)',
            phone: '+919876543212',
            email: 'anjali@example.com',
            relationship: 'Friend',
            notifyOnSos: true,
          },
        ],
        aiSettings: {
          voiceSensitivity: 0.8,
          motionSensitivity: 0.75,
          voiceDetectionEnabled: true,
          motionDetectionEnabled: true,
          distressKeywords: ['help me', 'save me', 'bachao', 'please help', 'stop'],
        },
      });
      console.log('✅ Created initial user in `users` collection: priya@example.com');
    } else {
      demoUser = await User.findOne();
    }

    if (safetyZoneCount === 0) {
      console.log('🌱 Seeding initial SafetyZones collection...');
      await SafetyZone.insertMany([
        {
          name: 'Central City Center (Safe Zone)',
          description: 'Well-lit area with active security, high foot traffic, and CCTV coverage.',
          riskScore: 2,
          reportedIncidents: 1,
          polygon: {
            type: 'Polygon',
            coordinates: [[
              [77.208, 28.612],
              [77.215, 28.612],
              [77.215, 28.619],
              [77.208, 28.619],
              [77.208, 28.612],
            ]],
          },
          metadata: {
            hasStreetLighting: true,
            hasCCTV: true,
            userDensity: 450,
            lastUpdated: new Date(),
          },
        },
        {
          name: 'Transit Terminal Corridor (Moderate Zone)',
          description: 'Moderate lighting with regular police patrols during peak hours.',
          riskScore: 5,
          reportedIncidents: 3,
          polygon: {
            type: 'Polygon',
            coordinates: [[
              [77.215, 28.619],
              [77.225, 28.619],
              [77.225, 28.628],
              [77.215, 28.628],
              [77.215, 28.619],
            ]],
          },
          metadata: {
            hasStreetLighting: true,
            hasCCTV: true,
            userDensity: 280,
            lastUpdated: new Date(),
          },
        },
        {
          name: 'Outer Bypass Segment (High Risk Alert)',
          description: 'Poorly lit area after late hours. High caution advised.',
          riskScore: 8,
          reportedIncidents: 7,
          polygon: {
            type: 'Polygon',
            coordinates: [[
              [77.225, 28.628],
              [77.240, 28.628],
              [77.240, 28.640],
              [77.225, 28.640],
              [77.225, 28.628],
            ]],
          },
          metadata: {
            hasStreetLighting: false,
            hasCCTV: false,
            userDensity: 50,
            lastUpdated: new Date(),
          },
        },
      ]);
      console.log('✅ Created safety zones in `safetyzones` collection');
    }

    if (incidentCount === 0 && demoUser) {
      console.log('🌱 Seeding initial Incidents collection...');
      await Incident.create({
        userId: demoUser._id,
        triggerType: 'Manual',
        status: 'Resolved',
        timestamp: new Date(Date.now() - 86400000),
        resolvedAt: new Date(Date.now() - 82800000),
        location: {
          type: 'Point',
          coordinates: [77.212, 28.615],
        },
        notes: 'Sample emergency alert test resolved safely',
        notifiedContacts: [
          {
            phone: '+919876543211',
            notifiedAt: new Date(Date.now() - 86400000),
            method: 'push',
          },
        ],
      });
      console.log('✅ Created initial incident in `incidents` collection');
    }

    console.log('✨ All database collections (`users`, `safetyzones`, `incidents`) are ready!');
  } catch (err) {
    console.error('❌ Database seeding error:', err.message);
  }
}

module.exports = seedDatabase;
