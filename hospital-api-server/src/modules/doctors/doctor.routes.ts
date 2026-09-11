import { Router } from 'express';
import DoctorController from './doctor.controller';
import { doctorAuth } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { doctorLoginSchema, doctorAvailabilitySchema } from './doctor.schemas';

const router = Router();

// Public
router.post('/login', validate(doctorLoginSchema), DoctorController.login);

// Protected (requires doctor JWT)
router.use(doctorAuth);
router.get('/me', DoctorController.getProfile);
router.get('/availability', DoctorController.getAvailability);
router.post('/availability', validate(doctorAvailabilitySchema), DoctorController.submitAvailability);

export default router;
