import mongoose, { Schema, Document, Types } from 'mongoose';
import { IDeviceToken } from './notification.types';

export interface IDeviceTokenDocument extends Document {
  _id: Types.ObjectId;
  userId: Types.ObjectId; // Patient ID
  tokens: IDeviceToken[];
  locale: string;
  createdAt: Date;
  updatedAt: Date;
}

const deviceTokenItemSchema = new Schema<IDeviceToken>({
  token: { type: String, required: true },
  platform: { type: String, enum: ['android', 'ios', 'web'], default: 'android' },
  lastSeenAt: { type: Date, default: Date.now },
  isActive: { type: Boolean, default: true }
}, { _id: false });

const deviceTokenSchema = new Schema<IDeviceTokenDocument>({
  userId: { type: Schema.Types.ObjectId, ref: 'Patient', required: true, unique: true, index: true },
  tokens: [deviceTokenItemSchema],
  locale: { type: String, default: 'en' }
}, { timestamps: true });

export const DeviceToken = mongoose.model<IDeviceTokenDocument>('DeviceToken', deviceTokenSchema);
export default DeviceToken;
