import { Router } from 'express';
import { NotificationController } from './notification.controller';
import { adminAuth } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { registerDeviceTokenSchema, broadcastAnnouncementSchema } from './notification.schemas';

const router = Router();

// Patient-facing endpoints
router.post('/device-token', validate(registerDeviceTokenSchema), NotificationController.registerDeviceToken);
router.get('/', NotificationController.getNotifications);
router.get('/unread-count', NotificationController.getUnreadCount);
router.patch('/read-all', NotificationController.markAllAsRead);
router.patch('/:id/read', NotificationController.markAsRead);

// Admin-facing announcement broadcast endpoint
router.post('/broadcast', adminAuth, validate(broadcastAnnouncementSchema), NotificationController.broadcastAnnouncement);

export default router;
