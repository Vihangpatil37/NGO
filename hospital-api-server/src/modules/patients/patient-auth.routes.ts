import { Router } from 'express';
import PatientAuthController from './patient-auth.controller';

const router = Router();

router.post('/firebase', PatientAuthController.verifyFirebaseToken);

export default router;
