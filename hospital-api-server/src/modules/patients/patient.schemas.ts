import { z } from 'zod';

export const newCaseSchema = z.object({
  phoneNumber: z.string().regex(/^\d{10}$/, 'Please enter a valid 10-digit mobile number.'),
  name: z.string().min(1, 'Please enter the patient\'s full name.').trim(),
  villageName: z.string().min(1, 'Please enter the village name.').trim(),
  age: z.coerce.number().int().min(0).max(130).optional(),
  deviceId: z.string().optional(),
});

export const oldCaseSchema = z.object({
  phoneNumber: z.string().regex(/^\d{10}$/, 'Please enter a valid 10-digit mobile number.'),
  caseNumber: z.string().min(1, 'Case ID is required.').trim(),
  deviceId: z.string().optional(),
});
