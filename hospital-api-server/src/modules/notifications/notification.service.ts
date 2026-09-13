import mongoose from 'mongoose';
import Notification, { INotificationDocument } from './notification.model';
import DeviceToken from './deviceToken.model';
import {
  NotificationType,
  NotificationPriority,
  RecipientScope,
  INotificationPayload
} from './notification.types';
import { renderNotificationTemplate } from './notification.templates';
import FcmService from './fcm.service';
import { logger } from '../../utils/logger';
import { SOCKET_EVENTS } from '../../infrastructure/socket/events';
import QueueToken from '../../models/QueueToken';
import Registration from '../../models/Registration';
import Patient from '../../models/Patient';

export class NotificationService {
  /**
   * Register or update an FCM device token for a patient.
   */
  public static async registerDeviceToken(
    patientId: string,
    token: string,
    platform: 'android' | 'ios' | 'web' = 'android',
    locale: string = 'en'
  ): Promise<void> {
    try {
      const userObjectId = new mongoose.Types.ObjectId(patientId);
      let record = await DeviceToken.findOne({ userId: userObjectId });

      if (!record) {
        record = new DeviceToken({
          userId: userObjectId,
          tokens: [{ token, platform, lastSeenAt: new Date(), isActive: true }],
          locale
        });
      } else {
        const existingTokenIdx = record.tokens.findIndex(t => t.token === token);
        if (existingTokenIdx >= 0) {
          record.tokens[existingTokenIdx].lastSeenAt = new Date();
          record.tokens[existingTokenIdx].isActive = true;
        } else {
          record.tokens.push({ token, platform, lastSeenAt: new Date(), isActive: true });
        }
        if (locale) record.locale = locale;
      }

      await record.save();
      logger.info({ patientId, tokenPreview: token.substring(0, 10) }, '[NotificationService] Device token registered');
    } catch (err) {
      logger.error({ err }, '[NotificationService] Error registering device token');
    }
  }

