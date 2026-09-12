import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import env from './config/env';
import patientRoutes from './modules/patients/patient.routes';
import staffRoutes from './modules/staff/staff.routes';
import doctorRoutes from './modules/doctors/doctor.routes';
import notificationRoutes from './modules/notifications/notification.routes';
import deviceRoutes from './modules/notifications/device.routes';
import errorHandler from './middleware/errorHandler';

export const createApp = (): Express => {
  const app = express();

  // Middleware
  app.use(
    cors({
      origin: [env.CORS_ORIGIN_PATIENT, env.CORS_ORIGIN_ADMIN, '*'],
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
      credentials: true
    })
  );

  app.use(express.json());

  // Attach io to req object for controllers
  app.use((req: Request, res: Response, next: NextFunction) => {
    (req as any).io = app.get('io');
    next();
  });

  // Healthcheck
  app.get('/health', (req: Request, res: Response) => {
    res.status(200).json({
      status: 'ok',
      hospital: env.HOSPITAL_NAME,
      timestamp: new Date().toISOString()
    });
  });

  // V1 API Routes (Target Flutter App & Clean Contract)
  app.use('/api/v1/patient', patientRoutes);

  // Staff & Admin Routes
  app.use('/api/admin', staffRoutes);

  // Doctor Routes
  app.use('/api/doctors', doctorRoutes);

  // Notification Routes (FCM, in-app inbox, read/unread, broadcasts)
  app.use('/api/v1/notifications', notificationRoutes);

  // Device Token Registration Routes (FCM endpoints matching spec)
  app.use('/api/v1/devices', deviceRoutes);

  // Backwards compatibility for existing web portals
  app.use('/api/registrations', patientRoutes);

  // 404 Handler
  app.use((req: Request, res: Response) => {
    res.status(404).json({
      success: false,
      error: {
        code: 'NOT_FOUND',
        message: `Endpoint ${req.method} ${req.originalUrl} not found`
      }
    });
  });

  // Centralized Error Handler
  app.use(errorHandler);

  return app;
};

export default createApp;
