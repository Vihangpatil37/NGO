import { Router } from 'express';
import StaffController from './staff.controller';
import { adminAuth } from '../../middleware/auth';

const router = Router();

// Public staff login
router.post('/login', StaffController.login);

// Protected staff routes
router.use(adminAuth);


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
router.get('/doctors/availability', StaffController.getDoctorsWithAvailability);
router.get('/doctors', StaffController.getDoctorsWithAvailability);
router.post('/doctors', StaffController.addDoctor);
router.patch('/doctors/:id/pin', StaffController.resetDoctorPin);
router.patch('/doctors/:id', StaffController.updateDoctor);
router.delete('/doctors/:id', StaffController.deleteDoctor);

export default router;
