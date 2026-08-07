/**
 * Firebase Cloud Messaging (FCM) service for push notifications.
 * 
 * Dispatches SOS alerts to guardians with < 2 second target latency.
 * 
 * Setup:
 * 1. Download your Firebase Admin SDK service account JSON
 * 2. Set FIREBASE_CREDENTIALS_PATH in .env
 * 3. Uncomment the Firebase initialization below
 */

const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

// Initialize Firebase Admin
const credentialsPath = process.env.FIREBASE_CREDENTIALS_PATH;
if (credentialsPath && fs.existsSync(path.resolve(credentialsPath))) {
  const serviceAccount = require(path.resolve(credentialsPath));
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log('✅ Firebase Admin initialized');
} else {
  console.log('⚠️ Firebase Admin credentials not found or invalid. FCM will run in Mock mode.');
}

/**
 * Send SOS notification to a guardian via FCM.
 * 
 * @param {string} fcmToken - Guardian's device FCM token
 * @param {Object} data - SOS data payload
 */
exports.sendSosNotification = async (fcmToken, data) => {
  if (!fcmToken) {
    console.log('[FCM] No token — skipping notification');
    return;
  }

  const message = {
    token: fcmToken,
    notification: {
      title: '🆘 EMERGENCY: SOS Alert',
      body: `${data.userName} has triggered an emergency SOS (${data.triggerType})`,
    },
    data: {
      type: 'sos_alert',
      incidentId: data.incidentId,
      triggerType: data.triggerType,
      location: data.location,
      mapsUrl: data.mapsUrl,
      timestamp: new Date().toISOString(),
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'sos_channel',
        priority: 'max',
        sound: 'default',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      },
    },
    apns: {
      headers: {
        'apns-priority': '10',
        'apns-push-type': 'alert',
      },
      payload: {
        aps: {
          alert: {
            title: '🆘 EMERGENCY: SOS Alert',
            body: `${data.userName} needs help! (${data.triggerType})`,
          },
          badge: 1,
          sound: 'default',
          'content-available': 1,
          'interruption-level': 'critical',
        },
      },
    },
  };

  // Production with active FCM admin SDK (fallback to mock mode if credentials not loaded)
  try {
    if (admin.apps.length > 0) {
      const response = await admin.messaging().send(message);
      console.log(`[FCM] ✅ Notification sent: ${response}`);
      return response;
    }
  } catch (err) {
    console.error(`[FCM] ❌ Failed to send active FCM notification: ${err.message}`);
    throw err;
  }

  // Development fallback/placeholder
  console.log(`[FCM] 📨 [Mock Mode] Would send SOS notification to token: ${fcmToken.substring(0, 20)}...`);
  console.log(`[FCM]    Data: ${JSON.stringify(data)}`);
  return 'mock-message-id';
};

/**
 * Send resolution notification to guardians.
 */
exports.sendResolutionNotification = async (fcmToken, data) => {
  if (!fcmToken) return;

  const message = {
    token: fcmToken,
    notification: {
      title: '✅ SOS Resolved',
      body: `${data.userName}'s emergency status has been resolved safely.`,
    },
    data: {
      type: 'sos_resolved',
      incidentId: data.incidentId,
      timestamp: new Date().toISOString(),
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'sos_channel',
        sound: 'default',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      },
    },
  };

  try {
    if (admin.apps.length > 0) {
      const response = await admin.messaging().send(message);
      console.log(`[FCM] ✅ Resolution sent: ${response}`);
      return response;
    }
  } catch (err) {
    console.error(`[FCM] ❌ Failed to send active FCM resolution: ${err.message}`);
    throw err;
  }

  console.log(`[FCM] 📨 [Mock Mode] Would send resolution to: ${fcmToken?.substring(0, 20)}...`);
  return 'mock-message-id';
};
