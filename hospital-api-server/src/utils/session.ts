import jwt from 'jsonwebtoken';
import env from '../config/env';

export const issueSessionToken = (patientId: any, tokenId: any, registrationId: any): string => {
  return jwt.sign(
    {
      patientId: patientId?.toString(),
      tokenId: tokenId?.toString(),
      registrationId: registrationId?.toString(),
    },
    env.PATIENT_JWT_SECRET,
    { expiresIn: '24h' }
  );
};
