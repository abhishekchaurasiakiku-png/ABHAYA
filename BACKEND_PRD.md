# Backend Product Requirements & Logic Document: ABHAYA

This document details the backend logic, architecture, and workflows for the ABHAYA women's safety platform. The backend is designed to handle high-stress, real-time emergency events with maximum reliability.

## 1. Architecture & Tech Stack
- **Runtime Environment:** Node.js with Express.js
- **Database:** MongoDB (Chosen specifically for its robust `$near` and `$geoWithin` geospatial query capabilities, essential for the Guardian Network).
- **Real-Time Communication:** Socket.io (WebSockets) for live location streaming and instant Guardian notifications.
- **Authentication:** JWT (JSON Web Tokens) for API security.
- **External Integrations:**
  - **Twilio / SMS Gateway:** To handle offline SMS fallbacks and notify contacts.
  - **AWS S3 / Cloud Storage:** For secure, write-once evidence storage (audio/video).

## 2. Core Database Schema & Entities

### 2.1 User (`users` collection)
Stores profile data, trust settings, and emergency contacts.
- `_id`: Unique identifier
- `phone`: Primary identifier (verified via OTP)
- `role`: `STANDARD` or `GUARDIAN`
- `emergency_contacts`: Array of objects (name, phone, relation)
- `trust_level`: Enum (`CONTACTS_ONLY`, `CONTACTS_AND_GUARDIANS`)
- `is_verified_guardian`: Boolean (True if background check passed)

### 2.2 Alert / Incident (`alerts` collection)
The core record of an emergency.
- `_id`: Unique identifier
- `user_id`: Reference to the User who triggered the SOS
- `status`: Enum (`ACTIVE`, `RESOLVED`, `FALSE_ALARM`)
- `severity`: Enum (`LOW`, `HIGH`, `CRITICAL`)
- `location_history`: Array of GeoJSON points (longitude, latitude, timestamp)
- `dispatched_guardians`: Array of User IDs (Guardians who were notified)
- `evidence_links`: Array of secure URLs pointing to uploaded media

### 2.3 Guardian Location Cache (Redis or In-Memory)
To rapidly find nearby help, active Guardians' locations are cached and updated frequently.
- Key: `guardian:{user_id}`
- Value: Geo-coordinates & timestamp.

## 3. Core Backend Logic & Workflows

### 3.1 The SOS Trigger Flow (How it Works)
1. **Trigger:** The user's app sends an HTTP POST to `/api/v1/alerts/trigger` with their current location and battery status.
2. **Record Creation:** The backend creates an `ACTIVE` Alert in the database.
3. **Contact Notification:** The backend retrieves the user's `emergency_contacts` and dispatches SMS/Push notifications containing a secure tracking link.
4. **Proximity Matching (Guardian Network):** 
   - If the user's `trust_level` allows Guardians, the backend executes a geospatial query (e.g., `db.users.find({ location: { $near: ... } })`) to find verified Guardians within a 500m radius.
   - The backend ranks them by distance and dispatches Push Notifications to those Guardians.
5. **Real-time Connection:** The user's app connects to a WebSocket room (e.g., `room_alert_{alert_id}`) to begin streaming live location points. Notified Guardians can join this room to see live updates.

### 3.2 Offline Fallback Logic (SMS/USSD)
If a user has no internet, the mobile app sends a formatted SMS to a centralized server number (e.g., via Twilio).
1. **Webhook:** Twilio receives the SMS and sends an HTTP POST webhook to our backend (e.g., `/api/v1/webhooks/sms`).
2. **Parsing:** The backend parses the sender's phone number and the SMS body (which contains encrypted or raw GPS coordinates).
3. **Lookup & Execution:** The backend looks up the user by phone number and triggers the exact same **SOS Trigger Flow** (3.1) as if it came from the internet, ensuring Contacts and nearby Guardians are still notified.

### 3.3 Evidence Capture & Hashing
1. **Upload:** When the app records audio/video, it requests a short-lived Pre-Signed URL from the backend.
2. **Storage:** The app uploads the file directly to Cloud Storage using the URL.
3. **Immutability:** The backend computes a SHA-256 hash of the uploaded file and stores it in the `Alert` record. If the file is ever tampered with, the hash will not match, ensuring chain-of-custody for legal proceedings.

### 3.4 False Alarm / Resolution Flow
1. **Cancellation:** The user enters their secure PIN on the app to cancel the SOS.
2. **Cleanup:** The backend updates the Alert status to `FALSE_ALARM` or `RESOLVED`.
3. **Stand Down Notification:** The backend broadcasts a "Stand Down" WebSocket event and sends SMS/Push updates to all dispatched Guardians and contacts, preventing unnecessary panic and alert fatigue.

## 4. API Endpoints Outline
- `POST /auth/register` & `/auth/login`
- `POST /alerts/trigger` - Initiate an SOS.
- `POST /alerts/:id/resolve` - Cancel or resolve an SOS.
- `GET /alerts/:id` - Fetch alert details (for Guardians/Contacts).
- `POST /users/location` - Background location update for active Guardians.
- `POST /webhooks/sms` - Entry point for offline fallback messages.
