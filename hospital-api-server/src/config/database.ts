import mongoose from 'mongoose';
import env from './env';
import { logger } from '../utils/logger';

export const connectDB = async () => {
  try {
    const conn = await mongoose.connect(env.MONGODB_URI);
    logger.info({ host: conn.connection.host }, '[MongoDB] Connected successfully');
    return conn;
  } catch (error) {
    logger.error({ err: error }, '[MongoDB] Connection error');
    process.exit(1);
  }
};

export default connectDB;
