import mongoose, { Schema, Document, Types } from 'mongoose';

export type AvailabilityStatus = 'coming' | 'not_coming';

export interface IDoctorAvailability extends Document {
  _id: Types.ObjectId;
  doctorId: Types.ObjectId;
  registrationWindowId: string;
  status: AvailabilityStatus;
  respondedAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

const doctorAvailabilitySchema = new Schema<IDoctorAvailability>({
  doctorId: {
    type: Schema.Types.ObjectId,
    ref: 'Doctor',
    required: true,
  },
  registrationWindowId: {
    type: String,
    required: true,
    index: true,
  },
  status: {
    type: String,
    enum: ['coming', 'not_coming'],
    required: true,
  },
  respondedAt: { type: Date, required: true },
}, { timestamps: true });

// One availability record per doctor per window
doctorAvailabilitySchema.index(
  { doctorId: 1, registrationWindowId: 1 },
  { unique: true }
);

export const DoctorAvailability = mongoose.model<IDoctorAvailability>(
  'DoctorAvailability',
  doctorAvailabilitySchema
);
export default DoctorAvailability;
