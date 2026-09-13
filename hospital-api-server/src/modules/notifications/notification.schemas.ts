import { z } from 'zod';

export const registerDeviceTokenSchema = z.object({
  body: z.object({
    patientId: z.string().nonempty('Patient ID is required'),
    token: z.string().nonempty('FCM Token is required'),
    platform: z.enum(['ios', 'android', 'web']).optional().default('android'),
    locale: z.string().optional()
  })
});

export const broadcastAnnouncementSchema = z.object({
  body: z.object({
    title: z.string().nonempty('Title is required'),
    message: z.string().nonempty('Message is required'),
    scope: z.enum(['ALL_ACTIVE_USERS']).optional().default('ALL_ACTIVE_USERS')
  })
});
