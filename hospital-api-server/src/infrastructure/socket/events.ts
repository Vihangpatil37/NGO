export const SOCKET_EVENTS = {
  // Client -> Server
  JOIN_ADMIN: 'join:admin',
  JOIN_PATIENT: 'join:patient',

  // Server -> Client (Admin Room)
  REGISTRATION_CREATED: 'registration:created',
  QUEUE_PAUSED: 'queue:paused', // leaving this just in case

  // Server -> Client (Patient Room / Global)
  // removed token events
};
