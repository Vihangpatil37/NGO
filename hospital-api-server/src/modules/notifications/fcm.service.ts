import { logger } from '../../utils/logger';
import { initializeApp, cert, getApps } from 'firebase-admin/app';
import { getMessaging, Message, MulticastMessage } from 'firebase-admin/messaging';
import path from 'path';

// Initialize Firebase Admin SDK
try {
  if (getApps().length === 0) {
    const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
    if (serviceAccountPath) {
      const fullPath = path.resolve(process.cwd(), serviceAccountPath);
      initializeApp({
        credential: cert(fullPath)
      });
      logger.info('[FCM] Firebase Admin SDK initialized successfully');
    } else {
      logger.warn('[FCM] FIREBASE_SERVICE_ACCOUNT_PATH not set, FCM will not be initialized');
    }
  }
} catch (error) {
  logger.error({ error }, '[FCM] Failed to initialize Firebase Admin SDK');
}

export interface IFcmMessage {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
  priority?: 'normal' | 'high';
}

export class FcmService {
  /**
   * Send push notification via FCM HTTP v1 API.
   */
  public static async sendPush(msg: IFcmMessage): Promise<{ success: boolean; messageId?: string; error?: string }> {
    try {
      if (getApps().length === 0) {
        logger.warn({ title: msg.title }, '[FCM] Simulation mode (Firebase not initialized). Push would be sent.');
        return { success: true, messageId: `mock_${Date.now()}` };
      }

      const message: Message = {
        token: msg.token,
        notification: {
          title: msg.title,
          body: msg.body,
        },
        data: msg.data,
        android: {
          priority: msg.priority || 'normal',
          notification: {
            sound: 'default',
          }
        }
      };

      const response = await getMessaging().send(message);
      
      logger.info({
        fcmPush: {
          tokenPreview: msg.token.substring(0, 10) + '...',
          messageId: response
        }
      }, '[FCM] Push notification dispatched successfully');

      return {
        success: true,
        messageId: response
      };
    } catch (err: any) {
      logger.error({ err }, '[FCM] Push notification dispatch failure');
      return {
        success: false,
        error: err.message
      };
    }
  }

  /**
   * Broadcast push to multiple device tokens.
   */
  public static async sendMulticast(tokens: string[], title: string, body: string, data?: Record<string, string>) {
    if (!tokens || tokens.length === 0) return [];
    
    try {
      if (getApps().length === 0) {
        logger.warn({ title }, '[FCM] Simulation mode multicast (Firebase not initialized). Push would be sent.');
        return tokens.map(() => ({ success: true, messageId: `mock_${Date.now()}` }));
      }

      // FCM Multicast allows up to 500 tokens per batch
      const message: MulticastMessage = {
        tokens: tokens,
        notification: {
          title,
          body,
        },
        data: data,
        android: {
          priority: 'high',
          notification: {
            sound: 'default'
          }
        }
      };

      const response = await getMessaging().sendEachForMulticast(message);
      
      return response.responses.map((r: any) => ({
        success: r.success,
        messageId: r.messageId,
        error: r.error?.message
      }));
    } catch (err: any) {
      logger.error({ err }, '[FCM] Multicast dispatch failure');
      return tokens.map(() => ({ success: false, error: err.message }));
    }
  }
}

export default FcmService;
