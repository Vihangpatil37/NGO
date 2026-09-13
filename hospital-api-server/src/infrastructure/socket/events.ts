export const SOCKET_EVENTS = {
  // Client -> Server
  JOIN_ADMIN: 'join:admin',
  JOIN_PATIENT: 'join:patient',
  JOIN_TOKEN: 'join:token',

  // Server -> Client (Admin Room)
  REGISTRATION_CREATED: 'registration:created',
  QUEUE_NEW_TOKEN: 'queue:new-token',
  QUEUE_UPDATED: 'queue:updated',
  QUEUE_PAUSED: 'queue:paused',

  // Server -> Client (Patient Room / Global)
  TOKEN_CALLED: 'token:called',
  TOKEN_POSITION_UPDATE: 'token:position-update',
  TOKEN_COMPLETED: 'token:completed',
  TOKEN_CANCELLED: 'token:cancelled',
  TOKEN_SKIPPED: 'token:skipped',
  
  // Server -> Client (Notification)
  NOTIFICATION_NEW: 'notification:new',
  NOTIFICATION_BROADCAST: 'notification:broadcast',
  ANNOUNCEMENT_BROADCAST: 'announcement:broadcast',
  
  // Server -> Client (Patient-specific)
  TOKEN_TURN_NEAR: 'token:turn-near',
};
