import { Server } from 'socket.io';
import { SOCKET_EVENTS } from './events';
import { logger } from '../../utils/logger';
import { IRegistration } from '../../types';

export const notifyAdminNewRegistration = async (io: Server | any, registration: any) => {
  if (!io) return;
  try {
    if (!registration.populated('patientId')) {
      await registration.populate('patientId');
    }
    io.to('admin').emit(SOCKET_EVENTS.REGISTRATION_CREATED, { registration });
  } catch (error: any) {
    logger.error({ err: error }, 'Failed to notify admin of new registration');
  }
};
