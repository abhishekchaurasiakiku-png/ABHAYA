const jwt = require('jsonwebtoken');

/**
 * WebSocket service for live location streaming during active SOS.
 * 
 * Architecture:
 * - Each active SOS creates a "room" identified by incidentId
 * - The user's device streams location updates to the room
 * - Guardians can join the room via a secure link to watch live
 * 
 * Message types:
 * - location_update: User sends GPS coordinates
 * - heartbeat: Keep-alive ping
 * - join_room: Guardian joins a tracking room
 * - leave_room: Guardian leaves a tracking room
 */

// Active rooms: Map<incidentId, Set<WebSocket>>
const rooms = new Map();

/**
 * Initialize WebSocket server handlers.
 */
function initializeWebSocket(wss) {
  wss.on('connection', (ws, req) => {
    // Use WHATWG URL API instead of deprecated url.parse()
    const parsedUrl = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
    const incidentId = parsedUrl.searchParams.get('incidentId');
    const token = parsedUrl.searchParams.get('token');

    // Authenticate
    let userId;
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      userId = decoded.userId;
    } catch (err) {
      ws.send(JSON.stringify({ type: 'error', message: 'Authentication failed' }));
      ws.close();
      return;
    }

    // Join room
    if (incidentId) {
      if (!rooms.has(incidentId)) {
        rooms.set(incidentId, new Set());
      }
      rooms.get(incidentId).add(ws);
      ws._incidentId = incidentId;
      ws._userId = userId;

      console.log(`[WS] User ${userId} joined room ${incidentId} (${rooms.get(incidentId).size} clients)`);

      ws.send(JSON.stringify({
        type: 'connected',
        incidentId,
        message: 'Live tracking active',
      }));
    }

    // Handle messages
    ws.on('message', (data) => {
      try {
        const message = JSON.parse(data.toString());

        switch (message.type) {
          case 'location_update':
            // Broadcast location to all clients in the room
            broadcastToRoom(ws._incidentId, {
              type: 'location_update',
              userId: ws._userId,
              data: message.data,
            }, ws);
            break;

          case 'heartbeat':
            ws.send(JSON.stringify({
              type: 'heartbeat_ack',
              timestamp: new Date().toISOString(),
            }));
            break;

          default:
            console.log(`[WS] Unknown message type: ${message.type}`);
        }
      } catch (err) {
        console.error('[WS] Message parse error:', err.message);
      }
    });

    // Handle disconnect
    ws.on('close', () => {
      if (ws._incidentId && rooms.has(ws._incidentId)) {
        rooms.get(ws._incidentId).delete(ws);
        if (rooms.get(ws._incidentId).size === 0) {
          rooms.delete(ws._incidentId);
        }
        console.log(`[WS] User ${ws._userId} left room ${ws._incidentId}`);
      }
    });

    ws.on('error', (err) => {
      console.error(`[WS] Error for user ${ws._userId}:`, err.message);
    });
  });

  console.log('✅ WebSocket service initialized');
}

/**
 * Broadcast a message to all clients in a room except the sender.
 */
function broadcastToRoom(incidentId, message, excludeWs) {
  if (!rooms.has(incidentId)) return;

  const payload = JSON.stringify(message);
  for (const client of rooms.get(incidentId)) {
    if (client !== excludeWs && client.readyState === 1) { // WebSocket.OPEN
      client.send(payload);
    }
  }
}

/**
 * Close a room (when SOS is resolved).
 */
function closeRoom(incidentId) {
  if (!rooms.has(incidentId)) return;

  const closeMessage = JSON.stringify({
    type: 'room_closed',
    incidentId,
    message: 'SOS has been resolved',
  });

  for (const client of rooms.get(incidentId)) {
    client.send(closeMessage);
    client.close();
  }

  rooms.delete(incidentId);
  console.log(`[WS] Room ${incidentId} closed`);
}

module.exports = { initializeWebSocket, broadcastToRoom, closeRoom };
