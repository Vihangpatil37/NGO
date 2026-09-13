import { Server as SocketIOServer } from 'socket.io';
import { Server as HTTPServer } from 'http';
import env from '../../config/env';
import { SOCKET_EVENTS } from './events';
import { logger } from '../../utils/logger';

export const initializeSocket = (io: SocketIOServer) => {
  io.on('connection', (socket) => {
    logger.info({ socketId: socket.id }, '[Socket] Client connected');

    socket.on(SOCKET_EVENTS.JOIN_ADMIN, () => {
      socket.join('admin');
      logger.info({ socketId: socket.id }, '[Socket] Joined admin room');
    });

    socket.on(SOCKET_EVENTS.JOIN_PATIENT, (payload: { registrationId?: string; patientId?: string; tokenId?: string }) => {
      const regId = payload.registrationId ?? payload.patientId;
      if (regId) {
        socket.join(`patient:${regId}`);
        logger.info({ socketId: socket.id, room: `patient:${regId}` }, '[Socket] Joined patient room');
      }
      if (payload.tokenId) {
        socket.join(`token:${payload.tokenId}`);
        logger.info({ socketId: socket.id, room: `token:${payload.tokenId}` }, '[Socket] Joined token room');
      }
    });

    socket.on(SOCKET_EVENTS.JOIN_TOKEN, ({ tokenId }: { tokenId?: string }) => {
      if (tokenId) {
        socket.join(`token:${tokenId}`);
        logger.info({ socketId: socket.id, room: `token:${tokenId}` }, '[Socket] Joined token room');
      }
    });

    socket.on('disconnect', () => {
      logger.info({ socketId: socket.id }, '[Socket] Client disconnected');
    });
  });
};

export const setupSocketServer = (server: HTTPServer) => {
  const io = new SocketIOServer(server, {
    cors: {
      origin: [env.CORS_ORIGIN_PATIENT, env.CORS_ORIGIN_ADMIN, '*'],
      methods: ['GET', 'POST']
    }
  });

  initializeSocket(io);

  return io;
};

export default setupSocketServer;
