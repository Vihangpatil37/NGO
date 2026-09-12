import http from 'http';
import createApp from './app';
import env from './config/env';
import connectDB from './config/database';
import setupSocketServer from './infrastructure/socket/socketServer';
import { logger } from './utils/logger';

const startServer = async (): Promise<void> => {
  try {
    // 1. Connect to MongoDB
    await connectDB();

    // 2. Initialize Express application
    const app = createApp();
    const server = http.createServer(app);

    // 3. Initialize Socket.IO
    const io = setupSocketServer(server);
    app.set('io', io);

    // 4. Start HTTP Server
    server.listen(env.PORT, '0.0.0.0', () => {
      logger.info(`=========================================`);
      logger.info(` Hospital Management API Server (TypeScript)`);
      logger.info(` Hospital: ${env.HOSPITAL_NAME}`);
      logger.info(` Local: http://localhost:${env.PORT}`);
      logger.info(` Wi-Fi LAN: http://192.168.1.10:${env.PORT}`);
      logger.info(` Environment: ${env.NODE_ENV}`);
      logger.info(` 24/7 Registration Testing: ${env.ALLOW_24_7_REGISTRATION}`);
      logger.info(`=========================================`);
    });
  } catch (error) {
    logger.error({ err: error }, 'Failed to start server');
    process.exit(1);
  }
};

startServer();
