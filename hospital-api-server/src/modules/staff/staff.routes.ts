import { Router } from 'express';
import StaffController from './staff.controller';
import { adminAuth } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { createDoctorSchema, updateDoctorSchema, resetDoctorPinSchema } from './staff.schemas';

const router = Router();

// Public staff login
router.post('/login', StaffController.login);

// Protected staff routes
router.use(adminAuth);

// Live Queue Management
router.get('/queue/live', StaffController.getLiveQueue);
router.post('/queue/:tokenId/call-next', StaffController.callNext);
router.post('/queue/:tokenId/skip', StaffController.skipToken);
router.post('/queue/:tokenId/complete', StaffController.completeToken);

// Registrations
router.get('/registrations', StaffController.getRegistrations);
router.patch('/registrations/:id', StaffController.updateRegistration);
router.delete('/registrations/:id', StaffController.deleteRegistration);

// Patients Directory
router.get('/patients', StaffController.searchPatients);
router.get('/patients/stats', StaffController.getPatientStats);
router.get('/patients/:id', StaffController.getPatientById);
router.patch('/patients/:id', StaffController.updatePatient);
router.post('/patients/:id/register-again', StaffController.registerAgain);

// Doctors
router.get('/doctors', StaffController.getDoctorsWithAvailability);
router.get('/doctors/availability', StaffController.getDoctorsWithAvailability);
router.post('/doctors', validate(createDoctorSchema), StaffController.addDoctor);
router.patch('/doctors/:id/pin', validate(resetDoctorPinSchema), StaffController.resetDoctorPin);
router.patch('/doctors/:id', validate(updateDoctorSchema), StaffController.updateDoctor);
router.delete('/doctors/:id', StaffController.deleteDoctor);

export default router;
