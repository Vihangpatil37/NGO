import { Request, Response } from 'express';
import mongoose from 'mongoose';
import Notification from './notification.model';
import NotificationService from './notification.service';
import { sendSuccess, sendError } from '../../utils/apiResponse';
import { logger } from '../../utils/logger';

export class NotificationController {
  /**
   * Register or update FCM device token
   * POST /api/v1/notifications/device-token
   */
  public static async registerDeviceToken(req: Request, res: Response): Promise<void> {
    try {
      const { patientId, token, platform, locale } = req.body;
      if (!patientId || !token) {
        sendError(res, 'patientId and token are required', 'VALIDATION_ERROR', 400);
        return;
      }

      await NotificationService.registerDeviceToken(patientId, token, platform, locale);
      sendSuccess(res, { registered: true }, 'Device token registered successfully');
    } catch (error: any) {
      logger.error({ error }, 'registerDeviceToken error');
      sendError(res, 'Failed to register device token', 'DEVICE_TOKEN_ERROR', 500);
    }
  }

  /**
   * Get notification history / in-app inbox
   * GET /api/v1/notifications
   */
  public static async getNotifications(req: Request, res: Response): Promise<void> {
    try {
      const patientId = req.query.patientId as string;
      const limit = parseInt((req.query.limit as string) || '30', 10);
      const page = parseInt((req.query.page as string) || '1', 10);
      const skip = (page - 1) * limit;

      let query: any = {
        $or: [
          { recipientScope: { $in: ['TODAY_PATIENTS', 'ALL_ACTIVE_USERS'] } }
        ]
      };

      if (patientId && mongoose.Types.ObjectId.isValid(patientId)) {
        query.$or.push({ recipientUserId: new mongoose.Types.ObjectId(patientId) });
      }

      const notifications = await Notification.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean();

      const total = await Notification.countDocuments(query);

      sendSuccess(res, {
        notifications,
        total,
        page,
        limit
      });
    } catch (error: any) {
      logger.error({ error }, 'getNotifications error');
      sendError(res, 'Failed to fetch notifications', 'FETCH_ERROR', 500);
    }
  }

  /**
   * Get count of unread notifications
   * GET /api/v1/notifications/unread-count
   */
  public static async getUnreadCount(req: Request, res: Response): Promise<void> {
    try {
      const patientId = req.query.patientId as string;

      let query: any = {
        readAt: null,
        $or: [
          { recipientScope: { $in: ['TODAY_PATIENTS', 'ALL_ACTIVE_USERS'] } }
        ]
      };

      if (patientId && mongoose.Types.ObjectId.isValid(patientId)) {
        query.$or.push({ recipientUserId: new mongoose.Types.ObjectId(patientId) });
      }

      const count = await Notification.countDocuments(query);
      sendSuccess(res, { unreadCount: count });
    } catch (error: any) {
      logger.error({ error }, 'getUnreadCount error');
      sendError(res, 'Failed to get unread count', 'COUNT_ERROR', 500);
    }
  }

  /**
   * Mark a single notification as read
   * PATCH /api/v1/notifications/:id/read
   */
  public static async markAsRead(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const notif = await Notification.findByIdAndUpdate(
        id,
        { readAt: new Date(), 'delivery.inApp.status': 'read' },
        { new: true }
      );

      if (!notif) {
        sendError(res, 'Notification not found', 'NOT_FOUND', 404);
        return;
      }

      sendSuccess(res, { notification: notif }, 'Marked as read');
    } catch (error: any) {
      logger.error({ error }, 'markAsRead error');
      sendError(res, 'Failed to mark notification as read', 'UPDATE_ERROR', 500);
    }
  }

  /**
   * Mark all notifications as read for a patient
   * PATCH /api/v1/notifications/read-all
   */
  public static async markAllAsRead(req: Request, res: Response): Promise<void> {
    try {
      const { patientId } = req.body;
      const query: any = { readAt: null };

      if (patientId && mongoose.Types.ObjectId.isValid(patientId)) {
        query.$or = [
          { recipientUserId: new mongoose.Types.ObjectId(patientId) },
          { recipientScope: { $in: ['TODAY_PATIENTS', 'ALL_ACTIVE_USERS'] } }
        ];
      }

      await Notification.updateMany(query, {
        readAt: new Date(),
        'delivery.inApp.status': 'read'
      });

      sendSuccess(res, { updated: true }, 'All notifications marked as read');
    } catch (error: any) {
      logger.error({ error }, 'markAllAsRead error');
      sendError(res, 'Failed to mark all as read', 'UPDATE_ERROR', 500);
    }
  }

  /**
   * Admin broadcast hospital announcement (N04)
   * POST /api/admin/announcements
   */
  public static async broadcastAnnouncement(req: Request, res: Response): Promise<void> {
    try {
      const { title, message, scope, expiresAt } = req.body;
      const adminId = (req as any).admin?.userId || 'admin';

      if (!title || !message) {
        sendError(res, 'Title and message are required', 'VALIDATION_ERROR', 400);
        return;
      }

      const announcementId = `ann_${Date.now()}`;
      const io = (req as any).io;

      const notif = await NotificationService.onHospitalAnnouncement(
        io,
        announcementId,
        scope || 'TODAY_PATIENTS',
        title,
        message,
        adminId,
        expiresAt ? new Date(expiresAt) : undefined
      );

      sendSuccess(res, { announcement: notif }, 'Announcement broadcasted successfully', 201);
    } catch (error: any) {
      logger.error({ error }, 'broadcastAnnouncement error');
      sendError(res, 'Failed to broadcast announcement', 'BROADCAST_ERROR', 500);
    }
  }
}

export default NotificationController;
