import { Document, Types } from 'mongoose';

export type CaseType = 'new' | 'old';

export interface IPatient extends Document {
  _id: Types.ObjectId;
  caseType: CaseType;
  name: string;
  villageName: string;
  phoneNumber: string;
  caseNumber: string;
  age?: number;
  preferredLanguage?: 'gu' | 'hi' | 'en';
  createdAt: Date;
  updatedAt: Date;
}

export interface IRegistration extends Document {
  _id: Types.ObjectId;
  patientId: Types.ObjectId | IPatient;
  caseType: CaseType;
  registrationWindowId: string;
  status: 'registered' | 'arrived' | 'in_consultation' | 'completed' | 'cancelled';
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

