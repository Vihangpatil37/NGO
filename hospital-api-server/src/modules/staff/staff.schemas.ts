import { z } from 'zod';

export const createDoctorSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  specialization: z.string().optional(),
  phoneNumber: z.string().regex(/^\d{10}$/, 'Must be a valid 10-digit phone number'),
  pin: z.string().regex(/^\d{6}$/, 'PIN must be exactly 6 digits'),
});

export const updateDoctorSchema = z.object({
  name: z.string().min(1, 'Name cannot be empty').optional(),
  specialization: z.string().optional(),
  phoneNumber: z.string().regex(/^\d{10}$/, 'Must be a valid 10-digit phone number').optional(),
  pin: z.string().regex(/^\d{6}$/, 'PIN must be exactly 6 digits').optional(),
});
