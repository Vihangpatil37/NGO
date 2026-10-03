import Patient from '../../models/Patient';
import Registration from '../../models/Registration';
import QueueToken from '../../models/QueueToken';
import TokenService from './token.service';

export class QueueService {
  /**
   * Find an active token for the patient in the current window.
   */
  public static async findActiveToken(patientId: string, windowId: string) {
    const registration = await Registration.findOne({
      patientId,
      registrationWindowId: windowId
    });

    if (!registration) return { registration: null, token: null };

    const token = await QueueToken.findOne({
      registrationId: registration._id,
      status: { $in: ['active', 'called', 'in_consultation'] }
    });

    return { registration, token };
  }

  /**
   * Calculate how many people are ahead of a given token.
   */
  public static async getQueuePosition(windowId: string, tokenNumber: number): Promise<number> {
    return QueueToken.countDocuments({
      registrationWindowId: windowId,
      tokenNumber: { $lt: tokenNumber },
      status: 'active'
    });
  }

  /**
   * Issue a new token for the given patient and window.
   */
  public static async issueToken(patientId: string, windowId: string, deviceId?: string) {
    let registration = await Registration.findOne({
      patientId,
      registrationWindowId: windowId
    });

    if (!registration) {
      registration = new Registration({
        patientId,
        registrationWindowId: windowId,
        deviceId,
        status: 'arrived'
      });
      await registration.save();
    }

    const tokenNumber = await TokenService.getNextTokenNumber(windowId);

    const token = new QueueToken({
      registrationId: registration._id,
      patientId,
      tokenNumber,
      registrationWindowId: windowId,
      status: 'active'
    });
    await token.save();

    return { registration, token, tokenNumber };
  }
}

export default QueueService;
