import { Request, Response } from 'express';
import mongoose from 'mongoose';
import jwt from 'jsonwebtoken';
import { QueueToken } from '../../models/QueueToken';
import { Registration } from '../../models/Registration';
import { Patient } from '../../models/Patient';
import Doctor from '../../models/Doctor';
import { DoctorService } from '../doctors/doctor.service';
import env from '../../config/env';
import { getRegistrationWindowId } from '../../middleware/validateRegistrationWindow';
import { sendSuccess, sendError } from '../../utils/apiResponse';
import { logger } from '../../utils/logger';
import { notifyTokenStatusChange, notifyAdminNewToken } from '../../infrastructure/socket/notifier';
import QueueService from '../tokens/queue.service';
import NotificationService from '../notifications/notification.service';

const unwrapParam = (param: string | string[] | undefined): string => {
  if (!param) return '';
  return Array.isArray(param) ? param[0] : param;
};

export class StaffController {
  public static login(req: Request, res: Response): void {
    const { pin } = req.body;
    if (pin === '1234') {
      const token = jwt.sign({ role: 'admin' }, env.ADMIN_JWT_SECRET, { expiresIn: '8h' });
      sendSuccess(res, { token });
      return;
    }
    sendError(res, 'Invalid PIN', 'UNAUTHORIZED', 401);
  }

