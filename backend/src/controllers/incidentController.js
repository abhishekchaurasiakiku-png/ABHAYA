const Incident = require('../models/Incident');
const multer = require('multer');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

// Multer config for evidence uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, process.env.UPLOAD_DIR || './uploads');
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `evidence_${uuidv4()}${ext}`);
  },
});

exports.upload = multer({
  storage,
  limits: { fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10485760 },
});

/**
 * GET /api/incidents
 */
exports.getIncidents = async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const incidents = await Incident.find({ userId: req.userId })
      .sort({ timestamp: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Incident.countDocuments({ userId: req.userId });

    res.json({
      incidents,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / parseInt(limit)),
    });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch incidents' });
  }
};

/**
 * GET /api/incidents/:id
 */
exports.getIncidentDetail = async (req, res) => {
  try {
    const incident = await Incident.findOne({
      _id: req.params.id,
      userId: req.userId,
    });
    if (!incident) return res.status(404).json({ error: 'Incident not found' });
    res.json(incident);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch incident' });
  }
};

/**
 * POST /api/incidents/:id/media
 */
exports.uploadMedia = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file provided' });
    }

    const mediaUrl = `/uploads/${req.file.filename}`;

    const incident = await Incident.findOneAndUpdate(
      { _id: req.params.id, userId: req.userId },
      { $push: { mediaLinks: mediaUrl } },
      { new: true }
    );

    if (!incident) return res.status(404).json({ error: 'Incident not found' });

    res.json({ mediaUrl, incident });
  } catch (err) {
    res.status(500).json({ error: 'Failed to upload media' });
  }
};
