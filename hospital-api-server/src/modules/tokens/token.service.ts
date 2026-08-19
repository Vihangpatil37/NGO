import Counter from '../../models/Counter';

export class TokenService {
  /**
   * Atomically generate the next sequential token number for the given window/day.
   */
  public static async getNextTokenNumber(windowId: string): Promise<number> {
    const counter = await Counter.findOneAndUpdate(
      { key: `token:${windowId}` },
      { $inc: { sequence: 1 } },
      { new: true, upsert: true }
    );
    return counter.sequence;
  }

  /**
   * Atomically generate the next sequential Case ID in U-00000 format.
   * e.g., U-00001, U-00002, ...
   */
  public static async getNextCaseNumber(): Promise<string> {
    const counter = await Counter.findOneAndUpdate(
      { key: 'case_number' },
      { $inc: { sequence: 1 } },
      { new: true, upsert: true }
    );
    const padded = String(counter.sequence).padStart(5, '0');
    return `U-${padded}`;
  }
}

export default TokenService;
