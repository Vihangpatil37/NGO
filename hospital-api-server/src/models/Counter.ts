import mongoose, { Schema } from 'mongoose';
import { ICounter } from '../types';

const counterSchema = new Schema<ICounter>({
  key: { type: String, required: true, unique: true },
  sequence: { type: Number, default: 0 }
});

counterSchema.virtual('registrationWindowId')
  .get(function() { return this.key; })
  .set(function(val: string) { this.key = val; });

export const Counter = mongoose.model<ICounter>('Counter', counterSchema);
export default Counter;
