import jwt from 'jsonwebtoken';
import env from '../config/env';

export const issueSessionToken = (patientId: any, registrationId: any): string => {
  return jwt.sign(
    {
      patientId: patientId?.toString(),
      registrationId: registrationId?.toString(),
    },
    env.PATIENT_JWT_SECRET,
    { expiresIn: '24h' }
  );
};
