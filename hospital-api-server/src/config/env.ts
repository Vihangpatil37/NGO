import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

export const env = {
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: parseInt(process.env.PORT || '4000', 10),
  MONGODB_URI: process.env.MONGODB_URI || 'mongodb://localhost:27017/hospital-queue',
  CORS_ORIGIN_PATIENT: process.env.CORS_ORIGIN_PATIENT || 'http://localhost:3000',
  CORS_ORIGIN_ADMIN: process.env.CORS_ORIGIN_ADMIN || 'http://localhost:3001',
  ADMIN_JWT_SECRET: process.env.ADMIN_JWT_SECRET || 'super_secret_hospital_jwt_key',
  PATIENT_JWT_SECRET: process.env.PATIENT_JWT_SECRET || 'patient_session_secret_key_2026',
  DOCTOR_JWT_SECRET: process.env.DOCTOR_JWT_SECRET!,
  TIMEZONE: process.env.TIMEZONE || 'Asia/Kolkata',
  HOSPITAL_NAME: process.env.HOSPITAL_NAME || 'ArogyaMitra',
  ALLOW_24_7_REGISTRATION: process.env.ALLOW_24_7_REGISTRATION !== 'false'
};

// Fail fast if required secrets are missing
if (!env.DOCTOR_JWT_SECRET) {
  console.error('FATAL: DOCTOR_JWT_SECRET environment variable is required');
  process.exit(1);
}

export default env;
