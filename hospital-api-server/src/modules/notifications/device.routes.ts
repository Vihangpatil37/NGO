import { Router, Request, Response } from 'express';
import { NotificationController } from './notification.controller';
import NotificationService from './notification.service';
import DeviceToken from './deviceToken.model';
import { sendSuccess, sendError } from '../../utils/apiResponse';
import { logger } from '../../utils/logger';

const router = Router();

/**
 * Register FCM device token
 * POST /api/v1/devices/register
 */
router.post('/register', async (req: Request, res: Response) => {
  try {
    const patientId = req.body.patientId || req.body.userId;
    const token = req.body.fcmToken || req.body.token;
    const platform = req.body.platform || 'android';
    const locale = req.body.locale || 'en';

    if (!patientId || !token) {
      sendError(res, 'patientId and token are required', 'VALIDATION_ERROR', 400);
      return;
    }

    await NotificationService.registerDeviceToken(patientId, token, platform, locale);
    sendSuccess(res, { registered: true }, 'Device registered successfully');
  } catch (error: any) {
    logger.error({ error }, 'device register error');
    sendError(res, 'Failed to register device', 'DEVICE_ERROR', 500);
  }
});

/**
 * Refresh/Update FCM device token
 * POST /api/v1/devices/refresh
 */
router.post('/refresh', async (req: Request, res: Response) => {
  try {
    const patientId = req.body.patientId || req.body.userId;
    const oldToken = req.body.oldToken;
    const newToken = req.body.newToken || req.body.token || req.body.fcmToken;
    const platform = req.body.platform || 'android';
    const locale = req.body.locale || 'en';

    if (!patientId || !newToken) {
      sendError(res, 'patientId and newToken are required', 'VALIDATION_ERROR', 400);
      return;
    }

    // Deactivate old token if supplied
    if (oldToken && oldToken !== newToken) {
      await DeviceToken.updateOne(
        { 'tokens.token': oldToken },
        { $set: { 'tokens.$.isActive': false } }
      );
    }

    await NotificationService.registerDeviceToken(patientId, newToken, platform, locale);
    sendSuccess(res, { refreshed: true }, 'Device token refreshed successfully');
  } catch (error: any) {
    logger.error({ error }, 'device refresh error');
    sendError(res, 'Failed to refresh device token', 'DEVICE_ERROR', 500);
  }
});

/**
 * Deactivate FCM device token
 * DELETE /api/v1/devices/:token
 */
router.delete('/:token', async (req: Request, res: Response) => {
  try {
    const token = req.params.token;
    if (!token) {
      sendError(res, 'Token is required', 'VALIDATION_ERROR', 400);
      return;
    }

    await DeviceToken.updateMany(
      { 'tokens.token': token },
      { $set: { 'tokens.$.isActive': false } }
    );

    sendSuccess(res, { deleted: true }, 'Device token deactivated');
  } catch (error: any) {
    logger.error({ error }, 'device delete error');
    sendError(res, 'Failed to deactivate device token', 'DEVICE_ERROR', 500);
  }
});

export default router;