  public static async getLiveQueue(req: Request, res: Response): Promise<void> {
    try {
      const windowId = getRegistrationWindowId();
      const tokens = await QueueToken.find({
        registrationWindowId: windowId,
        status: { $in: ['active', 'called', 'in_consultation'] }
      })
        .sort({ tokenNumber: 1 })
        .populate({
          path: 'registrationId',
          populate: { path: 'patientId' }
        });

      sendSuccess(res, { queue: tokens });
    } catch (error) {
      logger.error({ err: error }, 'getLiveQueue error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }

  private static async updateTokenStatus(tokenId: string, newStatus: any, req: Request, res: Response): Promise<void> {
    try {
      const token = await QueueToken.findById(tokenId);
      if (!token) {
        sendError(res, 'Token not found', 'NOT_FOUND', 404);
        return;
      }

      token.status = newStatus;
      if (newStatus === 'called') token.calledAt = new Date();
      if (newStatus === 'completed') {
        token.completedAt = new Date();
        await Registration.findByIdAndUpdate(token.registrationId, { status: 'completed' });
      }

      await token.save();

      notifyTokenStatusChange((req as any).io, token, newStatus);

      // Trigger N03 (TOKEN_CALLED) and evaluate N02 (TURN_NEAR)
      if (newStatus === 'called' && token.patientId) {
        NotificationService.onTokenCalled(
          (req as any).io,
          token.patientId.toString(),
          token._id.toString(),
          token.tokenNumber,
          token.registrationWindowId
        ).catch(err => logger.error({ err }, 'Failed to dispatch TOKEN_CALLED notification'));
      }

      sendSuccess(res, { token }, `Token marked as ${newStatus}`);
    } catch (error) {
      logger.error({ err: error }, 'updateTokenStatus error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }

  public static async callNext(req: Request, res: Response): Promise<void> {
    let targetTokenId = unwrapParam(req.params.tokenId);

    if (!targetTokenId || targetTokenId === 'next') {
      const windowId = getRegistrationWindowId();
      const nextToken = await QueueToken.findOne({
        registrationWindowId: windowId,
        status: 'active'
      }).sort({ tokenNumber: 1 });

      if (!nextToken) {
        sendError(res, 'No active tokens in queue', 'NOT_FOUND', 404);
        return;
      }
      targetTokenId = nextToken._id.toString();
    }

    return StaffController.updateTokenStatus(targetTokenId, 'called', req, res);
  }

  public static async skipToken(req: Request, res: Response): Promise<void> {
    const tokenId = unwrapParam(req.params.tokenId);
    return StaffController.updateTokenStatus(tokenId, 'skipped', req, res);
  }

  public static async completeToken(req: Request, res: Response): Promise<void> {
    const tokenId = unwrapParam(req.params.tokenId);
    return StaffController.updateTokenStatus(tokenId, 'completed', req, res);
  }

  public static async getRegistrations(req: Request, res: Response): Promise<void> {
    try {
      const search = req.query.search ? String(req.query.search) : undefined;
      const type = req.query.type ? String(req.query.type) : undefined;
      const status = req.query.status ? String(req.query.status) : undefined;
      const window = req.query.window ? String(req.query.window) : undefined;

      let patientQuery: any = {};
      if (type) patientQuery.caseType = type;
      if (search) {
        patientQuery.$or = [
          { name: { $regex: search, $options: 'i' } },
          { phoneNumber: { $regex: search, $options: 'i' } },
          { caseNumber: { $regex: search, $options: 'i' } }
        ];
      }

      let patientIds: any = null;
      if (Object.keys(patientQuery).length > 0) {
        const patients = await Patient.find(patientQuery).select('_id');
        patientIds = patients.map((p) => p._id);
      }

      let regQuery: any = {};
      const targetWindow = (window as string) || getRegistrationWindowId();
      regQuery.registrationWindowId = targetWindow;
      if (status) regQuery.status = status;
      if (patientIds !== null) {
        regQuery.patientId = { $in: patientIds };
      }

      const registrations = await Registration.find(regQuery)
        .populate('patientId')
        .sort({ createdAt: -1 });

      sendSuccess(res, { registrations });
    } catch (error) {
      logger.error({ err: error }, 'getRegistrations error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }

  public static async updateRegistration(req: Request, res: Response): Promise<void> {
    try {
      const id = unwrapParam(req.params.id);
      const updates = req.body;

      const registration = await Registration.findById(id);
      if (!registration) {
        sendError(res, 'Registration not found', 'NOT_FOUND', 404);
        return;
      }

      const patientAllowedFields = ['name', 'villageName', 'phoneNumber', 'caseNumber', 'age'];
      const patientUpdates: any = {};
      Object.keys(updates).forEach((k) => {
        if (patientAllowedFields.includes(k)) patientUpdates[k] = updates[k];
      });

      if (Object.keys(patientUpdates).length > 0) {
        await Patient.findByIdAndUpdate(registration.patientId, patientUpdates);
      }

      if (updates.status) {
        registration.status = updates.status;
        await registration.save();
      }

      const updatedReg = await Registration.findById(id).populate('patientId');
      sendSuccess(res, { registration: updatedReg });
    } catch (err) {
      logger.error({ err }, 'updateRegistration error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }

  public static async deleteRegistration(req: Request, res: Response): Promise<void> {
    try {
      const id = unwrapParam(req.params.id);
      await QueueToken.deleteMany({ registrationId: id });
      await Registration.findByIdAndDelete(id);
      sendSuccess(res, {}, 'Deleted successfully');
    } catch (err) {
      logger.error({ err }, 'deleteRegistration error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }

  public static async searchPatients(req: Request, res: Response): Promise<void> {
    try {
      const query = req.query.query ? String(req.query.query) : undefined;
      let dbQuery: any = {};

      if (query) {
        dbQuery.$or = [
          { name: { $regex: query, $options: 'i' } },
          { phoneNumber: { $regex: query, $options: 'i' } },
          { caseNumber: { $regex: query, $options: 'i' } },
          { villageName: { $regex: query, $options: 'i' } }
        ];
      }

      const patients = await Patient.find(dbQuery).sort({ createdAt: -1 }).lean();
      const patientIds = patients.map((p) => p._id);
      const registrations = await Registration.find({ patientId: { $in: patientIds } }).lean();

      const visitData = registrations.reduce((acc: any, reg: any) => {
        const pId = reg.patientId.toString();
        if (!acc[pId]) {
          acc[pId] = { totalVisits: 0, lastVisitDate: null };
        }
        acc[pId].totalVisits += 1;
        if (!acc[pId].lastVisitDate || new Date(reg.createdAt) > new Date(acc[pId].lastVisitDate)) {
          acc[pId].lastVisitDate = reg.createdAt;
        }
        return acc;
      }, {});

      const enrichedPatients = patients.map((p: any) => ({
        ...p,
        totalVisits: visitData[p._id.toString()]?.totalVisits || 0,
        lastVisitDate: visitData[p._id.toString()]?.lastVisitDate || p.createdAt
      }));

      sendSuccess(res, { patients: enrichedPatients });
    } catch (error) {
      logger.error({ err: error }, 'searchPatients error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }

  public static async getPatientStats(req: Request, res: Response): Promise<void> {
    try {
      const totalPatients = await Patient.countDocuments();
      const windowId = getRegistrationWindowId();
      const todaysRegistrations = await Registration.countDocuments({ registrationWindowId: windowId });
      const returningPatients = await Patient.countDocuments({ caseType: 'old' });

      const startOfMonth = new Date();
      startOfMonth.setDate(1);
      startOfMonth.setHours(0, 0, 0, 0);
      const newPatientsThisMonth = await Patient.countDocuments({
        createdAt: { $gte: startOfMonth }
      });

      sendSuccess(res, { totalPatients, todaysRegistrations, returningPatients, newPatientsThisMonth });
    } catch (error) {
      logger.error({ err: error }, 'getPatientStats error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }

  public static async getPatientById(req: Request, res: Response): Promise<void> {
    try {
      const id = unwrapParam(req.params.id);
      const patient = await Patient.findById(id).lean();
      if (!patient) {
        sendError(res, 'Patient not found', 'NOT_FOUND', 404);
        return;
      }

      const registrations = await Registration.find({ patientId: id }).sort({ createdAt: -1 }).lean();
      const regIds = registrations.map((r) => r._id);
      const tokens = await QueueToken.find({ registrationId: { $in: regIds } }).lean();

      const tokenMap = tokens.reduce((acc: any, t: any) => {
        acc[t.registrationId.toString()] = t;
        return acc;
      }, {});

      const history = registrations.map((reg: any) => {
        const token = tokenMap[reg._id.toString()];
        return {
          ...reg,
          tokenNumber: token ? token.tokenNumber : null,
          queueStatus: token ? token.status : null
        };
      });

      sendSuccess(res, { patient, history });
    } catch (error) {
      logger.error({ err: error }, 'getPatientById error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }

  public static async updatePatient(req: Request, res: Response): Promise<void> {
    try {
      const id = unwrapParam(req.params.id);
      const allowedUpdates = ['name', 'phoneNumber', 'villageName', 'caseNumber', 'caseType', 'age', 'preferredLanguage'];
      const updates: any = {};

      allowedUpdates.forEach((key) => {
        if (req.body[key] !== undefined) {
          updates[key] = req.body[key];
        }
      });

      const patient = await Patient.findByIdAndUpdate(id, updates, { new: true });
      if (!patient) {
        sendError(res, 'Patient not found', 'NOT_FOUND', 404);
        return;
      }

      sendSuccess(res, { patient }, 'Patient updated');
    } catch (error) {
      logger.error({ err: error }, 'updatePatient error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }

  public static async registerAgain(req: Request, res: Response): Promise<void> {
    try {
      const id = unwrapParam(req.params.id);
      const patient = await Patient.findById(id);
      if (!patient) {
        sendError(res, 'Patient not found', 'NOT_FOUND', 404);
        return;
      }

      const windowId = getRegistrationWindowId();

      const { token, registration } = await QueueService.findActiveToken(patient._id.toString(), windowId);

      if (token && registration) {
        sendError(res, 'Patient is already registered for this window.', 'CONFLICT', 409);
        return;
      }

      const result = await QueueService.issueToken(patient._id.toString(), windowId);

      await notifyAdminNewToken((req as any).io, result.registration, result.token);

      sendSuccess(res, { registration: result.registration, token: result.token }, 'Re-registration successful', 201);
    } catch (error) {
      logger.error({ err: error }, 'registerAgain error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }

  // --- Doctor Management ---

  public static async getDoctorsWithAvailability(req: Request, res: Response): Promise<void> {
    try {
      const windowId = getRegistrationWindowId();
      const doctors = await Doctor.aggregate([
        {
          $lookup: {
            from: 'doctoravailabilities',
            let: { docId: '$_id' },
            pipeline: [
              { $match: { $expr: { $and: [
                { $eq: ['$doctorId', '$$docId'] },
                { $eq: ['$registrationWindowId', windowId] }
              ]}}}
            ],
            as: 'availability'
          }
        },
        {
          $project: {
            pinHash: 0 // Ensure we don't leak the pinHash
          }
        }
      ]);
      sendSuccess(res, { doctors });
    } catch (error) {
      logger.error({ err: error }, 'getDoctors error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }

  public static async addDoctor(req: Request, res: Response): Promise<void> {
    try {
      const { name, specialization, phoneNumber, pin } = req.body;
      
      const existing = await Doctor.findOne({ phoneNumber });
      if (existing) {
        sendError(res, 'A doctor with this phone number already exists', 'CONFLICT', 409);
        return;
      }

      const pinHash = await DoctorService.hashPassword(pin);
      
      const doctor = await Doctor.create({
        name,
        specialization,
        phoneNumber,
        pinHash,
        isActive: true
      });

      const doctorJson = doctor.toJSON();

      sendSuccess(res, { doctor: doctorJson }, 'Doctor added successfully', 201);
    } catch (error) {
      logger.error({ err: error }, 'addDoctor error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }

  public static async updateDoctor(req: Request, res: Response): Promise<void> {
    try {
      const id = unwrapParam(req.params.id);
      const { name, specialization, phoneNumber, pin } = req.body;

      const doctor = await Doctor.findById(id);
      if (!doctor) {
        sendError(res, 'Doctor not found', 'NOT_FOUND', 404);
        return;
      }

      if (phoneNumber && phoneNumber !== doctor.phoneNumber) {
        const existing = await Doctor.findOne({ phoneNumber });
        if (existing) {
          sendError(res, 'Phone number already in use by another doctor', 'CONFLICT', 409);
          return;
        }
        doctor.phoneNumber = phoneNumber;
      }

      if (name !== undefined) doctor.name = name;
      if (specialization !== undefined) doctor.specialization = specialization;

      if (pin) {
        doctor.pinHash = await DoctorService.hashPassword(pin);
      }

      await doctor.save();

      const updated = await Doctor.findById(id);
      sendSuccess(res, { doctor: updated });
    } catch (error) {
      logger.error({ err: error }, 'updateDoctor error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }

  public static async deleteDoctor(req: Request, res: Response): Promise<void> {
    try {
      const id = unwrapParam(req.params.id);
      
      const doctor = await Doctor.findById(id);
      if (!doctor) {
        sendError(res, 'Doctor not found', 'NOT_FOUND', 404);
        return;
      }

      // Hard delete the doctor
      await Doctor.findByIdAndDelete(id);
      
      // Also delete any associated availability records to keep DB clean
      const DoctorAvailability = mongoose.model('DoctorAvailability');
      await DoctorAvailability.deleteMany({ doctorId: doctor._id });

      sendSuccess(res, {}, 'Doctor deleted successfully');
    } catch (error) {
      logger.error({ err: error }, 'deleteDoctor error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }

  public static async resetDoctorPin(req: Request, res: Response): Promise<void> {
    try {
      const id = unwrapParam(req.params.id);
      const { pin } = req.body;

      if (!pin) {
        sendError(res, 'PIN is required', 'BAD_REQUEST', 400);
        return;
      }

      const doctor = await Doctor.findById(id);
      if (!doctor) {
        sendError(res, 'Doctor not found', 'NOT_FOUND', 404);
        return;
      }

      doctor.pinHash = await DoctorService.hashPassword(pin);
      await doctor.save();

      sendSuccess(res, {}, 'Doctor PIN updated successfully');
    } catch (error) {
      logger.error({ err: error }, 'resetDoctorPin error');
      sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
    }
  }
}

export default StaffController;
