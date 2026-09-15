import mongoose, { Schema, Document, Types } from 'mongoose';
import { NotificationType, NotificationPriority, RecipientScope, DeliveryStatus } from './notification.types';

export interface INotificationDocument extends Document {
  _id: Types.ObjectId;
  type: NotificationType;
  version: string;
  recipientUserId?: Types.ObjectId;
  recipientScope: RecipientScope;
  titleKey: string;
  bodyKey: string;
  variables: Map<string, any> | Record<string, any>;
  renderedTitle?: string;
  renderedBody?: string;
  locale: string;
  priority: NotificationPriority;
  relatedEntities: {
    registrationId?: Types.ObjectId;
    doctorId?: Types.ObjectId;
    doctorName?: string;
    registrationWindowId?: string;
  };
  eventKey: string;
  delivery: {
    push: {
      status: DeliveryStatus;
      attempts: number;
      lastAttemptAt?: Date;
      error?: string;
    };
    socket: {
      status: DeliveryStatus;
    };
    inApp: {
      status: DeliveryStatus;
    };
  };
  createdBy: string;
  expiresAt?: Date | null;
  readAt?: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

const notificationSchema = new Schema<INotificationDocument>(
  {
    type: {
      type: String,
      enum: [
        'REGISTRATION_CONFIRMED',
        'HOSPITAL_ANNOUNCEMENT',
        'DOCTOR_UNAVAILABLE',
        'OPD_CLOSED'
      ],
      required: true
    },
    version: { type: String, default: '1.0' },
    recipientUserId: { type: Schema.Types.ObjectId, ref: 'Patient', index: true },
    recipientScope: {
      type: String,
      enum: ['USER', 'TODAY_PATIENTS', 'ALL_ACTIVE_USERS'],
      default: 'USER'
    },
    titleKey: { type: String, required: true },
    bodyKey: { type: String, required: true },
    variables: { type: Schema.Types.Mixed, default: {} },
    renderedTitle: { type: String },
    renderedBody: { type: String },
    locale: { type: String, default: 'en' },
    priority: {
      type: String,
      enum: ['normal', 'high', 'urgent'],
      default: 'normal'
    },
    relatedEntities: {
      registrationId: { type: Schema.Types.ObjectId, ref: 'Registration' },
      doctorId: { type: Schema.Types.ObjectId, ref: 'Doctor' },
      doctorName: { type: String },
      registrationWindowId: { type: String }
    },
    eventKey: { type: String, required: true, unique: true },
    delivery: {
      push: {
        status: { type: String, default: 'pending' },
        attempts: { type: Number, default: 0 },
        lastAttemptAt: { type: Date },
        error: { type: String }
      },
      socket: {
        status: { type: String, default: 'pending' }
      },
      inApp: {
        status: { type: String, default: 'stored' }
      }
    },
    createdBy: { type: String, default: 'system' },
    expiresAt: { type: Date, default: null },
    readAt: { type: Date, default: null }
  },
  { timestamps: true }
);

// Indexes matching specifications
notificationSchema.index({ recipientUserId: 1, createdAt: -1 });
notificationSchema.index({ recipientUserId: 1, 'delivery.inApp.status': 1 });
notificationSchema.index({ type: 1, createdAt: -1 });
notificationSchema.index({ expiresAt: 1 });

export const Notification = mongoose.model<INotificationDocument>('Notification', notificationSchema);
export default Notification;
