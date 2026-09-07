import { Request, Response, NextFunction } from 'express';
import { DateTime } from 'luxon';
import env from '../config/env';

export const getRegistrationWindowId = (): string => {
  const now = DateTime.now().setZone(env.TIMEZONE);

  if (env.ALLOW_24_7_REGISTRATION) {
    return now.toFormat('yyyy-MM-dd');
  }

  let windowStart = now;
  if (now.weekday === 7 && now.hour < 6) {
    windowStart = now.minus({ days: 1 });
  } else if (now.weekday !== 6) {
    windowStart = now.set({ weekday: 6 }).minus({ weeks: now.weekday < 6 ? 1 : 0 });
  }

  return windowStart.toFormat('yyyy-MM-dd');
};

export const validateRegistrationWindow = (req: Request | any, res: Response, next: NextFunction) => {
  if (env.ALLOW_24_7_REGISTRATION) {
    req.registrationWindowId = getRegistrationWindowId();
    return next();
  }

  const now = DateTime.now().setZone(env.TIMEZONE);
  const dayOfWeek = now.weekday;
  const hour = now.hour;

  const isWindowOpen = (dayOfWeek === 6 && hour >= 6) || (dayOfWeek === 7 && hour < 6);

  if (!isWindowOpen) {
    res.status(403).json({
      success: false,
      error: {
        code: 'REGISTRATION_CLOSED',
        message: 'Registration is currently closed. Registration opens Saturday 06:00 and closes Sunday 06:00.'
      }
    });
    return;
  }

  req.registrationWindowId = getRegistrationWindowId();
  next();
};

export default validateRegistrationWindow;
