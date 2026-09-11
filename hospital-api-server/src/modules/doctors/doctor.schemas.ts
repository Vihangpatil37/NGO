import { z } from 'zod';

export const doctorLoginSchema = z.object({
  phoneNumber: z.string().regex(/^\d{10}$/, 'Must be a valid 10-digit phone number'),
  pin: z.string().regex(/^\d{6}$/, 'PIN must be exactly 6 digits'),
});

export const doctorAvailabilitySchema = z.object({
  status: z.enum(['coming', 'not_coming'], {
    message: 'Status must be "coming" or "not_coming"',
  }),
});
