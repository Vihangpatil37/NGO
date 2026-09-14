import { Request, Response } from 'express';
import { getAuth } from 'firebase-admin/auth';
import { sendSuccess, sendError } from '../../utils/apiResponse';
import { logger } from '../../utils/logger';
import Patient from '../../models/Patient';
import { issueSessionToken } from '../../utils/session';
import TokenService from '../tokens/token.service';
import { toPatientDTO } from './patient.dto';

export class PatientAuthController {
  public static async verifyFirebaseToken(req: Request, res: Response): Promise<void> {
    try {
      const { firebaseIdToken } = req.body;

      if (!firebaseIdToken) {
        sendError(res, 'Firebase ID token is required', 'BAD_REQUEST', 400);
        return;
      }

      // Verify token
      const decodedToken = await getAuth().verifyIdToken(firebaseIdToken);
      const phoneNumber = decodedToken.phone_number;

      if (!phoneNumber) {
        sendError(res, 'Phone number not found in Firebase token', 'UNAUTHORIZED', 401);
        return;
      }

      let patient = await Patient.findOne({ phoneNumber });
      let isNewPatient = false;

      if (!patient) {
        const caseNumber = await TokenService.getNextCaseNumber();
        patient = await Patient.create({
          phoneNumber,
          caseNumber,
          name: 'Unknown',
          villageName: 'Unknown',
          caseType: 'new'
        });
        isNewPatient = true;
      }

      const sessionToken = issueSessionToken(patient._id, null, null);

      sendSuccess(res, {
        sessionToken,
        patient: toPatientDTO(patient),
        isNewPatient
      }, 'Authentication successful');
    } catch (error: any) {
      logger.error({ err: error }, 'verifyFirebaseToken error');
      sendError(res, `Authentication failed. Error: ${error.message}`, 'UNAUTHORIZED', 401);
    }
  }
}

export default PatientAuthController;
