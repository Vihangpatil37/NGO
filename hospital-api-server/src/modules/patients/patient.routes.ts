import { Router } from 'express';
import PatientController from './patient.controller';
import validateRegistrationWindow from '../../middleware/validateRegistrationWindow';
import { validate } from '../../middleware/validate';
import { newCaseSchema, oldCaseSchema } from './patient.schemas';

const router = Router();

// Patient token generation and queue routes
router.post('/cases/new', validateRegistrationWindow, validate(newCaseSchema), PatientController.registerNewCase);
router.post('/cases/lookup', validate(oldCaseSchema), PatientController.lookupCase);
router.post('/queue/register', validateRegistrationWindow, validate(oldCaseSchema), PatientController.registerOldCase);
router.get('/token', PatientController.getTokenStatus);
router.get('/queue/status', PatientController.getHospitalQueueStatus);
router.patch('/language', PatientController.updateLanguage);

export default router;
