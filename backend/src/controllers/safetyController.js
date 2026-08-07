const SafetyZone = require('../models/SafetyZone');
const Incident = require('../models/Incident');

/**
 * GET /api/safety/zones?lat=&lng=&radius=
 * 
 * Geospatial query for nearby safety zones.
 */
exports.getNearbyZones = async (req, res) => {
  try {
    const { lat, lng, radius = 2000 } = req.query; // radius in meters

    if (!lat || !lng) {
      return res.status(400).json({ error: 'lat and lng are required' });
    }

    const zones = await SafetyZone.find({
      polygon: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(lng), parseFloat(lat)],
          },
          $maxDistance: parseInt(radius),
        },
      },
    }).limit(50);

    res.json({ zones });
  } catch (err) {
    // Fallback if geospatial index not available
    console.error('[Safety] Zones query error:', err.message);
    const zones = await SafetyZone.find({}).limit(50);
    res.json({ zones });
  }
};

/**
 * GET /api/safety/route?fromLat=&fromLng=&toLat=&toLng=
 * 
 * Calculate safest route with safety scores.
 * In production, this would integrate with a routing API and
 * overlay safety zone data to score route segments.
 */
exports.getSafeRoute = async (req, res) => {
  try {
    const { fromLat, fromLng, toLat, toLng } = req.query;

    if (!fromLat || !fromLng || !toLat || !toLng) {
      return res.status(400).json({ error: 'from and to coordinates required' });
    }

    // Placeholder: return mock route options with safety scores
    // Production would:
    // 1. Get multiple routes from Google Directions API
    // 2. For each route, sample points along the path
    // 3. Query SafetyZone collection for each point
    // 4. Calculate aggregate safety score per route
    // 5. Return routes ranked by safety

    const routes = [
      {
        label: 'Safest Route',
        safetyScore: 9.2,
        distance: '3.4 km',
        duration: '12 min',
        highlights: ['Well-lit streets', 'CCTV coverage', 'High foot traffic'],
        recommended: true,
      },
      {
        label: 'Balanced Route',
        safetyScore: 7.1,
        distance: '2.8 km',
        duration: '9 min',
        highlights: ['Partially lit', 'Some isolated stretches'],
        recommended: false,
      },
      {
        label: 'Fastest Route',
        safetyScore: 4.5,
        distance: '2.1 km',
        duration: '7 min',
        highlights: ['Poorly lit areas', 'Low foot traffic'],
        recommended: false,
      },
    ];

    res.json({ routes });
  } catch (err) {
    res.status(500).json({ error: 'Failed to calculate route' });
  }
};

/**
 * POST /api/safety/report
 * 
 * Crowd-sourced incident reporting to update safety zones.
 */
exports.reportIncident = async (req, res) => {
  try {
    const { location, description, type } = req.body;

    if (!location || !location.coordinates) {
      return res.status(400).json({ error: 'Location required' });
    }

    // Find the safety zone containing this point
    const zone = await SafetyZone.findOne({
      polygon: {
        $geoIntersects: {
          $geometry: {
            type: 'Point',
            coordinates: location.coordinates,
          },
        },
      },
    });

    if (zone) {
      zone.reportedIncidents += 1;
      // Increase risk score if many reports
      if (zone.reportedIncidents % 5 === 0 && zone.riskScore < 10) {
        zone.riskScore += 1;
      }
      zone.metadata.lastUpdated = new Date();
      await zone.save();
    }

    res.status(201).json({
      message: 'Report received',
      zoneUpdated: !!zone,
    });
  } catch (err) {
    res.status(500).json({ error: 'Failed to submit report' });
  }
};