  /**
   * Dispatches a notification synchronously storing it in DB, then queuing FCM & Socket.IO.
   * Enforces strict idempotency via unique eventKey.
   */
  public static async dispatch(io: any, payload: INotificationPayload): Promise<INotificationDocument | null> {
    try {
      // 1. Idempotency check: see if event already recorded
      const existing = await Notification.findOne({ eventKey: payload.eventKey });
      if (existing) {
        logger.warn({ eventKey: payload.eventKey }, '[NotificationService] Duplicate event skipped by idempotency check');
        return existing;
      }

      // 2. Resolve preferred locale
      let locale = payload.locale;
      let deviceTokens: string[] = [];
      if (payload.recipientUserId) {
        if (!locale) {
          const patient = await Patient.findById(payload.recipientUserId).select('preferredLanguage').lean();
          if (patient?.preferredLanguage && ['gu', 'hi', 'en'].includes(patient.preferredLanguage)) {
            locale = patient.preferredLanguage;
          }
        }
        const dt = await DeviceToken.findOne({ userId: new mongoose.Types.ObjectId(payload.recipientUserId) });
        if (dt) {
          if (!locale) locale = dt.locale;
          deviceTokens = dt.tokens.filter(t => t.isActive).map(t => t.token);
        }
      }
      if (!locale) locale = 'en';

      // 3. Render localized templates
      const { title, body } = renderNotificationTemplate(payload.type, locale, payload.variables || {});

      // 4. Store notification record in Database (Source of truth & In-app Inbox)
      const doc = new Notification({
        type: payload.type,
        recipientUserId: payload.recipientUserId ? new mongoose.Types.ObjectId(payload.recipientUserId) : undefined,
        recipientScope: payload.recipientScope || 'USER',
        titleKey: payload.titleKey,
        bodyKey: payload.bodyKey,
        variables: payload.variables || {},
        renderedTitle: title,
        renderedBody: body,
        locale,
        priority: payload.priority || 'normal',
        relatedEntities: {
          tokenId: payload.relatedEntities?.tokenId ? new mongoose.Types.ObjectId(payload.relatedEntities.tokenId) : undefined,
          tokenNumber: payload.relatedEntities?.tokenNumber,
          registrationId: payload.relatedEntities?.registrationId ? new mongoose.Types.ObjectId(payload.relatedEntities.registrationId) : undefined,
          doctorId: payload.relatedEntities?.doctorId ? new mongoose.Types.ObjectId(payload.relatedEntities.doctorId) : undefined,
          doctorName: payload.relatedEntities?.doctorName,
          registrationWindowId: payload.relatedEntities?.registrationWindowId,
          patientsAhead: payload.relatedEntities?.patientsAhead
        },
        eventKey: payload.eventKey,
        createdBy: payload.createdBy || 'system',
        expiresAt: payload.expiresAt || null,
        delivery: {
          push: { status: deviceTokens.length > 0 ? 'sending' : 'pending', attempts: 0 },
          socket: { status: 'sending' },
          inApp: { status: 'stored' }
        }
      });

      await doc.save();

      // 5. Asynchronous Delivery: Socket.IO
      if (io) {
        try {
          if (payload.recipientUserId) {
            // Patient personalized room
            io.to(`patient:${payload.recipientUserId}`).emit(SOCKET_EVENTS.NOTIFICATION_NEW, {
              _id: doc._id,
              type: doc.type,
              title,
              body,
              priority: doc.priority,
              createdAt: doc.createdAt,
              relatedEntities: doc.relatedEntities
            });
          }
          if (payload.relatedEntities?.tokenId) {
            // Emit to token room if applicable
            io.to(`token:${payload.relatedEntities.tokenId}`).emit(SOCKET_EVENTS.NOTIFICATION_NEW, {
              _id: doc._id,
              type: doc.type,
              title,
              body,
              priority: doc.priority,
              createdAt: doc.createdAt,
              relatedEntities: doc.relatedEntities
            });
          }
          if (payload.recipientScope === 'TODAY_PATIENTS' || payload.recipientScope === 'ALL_ACTIVE_USERS') {
            io.emit(SOCKET_EVENTS.NOTIFICATION_BROADCAST, {
              _id: doc._id,
              type: doc.type,
              title,
              body,
              priority: doc.priority,
              createdAt: doc.createdAt
            });
          }
          doc.delivery.socket.status = 'delivered';
        } catch (socketErr) {
          logger.error({ socketErr }, '[NotificationService] Socket emission error');
          doc.delivery.socket.status = 'failed';
        }
      }

      // 6. Asynchronous Delivery: FCM Push
      if (deviceTokens.length > 0) {
        doc.delivery.push.attempts += 1;
        doc.delivery.push.lastAttemptAt = new Date();

        const fcmRes = await FcmService.sendMulticast(
          deviceTokens,
          title,
          body,
          {
            type: doc.type,
            notificationId: doc._id.toString(),
            tokenId: payload.relatedEntities?.tokenId || '',
            tokenNumber: String(payload.relatedEntities?.tokenNumber || '')
          }
        );

        const allOk = fcmRes.every((r: any) => r.success);
        doc.delivery.push.status = allOk ? 'provider_accepted' : 'failed';
      }

      await doc.save();
      return doc;
    } catch (err: any) {
      if (err.code === 11000) {
        logger.warn({ eventKey: payload.eventKey }, '[NotificationService] Idempotency duplicate intercepted by MongoDB index');
        return Notification.findOne({ eventKey: payload.eventKey });
      }
      logger.error({ err }, '[NotificationService] Error creating notification');
      return null;
    }
  }

  // --- N01: Registration Confirmed ---
  public static async onRegistrationConfirmed(
    io: any,
    patientId: string,
    registrationId: string,
    tokenId: string,
    tokenNumber: number,
    registrationWindowId: string
  ) {
    const eventKey = `REGISTRATION_CONFIRMED:${registrationId}`;
    return NotificationService.dispatch(io, {
      type: 'REGISTRATION_CONFIRMED',
      recipientUserId: patientId,
      recipientScope: 'USER',
      eventKey,
      titleKey: 'notifications.registrationConfirmed.title',
      bodyKey: 'notifications.registrationConfirmed.body',
      variables: { tokenNumber },
      priority: 'normal',
      relatedEntities: {
        registrationId,
        tokenId,
        tokenNumber,
        registrationWindowId
      }
    });
  }

