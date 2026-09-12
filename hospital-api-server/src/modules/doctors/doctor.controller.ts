import { Request, Response } from 'express';
import DoctorService from './doctor.service';
import NotificationService from '../notifications/notification.service';
import { getRegistrationWindowId } from '../../middleware/validateRegistrationWindow';
import { sendSuccess, sendError } from '../../utils/apiResponse';
import { logger } from '../../utils/logger';

export class DoctorController {
  /**
   * POST /api/doctors/login
   */
  static async login(req: Request, res: Response): Promise<void> {
    try {
      const { phoneNumber, pin } = req.body;
      const result = await DoctorService.login(phoneNumber, pin);

      if (!result.success) {
        sendError(res, 'Invalid doctor credentials', 'INVALID_CREDENTIALS', 401);
        return;
      }

      sendSuccess(res, {
        token: result.token,
        doctor: result.doctor,
      }, 'Login successful');
    } catch (error) {
      logger.error({ err: error }, 'Doctor login error');
      sendError(res, 'Login failed. Please try again.', 'LOGIN_FAILED', 500);
    }
  }

  /**
   * GET /api/doctors/me
   */
  static async getProfile(req: Request | any, res: Response): Promise<void> {
    try {
      const doctor = await DoctorService.getProfile(req.doctor.doctorObjectId);

      if (!doctor) {
        sendError(res, 'Doctor not found or inactive', 'NOT_FOUND', 404);
        return;
      }

      sendSuccess(res, { doctor });
    } catch (error) {
      logger.error({ err: error }, 'Get doctor profile error');
      sendError(res, 'Could not fetch profile', 'PROFILE_ERROR', 500);
    }
  }

  /**
   * GET /api/doctors/availability
   */
  static async getAvailability(req: Request | any, res: Response): Promise<void> {
    try {
      const result = await DoctorService.getAvailability(req.doctor.doctorObjectId);
      sendSuccess(res, result);
    } catch (error) {
      logger.error({ err: error }, 'Get availability error');
      sendError(res, 'Could not fetch availability', 'AVAILABILITY_ERROR', 500);
    }
  }

  /**
   * POST /api/doctors/availability
   */
  static async submitAvailability(req: Request | any, res: Response): Promise<void> {
    try {
      const { status } = req.body;
      const result = await DoctorService.submitAvailability(
        req.doctor.doctorObjectId,
        status
      );

      // N05: Trigger DOCTOR_UNAVAILABLE if marked not_coming
      if (status === 'not_coming') {
        const windowId = getRegistrationWindowId();
        const profile = await DoctorService.getProfile(req.doctor.doctorObjectId);
        NotificationService.onDoctorUnavailable(
          (req as any).io,
          req.doctor.doctorObjectId,
          profile?.name || 'Doctor',
          windowId,
          windowId
        ).catch(err => logger.error({ err }, 'Failed to dispatch DOCTOR_UNAVAILABLE notification'));
      }

      sendSuccess(res, result, `Availability updated to ${status}`);
    } catch (error) {
      logger.error({ err: error }, 'Submit availability error');
      sendError(res, 'Could not save availability. Please try again.', 'AVAILABILITY_SAVE_ERROR', 500);
    }
  }
}

export default DoctorController;
