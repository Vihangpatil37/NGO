import { Server } from 'socket.io';
import { SOCKET_EVENTS } from './events';
import { logger } from '../../utils/logger';
import { IRegistration, IQueueToken } from '../../types';

export const notifyAdminNewToken = async (io: Server | any, registration: any, token: any) => {
  if (!io) return;
  try {
    if (!registration.populated('patientId')) {
      await registration.populate('patientId');
    }
    io.to('admin').emit(SOCKET_EVENTS.REGISTRATION_CREATED, { registration });
    io.to('admin').emit(SOCKET_EVENTS.QUEUE_NEW_TOKEN, { token, registration });
    io.to('admin').emit(SOCKET_EVENTS.QUEUE_UPDATED, { tokenId: token._id, status: token.status });
  } catch (error: any) {
    logger.error({ err: error }, 'Failed to notify admin of new token');
  }
};

export const notifyTokenStatusChange = (io: Server | any, token: any, newStatus: string) => {
  if (!io) return;
  try {
    const eventName = `token:${newStatus}`;
    io.to('admin').emit(SOCKET_EVENTS.QUEUE_UPDATED, { tokenId: token._id, status: newStatus });
    const payload = { tokenNumber: token.tokenNumber, tokenId: token._id, status: newStatus };
    io.to(`patient:${token.registrationId}`).emit(eventName, payload);
    io.to(`token:${token._id}`).emit(eventName, payload);
  } catch (error: any) {
    logger.error({ err: error }, 'Failed to notify token status change');
  }
};