  // --- N02: Turn Near ---
  public static async evaluateTurnNearForQueue(io: any, windowId: string, currentCalledTokenNumber: number, threshold: number = 3) {
    try {
      // Find active tokens in queue ahead of current called
      const candidateTokens = await QueueToken.find({
        registrationWindowId: windowId,
        status: 'active',
        tokenNumber: { $gt: currentCalledTokenNumber }
      }).sort({ tokenNumber: 1 }).limit(threshold);

      for (const t of candidateTokens) {
        // Calculate exact patients ahead
        const patientsAhead = await QueueToken.countDocuments({
          registrationWindowId: windowId,
          status: 'active',
          tokenNumber: { $lt: t.tokenNumber }
        });

        if (patientsAhead <= threshold && patientsAhead > 0) {
          const eventKey = `TURN_NEAR:${t._id}`;
          // Check if already dispatched
          const exists = await Notification.findOne({ eventKey });
          if (!exists && t.patientId) {
            await NotificationService.dispatch(io, {
              type: 'TURN_NEAR',
              recipientUserId: t.patientId.toString(),
              recipientScope: 'USER',
              eventKey,
              titleKey: 'notifications.turnNear.title',
              bodyKey: 'notifications.turnNear.body',
              variables: { tokenNumber: t.tokenNumber, patientsAhead },
              priority: 'high',
              relatedEntities: {
                tokenId: t._id.toString(),
                tokenNumber: t.tokenNumber,
                registrationWindowId: windowId,
                patientsAhead
              }
            });
          }
        }
      }
    } catch (err) {
      logger.error({ err }, '[NotificationService] Error evaluating Turn Near notifications');
    }
  }

  // --- N03: Token Called ---
  public static async onTokenCalled(
    io: any,
    patientId: string,
    tokenId: string,
    tokenNumber: number,
    registrationWindowId: string,
    room: string = 'Doctor Room 1'
  ) {
    const eventKey = `TOKEN_CALLED:${tokenId}`;
    const notif = await NotificationService.dispatch(io, {
      type: 'TOKEN_CALLED',
      recipientUserId: patientId,
      recipientScope: 'USER',
      eventKey,
      titleKey: 'notifications.tokenCalled.title',
      bodyKey: 'notifications.tokenCalled.body',
      variables: { tokenNumber, room },
      priority: 'urgent',
      relatedEntities: {
        tokenId,
        tokenNumber,
        registrationWindowId
      }
    });

    // Check Turn Near for upcoming patients in queue
    await NotificationService.evaluateTurnNearForQueue(io, registrationWindowId, tokenNumber);
    return notif;
  }

  // --- N04: Hospital Announcement ---
  public static async onHospitalAnnouncement(
    io: any,
    announcementId: string,
    scope: RecipientScope,
    title: string,
    message: string,
    adminId: string,
    expiresAt?: Date
  ) {
    const eventKey = `HOSPITAL_ANNOUNCEMENT:${announcementId}`;
    return NotificationService.dispatch(io, {
      type: 'HOSPITAL_ANNOUNCEMENT',
      recipientScope: scope,
      eventKey,
      titleKey: 'notifications.announcement.title',
      bodyKey: 'notifications.announcement.body',
      variables: { title, message },
      priority: 'high',
      createdBy: adminId,
      expiresAt
    });
  }

  // --- N05: Doctor Unavailable ---
  public static async onDoctorUnavailable(
    io: any,
    doctorId: string,
    doctorName: string,
    date: string,
    registrationWindowId: string
  ) {
    try {
      // Find affected active registrations for today's OPD
      const activeTokens = await QueueToken.find({
        registrationWindowId,
        status: { $in: ['active', 'called'] }
      }).populate('patientId');

      for (const t of activeTokens) {
        if (!t.patientId) continue;
        const patientId = (t.patientId as any)._id?.toString() || t.patientId.toString();
        const eventKey = `DOCTOR_UNAVAILABLE:${doctorId}:${date}:${t._id}`;

        await NotificationService.dispatch(io, {
          type: 'DOCTOR_UNAVAILABLE',
          recipientUserId: patientId,
          recipientScope: 'USER',
          eventKey,
          titleKey: 'notifications.doctorUnavailable.title',
          bodyKey: 'notifications.doctorUnavailable.body',
          variables: { doctorName, date },
          priority: 'high',
          relatedEntities: {
            doctorId,
            doctorName,
            tokenId: t._id.toString(),
            tokenNumber: t.tokenNumber,
            registrationWindowId
          }
        });
      }
    } catch (err) {
      logger.error({ err }, '[NotificationService] Error notifying doctor unavailability');
    }
  }

  // --- N06: OPD Closed ---
  public static async onOpdClosed(
    io: any,
    registrationWindowId: string,
    reason: string = 'OPD session concluded',
    adminId: string
  ) {
    const eventKey = `OPD_CLOSED:${registrationWindowId}`;
    return NotificationService.dispatch(io, {
      type: 'OPD_CLOSED',
      recipientScope: 'TODAY_PATIENTS',
      eventKey,
      titleKey: 'notifications.opdClosed.title',
      bodyKey: 'notifications.opdClosed.body',
      variables: { reason },
      priority: 'urgent',
      createdBy: adminId,
      relatedEntities: {
        registrationWindowId
      }
    });
  }
}

export default NotificationService;
