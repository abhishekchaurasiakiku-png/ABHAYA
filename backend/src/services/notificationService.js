const nodemailer = require('nodemailer');
const twilio = require('twilio');
const config = require('../config/env');

let twilioClient = null;
if (config.twilio.sid && config.twilio.authToken) {
  try {
    twilioClient = twilio(config.twilio.sid, config.twilio.authToken);
  } catch (err) {
    console.error('[NotificationService] Twilio init failed:', err.message);
  }
}

let mailTransporter = null;
if (config.smtp.user && config.smtp.pass) {
  mailTransporter = nodemailer.createTransport({
    service: 'gmail', // You can change this or make it configurable
    auth: {
      user: config.smtp.user,
      pass: config.smtp.pass,
    },
  });
}

/**
 * Send an SMS to a trusted contact
 */
exports.sendSosSms = async (to, message) => {
  if (!twilioClient || !config.twilio.fromNumber) {
    console.log(`[SIMULATED SMS to ${to}]: ${message}`);
    return;
  }
  
  try {
    await twilioClient.messages.create({
      body: message,
      from: config.twilio.fromNumber,
      to,
    });
    console.log(`[NotificationService] SMS sent to ${to}`);
  } catch (err) {
    console.error(`[NotificationService] Failed to send SMS to ${to}:`, err.message);
  }
};

/**
 * Send an Email to a trusted contact
 */
exports.sendSosEmail = async (to, subject, html) => {
  if (!mailTransporter) {
    console.log(`[SIMULATED EMAIL to ${to}] Subject: ${subject}`);
    return;
  }

  try {
    await mailTransporter.sendMail({
      from: `"SafeHer-AI SOS" <${config.smtp.user}>`,
      to,
      subject,
      html,
    });
    console.log(`[NotificationService] Email sent to ${to}`);
  } catch (err) {
    console.error(`[NotificationService] Failed to send Email to ${to}:`, err.message);
  }
};
