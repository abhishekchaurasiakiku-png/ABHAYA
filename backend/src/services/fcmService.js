/**
 * Firebase Cloud Messaging (FCM) service for push notifications.
 * Operating in Mock mode (Firebase Admin credentials disabled).
 */

console.log('ℹ️ FCM running in Mock mode (Firebase Admin disabled for Render deployment)');

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

  // Mock mode notification output
  console.log(`[FCM] 📨 [Mock Mode] Would send SOS notification to token: ${fcmToken.substring(0, 20)}...`);
  console.log(`[FCM]    Data: ${JSON.stringify(data)}`);
  return 'mock-message-id';
};

/**
 * Send resolution notification to guardians.
 */
exports.sendResolutionNotification = async (fcmToken, data) => {
  if (!fcmToken) return;

  console.log(`[FCM] 📨 [Mock Mode] Would send resolution to: ${fcmToken?.substring(0, 20)}...`);
  return 'mock-message-id';
};
