const router = require('express').Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');
const {
  validateUpdateProfile,
  validateUpdateContacts,
  validateUpdateAiSettings,
  validateFcmToken,
} = require('../middleware/validation');

router.use(authMiddleware);

router.get('/profile', userController.getProfile);
router.put('/profile', validateUpdateProfile, userController.updateProfile);
router.put('/contacts', validateUpdateContacts, userController.updateContacts);
router.put('/ai-settings', validateUpdateAiSettings, userController.updateAiSettings);
router.put('/fcm-token', validateFcmToken, userController.updateFcmToken);

module.exports = router;
