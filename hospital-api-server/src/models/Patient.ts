import mongoose, { Schema } from 'mongoose';
import { IPatient } from '../types';

const patientSchema = new Schema<IPatient>({
  caseType: { type: String, enum: ['new', 'old'], required: true, default: 'new' },
  name: { type: String, required: true, trim: true },
  villageName: { type: String, required: true, trim: true },
  phoneNumber: { type: String, required: true, index: true, trim: true },
  caseNumber: { type: String, required: true, index: true, trim: true },
  age: { type: Number, min: 0, max: 150 }
}, { timestamps: true });

export const Patient = mongoose.model<IPatient>('Patient', patientSchema);
export default Patient;
