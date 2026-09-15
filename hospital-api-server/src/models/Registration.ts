import mongoose, { Schema } from 'mongoose';
import { IRegistration } from '../types';

const registrationSchema = new Schema<IRegistration>({
  patientId: { type: Schema.Types.ObjectId, ref: 'Patient', required: true },
  caseType: { type: String, enum: ['new', 'old'], required: true },
  registrationWindowId: { type: String, required: true, index: true },
  status: { type: String, enum: ['registered', 'arrived', 'in_consultation', 'completed', 'cancelled'], default: 'registered' }
}, { timestamps: true });

export const Registration = mongoose.model<IRegistration>('Registration', registrationSchema);
export default Registration;
