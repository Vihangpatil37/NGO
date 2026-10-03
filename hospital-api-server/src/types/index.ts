import { Document, Types } from 'mongoose';

export type CaseType = 'new' | 'old';
export type QueueStatus = 'active' | 'called' | 'in_consultation' | 'completed' | 'skipped' | 'cancelled';

export interface IPatient extends Document {
  _id: Types.ObjectId;
  caseType: CaseType;
  name: string;
  villageName: string;
  phoneNumber: string;
  caseNumber: string;
  age?: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface IRegistration extends Document {
  _id: Types.ObjectId;
  patientId: Types.ObjectId | IPatient;
  registrationWindowId: string;
  deviceId?: string;
  status: 'registered' | 'arrived' | 'in_queue' | 'in_consultation' | 'completed' | 'cancelled';
  createdAt: Date;
  updatedAt: Date;
}

export interface IQueueToken extends Document {
  _id: Types.ObjectId;
  registrationId: Types.ObjectId | IRegistration;
  patientId?: Types.ObjectId | IPatient;
  tokenNumber: number;
  registrationWindowId: string;
  departmentId?: string;
  status: QueueStatus;
  calledAt?: Date | null;
  completedAt?: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface ICounter extends Document {
  _id: Types.ObjectId;
  key: string;
  sequence: number;
}

export interface ApiResponse<T = any> {
  success: boolean;
  message?: string;
  data?: T;
  error?: {
    code: string;
    message: string;
  };
}

// Doctor types
export type AvailabilityStatus = 'coming' | 'not_coming';

export interface IDoctorPayload {
  doctorObjectId: string;
  doctorId: string;
  role: 'doctor';
}

