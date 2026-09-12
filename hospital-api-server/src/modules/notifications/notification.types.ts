export type NotificationType =
  | 'REGISTRATION_CONFIRMED'
  | 'TURN_NEAR'
  | 'TOKEN_CALLED'
  | 'HOSPITAL_ANNOUNCEMENT'
  | 'DOCTOR_AVAILABLE'
  | 'DOCTOR_UNAVAILABLE'
  | 'OPD_REMINDER'
  | 'OPD_CLOSED';

export type NotificationPriority = 'normal' | 'high' | 'urgent';

export type RecipientScope = 'USER' | 'TODAY_PATIENTS' | 'ALL_ACTIVE_USERS';

export type DeliveryStatus =
  | 'pending'
  | 'queued'
  | 'sending'
  | 'provider_accepted'
  | 'delivered'
  | 'read'
  | 'failed'
  | 'retry'
  | 'failed_permanent';

export interface IDeviceToken {
  token: string;
  platform: 'android' | 'ios' | 'web';
  lastSeenAt: Date;
  isActive: boolean;
}

export interface INotificationPayload {
  type: NotificationType;
  recipientUserId?: string;
  recipientScope?: RecipientScope;
  eventKey: string;
  titleKey: string;
  bodyKey: string;
  variables?: Record<string, any>;
  locale?: string;
  priority?: NotificationPriority;
  relatedEntities?: {
    tokenId?: string;
    tokenNumber?: number;
    registrationId?: string;
    doctorId?: string;
    doctorName?: string;
    registrationWindowId?: string;
    patientsAhead?: number;
  };
  createdBy?: string;
  expiresAt?: Date | null;
}
