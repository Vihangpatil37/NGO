import { Server as SocketIOServer } from 'socket.io';
import { Server as HTTPServer } from 'http';
import env from '../../config/env';
import { SOCKET_EVENTS } from './events';

export const setupSocketServer = (server: HTTPServer) => {
  const io = new SocketIOServer(server, {
    cors: {
      origin: [env.CORS_ORIGIN_PATIENT, env.CORS_ORIGIN_ADMIN, '*'],
      methods: ['GET', 'POST']
    }
  });

  io.on('connection', (socket) => {
    console.log(`[Socket] Client connected: ${socket.id}`);

    // Staff joins admin room
    socket.on(SOCKET_EVENTS.JOIN_ADMIN, () => {
      socket.join('admin');
      console.log(`[Socket] Client ${socket.id} joined admin room`);
    });

    // Patient joins registration/token room
    socket.on(SOCKET_EVENTS.JOIN_PATIENT, ({ registrationId, tokenId }: { registrationId?: string, tokenId?: string }) => {
      if (registrationId) {
        socket.join(`patient:${registrationId}`);
        console.log(`[Socket] Client ${socket.id} joined patient:${registrationId}`);
      }
      if (tokenId) {
        socket.join(`token:${tokenId}`);
        console.log(`[Socket] Client ${socket.id} joined token:${tokenId}`);
      }
    });

    socket.on('disconnect', () => {
      console.log(`[Socket] Client disconnected: ${socket.id}`);
    });
  });

  return io;
};

export default setupSocketServer;
