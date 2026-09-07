import mongoose, { Schema } from 'mongoose';
import { IQueueToken } from '../types';

const queueTokenSchema = new Schema<IQueueToken>({
  registrationId: { type: Schema.Types.ObjectId, ref: 'Registration', required: true },
  patientId: { type: Schema.Types.ObjectId, ref: 'Patient' },
  tokenNumber: { type: Number, required: true },
  registrationWindowId: { type: String, required: true, index: true },
  departmentId: { type: String, default: 'general' },
  status: { type: String, enum: ['active', 'called', 'in_consultation', 'completed', 'skipped', 'cancelled'], default: 'active', index: true },
  calledAt: { type: Date, default: null },
  completedAt: { type: Date, default: null }
}, { timestamps: true });

queueTokenSchema.index({ registrationWindowId: 1, tokenNumber: 1 });
queueTokenSchema.index({ registrationWindowId: 1, status: 1 });

export const QueueToken = mongoose.model<IQueueToken>('QueueToken', queueTokenSchema);
export default QueueToken;
