import { Router } from 'express';
import { NotificationController } from './notification.controller';
import { adminAuth } from '../../middleware/auth';

const router = Router();

// Patient-facing endpoints
router.post('/device-token', NotificationController.registerDeviceToken);
router.get('/', NotificationController.getNotifications);
router.get('/unread-count', NotificationController.getUnreadCount);
router.patch('/:id/read', NotificationController.markAsRead);
router.patch('/read-all', NotificationController.markAllAsRead);

// Admin-facing announcement broadcast endpoint
router.post('/broadcast', adminAuth, NotificationController.broadcastAnnouncement);
router.post('/announcements', adminAuth, NotificationController.broadcastAnnouncement);

export default router;
