import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IDoctor extends Document {
  _id: Types.ObjectId;
  name: string;
  phoneNumber: string;
  specialization?: string;
  pinHash: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const doctorSchema = new Schema<IDoctor>({
  name: { type: String, required: true, trim: true },
  phoneNumber: { type: String, required: true, unique: true, trim: true },
  specialization: { type: String, trim: true },
  pinHash: { type: String, required: true, select: false },
  isActive: { type: Boolean, required: true, default: true },
}, { timestamps: true });

// Never return pinHash in JSON
doctorSchema.methods.toJSON = function () {
  const obj = this.toObject();
  delete obj.pinHash;
  return obj;
};

export const Doctor = mongoose.model<IDoctor>('Doctor', doctorSchema);
export default Doctor;
