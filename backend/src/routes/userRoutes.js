const router = require('express').Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');
const {
  validateUpdateProfile,
  validateUpdateContacts,
  validateUpdateAiSettings,
  validateFcmToken,
} = require('../middleware/validation');

const multer = require('multer');
const path = require('path');
const fs = require('fs');
const env = require('../config/env');

// Ensure upload directory exists
const uploadDir = path.resolve(process.cwd(), env.uploadDir || './uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, req.userId + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});
const upload = multer({ storage });

router.use(authMiddleware);

router.get('/profile', userController.getProfile);
router.put('/profile', validateUpdateProfile, userController.updateProfile);
router.post('/profile-image', upload.single('image'), userController.uploadProfileImage);
router.put('/contacts', validateUpdateContacts, userController.updateContacts);
router.put('/ai-settings', validateUpdateAiSettings, userController.updateAiSettings);
router.put('/fcm-token', validateFcmToken, userController.updateFcmToken);

module.exports = router;
