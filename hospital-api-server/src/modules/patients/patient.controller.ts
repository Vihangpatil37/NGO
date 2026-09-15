import { Request, Response } from 'express';
import Patient from '../../models/Patient';
import { getRegistrationWindowId } from '../../middleware/validateRegistrationWindow';
import { sendSuccess, sendError } from '../../utils/apiResponse';
import env from '../../config/env';
import { logger } from '../../utils/logger';
import { issueSessionToken } from '../../utils/session';
import { toPatientDTO } from './patient.dto';
import Registration from '../../models/Registration';
import NotificationService from '../notifications/notification.service';
import { notifyAdminNewRegistration } from '../../infrastructure/socket/notifier';

export class PatientController {
  /**
   * Register a brand new patient and create a registration.
   * POST /api/v1/patient/cases/new
   */
  public static async registerNewCase(req: Request, res: Response): Promise<void> {
    try {
      const { name, villageName, phoneNumber, age, preferredLanguage } = req.body;
      const windowId = getRegistrationWindowId();

      let patient = await Patient.findOne({ phoneNumber });

      if (!patient) {
        // Mock case number generation since TokenService is gone.
        const counter = await (await import('../../models/Counter')).default.findOneAndUpdate(
          { key: 'caseNumber' },
          { $inc: { sequence: 1 } },
          { new: true, upsert: true }
        );
        const caseNumber = `CASE-${counter.sequence}`;

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

      let registration = await Registration.findOne({ patientId: patient._id, registrationWindowId: windowId });
      let alreadyRegistered = false;

      if (!registration) {
        registration = new Registration({
          patientId: patient._id,
          caseType: 'new',
          registrationWindowId: windowId,
          status: 'registered'
        });
        await registration.save();
        await notifyAdminNewRegistration((req as any).io, registration);
      } else {
        alreadyRegistered = true;
      }

      const sessionToken = issueSessionToken(patient._id, registration._id);

      sendSuccess(res, {
        alreadyRegistered,
        caseNumber: patient.caseNumber,
        registrationId: registration._id,
        sessionToken,
        patient: toPatientDTO(patient)
      }, alreadyRegistered ? 'You already have an active registration for today.' : 'Registration successful.', 201);
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
        caseNumber: { $regex: new RegExp(`^${caseNumber}$`, 'i') }
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
   * Register a returning patient for today.
   * POST /api/v1/patient/queue/register
   */
  public static async registerOldCase(req: Request, res: Response): Promise<void> {
    try {
      const { phoneNumber, caseNumber, preferredLanguage } = req.body;

      let patient = await Patient.findOne({
        phoneNumber,
        caseNumber: { $regex: new RegExp(`^${caseNumber}$`, 'i') }
      });

      if (!patient) {
        // Collect info even if not in DB, and create patient
        patient = new Patient({
          caseType: 'old',
          phoneNumber,
          caseNumber: caseNumber.toUpperCase(),
          preferredLanguage: ['gu', 'hi', 'en'].includes(preferredLanguage) ? preferredLanguage : 'en'
        });
        await patient.save();
      } else if (preferredLanguage && ['gu', 'hi', 'en'].includes(preferredLanguage)) {
        patient.preferredLanguage = preferredLanguage;
        await patient.save();
      }

      const windowId = getRegistrationWindowId();
      
      let registration = await Registration.findOne({ patientId: patient._id, registrationWindowId: windowId });
      let alreadyRegistered = false;

      if (!registration) {
        registration = new Registration({
          patientId: patient._id,
          caseType: 'old',
          registrationWindowId: windowId,
          status: 'registered'
        });
        await registration.save();
        await notifyAdminNewRegistration((req as any).io, registration);
      } else {
        alreadyRegistered = true;
      }

      const sessionToken = issueSessionToken(patient._id, registration._id);

      sendSuccess(res, {
        alreadyRegistered,
        caseNumber: patient.caseNumber,
        registrationId: registration._id,
        sessionToken,
        patient: toPatientDTO(patient)
      }, alreadyRegistered ? 'You already have an active registration for today.' : 'Registration successful.', 201);
    } catch (error) {
      logger.error({ err: error }, 'registerOldCase error');
      sendError(res, 'Unable to register case. Please try again.', 'REGISTRATION_FAILED', 500);
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
