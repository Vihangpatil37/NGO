import { Request, Response } from 'express';
import Patient from '../../models/Patient';
import TokenService from '../tokens/token.service';
import QueueService from '../tokens/queue.service';
import { getRegistrationWindowId } from '../../middleware/validateRegistrationWindow';
import { sendSuccess, sendError } from '../../utils/apiResponse';
import env from '../../config/env';
import { logger } from '../../utils/logger';
import { issueSessionToken } from '../../utils/session';
import { toPatientDTO } from './patient.dto';
import { notifyAdminNewToken } from '../../infrastructure/socket/notifier';
import QueueToken from '../../models/QueueToken';
import Registration from '../../models/Registration';
import NotificationService from '../notifications/notification.service';

// Utility: escape special regex characters from user input
function escapeRegex(str: string): string {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

export class PatientController {
  /**
   * Register a brand new patient and instantly issue a queue token.
   * POST /api/v1/patient/cases/new
   */
  public static async registerNewCase(req: Request, res: Response): Promise<void> {
    try {
      const { name, villageName, phoneNumber, age, preferredLanguage } = req.body;
      const windowId = getRegistrationWindowId();

      let patient = await Patient.findOne({ phoneNumber });

      if (!patient) {
        const caseNumber = await TokenService.getNextCaseNumber();
        patient = new Patient({
          caseType: 'new',
          name,
          villageName,
          phoneNumber,
          caseNumber,
          age,
          preferredLanguage: ['gu', 'hi', 'en'].includes(preferredLanguage) ? preferredLanguage : 'en'
        });
      } else {
        patient.name = name;
        patient.villageName = villageName;
        if (age !== undefined) patient.age = age;
        if (preferredLanguage && ['gu', 'hi', 'en'].includes(preferredLanguage)) { patient.preferredLanguage = preferredLanguage; }
      }
      await patient.save();

      const { token, registration } = await QueueService.findActiveToken(patient._id.toString(), windowId);

      if (token && registration) {
        const queuePosition = await QueueService.getQueuePosition(windowId, token.tokenNumber);
        const sessionToken = issueSessionToken(patient._id, token._id, registration._id);

        sendSuccess(res, {
          alreadyRegistered: true,
          tokenNumber: token.tokenNumber,
          caseNumber: patient.caseNumber,
          queuePosition,
          tokenId: token._id,
          registrationId: registration._id,
          sessionToken,
          patient: toPatientDTO(patient)
        }, 'You already have an active token for today.');
        return;
      }

      const result = await QueueService.issueToken(patient._id.toString(), windowId);
      const queuePosition = await QueueService.getQueuePosition(windowId, result.tokenNumber);
      const sessionToken = issueSessionToken(patient._id, result.token._id, result.registration._id);

      await notifyAdminNewToken((req as any).io, result.registration, result.token);

      // N01: Registration Confirmed Notification (Idempotent, DB-backed)
      NotificationService.onRegistrationConfirmed(
        (req as any).io,
        patient._id.toString(),
        result.registration._id.toString(),
        result.token._id.toString(),
        result.tokenNumber,
        windowId
      ).catch(e => logger.error({ e }, 'Failed to dispatch registration confirmed notification'));

      sendSuccess(res, {
        tokenNumber: result.tokenNumber,
        caseNumber: patient.caseNumber,
        queuePosition,
        tokenId: result.token._id,
        registrationId: result.registration._id,
        sessionToken,
        patient: toPatientDTO(patient)
      }, 'Token issued successfully.', 201);
    } catch (error: any) {
      logger.error({ err: error }, 'registerNewCase error');
      sendError(res, `Unable to register patient. Error: ${error.message}`, 'REGISTRATION_FAILED', 500);
    }
  }

  /**
   * Look up existing case for returning patients.
   * POST /api/v1/patient/cases/lookup
   */
  public static async lookupCase(req: Request, res: Response): Promise<void> {
    try {
      const { phoneNumber, caseNumber } = req.body;

      const patient = await Patient.findOne({
        phoneNumber,
        caseNumber: { $regex: new RegExp(`^${escapeRegex(caseNumber)}$`, 'i') }
      });

      if (!patient) {
        sendError(res, "We couldn't find this case. Please check your mobile number and Case ID.", 'CASE_NOT_FOUND', 404);
        return;
      }

      sendSuccess(res, { patient: toPatientDTO(patient) });
    } catch (error) {
      logger.error({ err: error }, 'lookupCase error');
      sendError(res, 'Error searching for case. Please try again.', 'LOOKUP_FAILED', 500);
    }
  }

  /**
   * Register a returning patient for today's queue and get token.
   * POST /api/v1/patient/queue/register
   */
  public static async registerOldCase(req: Request, res: Response): Promise<void> {
    try {
      const { phoneNumber, caseNumber, preferredLanguage } = req.body;

      const patient = await Patient.findOne({
        phoneNumber,
        caseNumber: { $regex: new RegExp(`^${escapeRegex(caseNumber)}$`, 'i') }
      });

      if (!patient) {
        sendError(res, "We couldn't find this case. Please check your mobile number and Case ID.", 'CASE_NOT_FOUND', 404);
        return;
      }

      if (preferredLanguage && ['gu', 'hi', 'en'].includes(preferredLanguage)) {
        patient.preferredLanguage = preferredLanguage;
        await patient.save();
      }

      const windowId = getRegistrationWindowId();
      const { token, registration } = await QueueService.findActiveToken(patient._id.toString(), windowId);

      if (token && registration) {
        const queuePosition = await QueueService.getQueuePosition(windowId, token.tokenNumber);
        const sessionToken = issueSessionToken(patient._id, token._id, registration._id);

        sendSuccess(res, {
          alreadyRegistered: true,
          tokenNumber: token.tokenNumber,
          caseNumber: patient.caseNumber,
          queuePosition,
          tokenId: token._id,
          registrationId: registration._id,
          sessionToken,
          patient: toPatientDTO(patient)
        }, 'You already have an active token for today.');
        return;
      }

      const result = await QueueService.issueToken(patient._id.toString(), windowId);
      const queuePosition = await QueueService.getQueuePosition(windowId, result.tokenNumber);
      const sessionToken = issueSessionToken(patient._id, result.token._id, result.registration._id);

      await notifyAdminNewToken((req as any).io, result.registration, result.token);

      // N01: Registration Confirmed Notification (Idempotent, DB-backed)
      NotificationService.onRegistrationConfirmed(
        (req as any).io,
        patient._id.toString(),
        result.registration._id.toString(),
        result.token._id.toString(),
        result.tokenNumber,
        windowId
      ).catch(e => logger.error({ e }, 'Failed to dispatch registration confirmed notification'));

      sendSuccess(res, {
        tokenNumber: result.tokenNumber,
        caseNumber: patient.caseNumber,
        queuePosition,
        tokenId: result.token._id,
        registrationId: result.registration._id,
        sessionToken,
        patient: toPatientDTO(patient)
      }, 'Token issued successfully.', 201);
    } catch (error) {
      logger.error({ err: error }, 'registerOldCase error');
      sendError(res, 'Unable to register case. Please try again.', 'REGISTRATION_FAILED', 500);
    }
  }

  /**
   * Get current token status and queue progress for the active patient.
   * GET /api/v1/patient/token
   */
  public static async getTokenStatus(req: Request, res: Response): Promise<void> {
    try {
      const tokenId = req.query.tokenId as string;
      const phoneNumber = req.query.phoneNumber as string;
      const windowId = getRegistrationWindowId();

      let token = null;

      if (tokenId) {
        token = await QueueToken.findById(tokenId).populate({
          path: 'registrationId',
          populate: { path: 'patientId' }
        });
      } else if (phoneNumber) {
        const patient = await Patient.findOne({ phoneNumber: phoneNumber.trim() });
        if (patient) {
          const reg = await Registration.findOne({ patientId: patient._id, registrationWindowId: windowId });
          if (reg) {
            token = await QueueToken.findOne({ registrationId: reg._id }).populate({
              path: 'registrationId',
              populate: { path: 'patientId' }
            });
          }
        }
      }

      if (!token) {
        sendError(res, 'No active token found for today.', 'TOKEN_NOT_FOUND', 404);
        return;
      }

      const queuePosition = await QueueService.getQueuePosition(token.registrationWindowId, token.tokenNumber);

      const currentServingToken = await QueueToken.findOne({
        registrationWindowId: token.registrationWindowId,
        status: { $in: ['called', 'in_consultation'] }
      }).sort({ tokenNumber: -1 });

      const reg = token.registrationId as any;
      const patient = reg?.patientId;

      sendSuccess(res, {
        token: {
          _id: token._id,
          tokenNumber: token.tokenNumber,
          status: token.status,
          calledAt: token.calledAt,
          completedAt: token.completedAt,
          createdAt: token.createdAt
        },
        queuePosition,
        currentlyServing: currentServingToken ? currentServingToken.tokenNumber : null,
        patient: patient ? toPatientDTO(patient) : null
      });
    } catch (error) {
      logger.error({ err: error }, 'getTokenStatus error');
      sendError(res, 'Could not retrieve token status.', 'GET_TOKEN_FAILED', 500);
    }
  }

  /**
   * Get public hospital queue status.
   * GET /api/v1/patient/queue/status
   */
  public static async getHospitalQueueStatus(req: Request, res: Response): Promise<void> {
    try {
      const windowId = getRegistrationWindowId();

      const totalWaiting = await QueueToken.countDocuments({
        registrationWindowId: windowId,
        status: 'active'
      });

      const currentlyServingToken = await QueueToken.findOne({
        registrationWindowId: windowId,
        status: { $in: ['called', 'in_consultation'] }
      }).sort({ tokenNumber: -1 });

      sendSuccess(res, {
        hospitalName: env.HOSPITAL_NAME,
        windowId,
        totalWaiting,
        currentlyServing: currentlyServingToken ? currentlyServingToken.tokenNumber : null,
        isOpen: true
      });
    } catch (error) {
      logger.error({ err: error }, 'getHospitalQueueStatus error');
      sendError(res, 'Error fetching queue status', 'STATUS_ERROR', 500);
    }
  }

  public static async updateLanguage(req: Request, res: Response): Promise<void> {
    try {
      const { patientId, preferredLanguage } = req.body;
      if (!patientId || !['gu', 'hi', 'en'].includes(preferredLanguage)) {
        sendError(res, 'Valid patientId and preferredLanguage (gu/hi/en) required', 'VALIDATION_ERROR', 400);
        return;
      }
      const patient = await Patient.findByIdAndUpdate(patientId, { preferredLanguage }, { new: true });
      if (!patient) { sendError(res, 'Patient not found', 'NOT_FOUND', 404); return; }
      const DeviceToken = (await import('../notifications/deviceToken.model')).default;
      await DeviceToken.updateOne({ userId: patient._id }, { $set: { locale: preferredLanguage } });
      sendSuccess(res, { preferredLanguage: patient.preferredLanguage }, 'Language updated');
    } catch (error) {
      sendError(res, 'Failed to update language', 'UPDATE_FAILED', 500);
    }
  }
}

export default PatientController;
