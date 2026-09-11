import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import Doctor, { IDoctor } from '../../models/Doctor';
import DoctorAvailability, { AvailabilityStatus } from '../../models/DoctorAvailability';
import env from '../../config/env';
import { getRegistrationWindowId } from '../../middleware/validateRegistrationWindow';
import { logger } from '../../utils/logger';

const SALT_ROUNDS = 12;
const TOKEN_EXPIRY = '24h';

export class DoctorService {
  /**
   * Authenticate doctor and return JWT + profile
   */
  static async login(phoneNumber: string, pin: string) {
    const doctor = await Doctor.findOne({ phoneNumber })
      .select('+pinHash');

    if (!doctor) {
      return { success: false, reason: 'invalid_credentials' };
    }

    if (!doctor.isActive) {
      return { success: false, reason: 'invalid_credentials' };
    }

    const pinMatch = await bcrypt.compare(pin, doctor.pinHash);
    if (!pinMatch) {
      return { success: false, reason: 'invalid_credentials' };
    }

    const token = jwt.sign(
      {
        doctorObjectId: doctor._id.toString(),
        phoneNumber: doctor.phoneNumber,
        role: 'doctor',
      },
      env.DOCTOR_JWT_SECRET,
      { expiresIn: TOKEN_EXPIRY }
    );

    return {
      success: true,
      token,
      doctor: {
        id: doctor._id,
        phoneNumber: doctor.phoneNumber,
        name: doctor.name,
        specialization: doctor.specialization,
      },
    };
  }

  /**
   * Get doctor profile by ObjectId
   */
  static async getProfile(doctorObjectId: string) {
    const doctor = await Doctor.findById(doctorObjectId);
    if (!doctor || !doctor.isActive) {
      return null;
    }
    return {
      id: doctor._id,
      phoneNumber: doctor.phoneNumber,
      name: doctor.name,
      specialization: doctor.specialization,
    };
  }

  /**
   * Get current window availability for a doctor
   */
  static async getAvailability(doctorObjectId: string) {
    const windowId = getRegistrationWindowId();

    const availability = await DoctorAvailability.findOne({
      doctorId: doctorObjectId,
      registrationWindowId: windowId,
    });

    return {
      registrationWindow: {
        id: windowId,
        date: windowId,
      },
      availability: availability
        ? {
            status: availability.status,
            respondedAt: availability.respondedAt,
          }
        : null,
    };
  }

  /**
   * Create or update doctor availability for current window
   */
  static async submitAvailability(
    doctorObjectId: string,
    status: AvailabilityStatus
  ) {
    const windowId = getRegistrationWindowId();
    const now = new Date();

    const availability = await DoctorAvailability.findOneAndUpdate(
      {
        doctorId: doctorObjectId,
        registrationWindowId: windowId,
      },
      {
        status,
        respondedAt: now,
      },
      {
        upsert: true,
        new: true,
        setDefaultsOnInsert: true,
      }
    );

    return {
      registrationWindow: {
        id: windowId,
        date: windowId,
      },
      availability: {
        status: availability.status,
        respondedAt: availability.respondedAt,
      },
    };
  }

  /**
   * Hash a password (used by seed script)
   */
  static async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, SALT_ROUNDS);
  }
}

export default DoctorService;
