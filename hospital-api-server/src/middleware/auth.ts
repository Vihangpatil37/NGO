import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import env from '../config/env';

export const adminAuth = (req: Request | any, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith('Bearer ')
    ? authHeader.split(' ')[1]
    : authHeader;

  if (!token) {
    res.status(401).json({
      success: false,
      error: { code: 'UNAUTHORIZED', message: 'No authorization token provided' }
    });
    return;
  }

  try {
    const decoded = jwt.verify(token, env.ADMIN_JWT_SECRET);
    req.admin = decoded;
    next();
  } catch (err) {
    res.status(401).json({
      success: false,
      error: { code: 'INVALID_TOKEN', message: 'Invalid or expired staff token' }
    });
  }
};

export const patientAuth = (req: Request | any, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith('Bearer ')
    ? authHeader.split(' ')[1]
    : authHeader;

  if (!token) {
    res.status(401).json({
      success: false,
      error: { code: 'UNAUTHORIZED', message: 'No session token provided' }
    });
    return;
  }

  try {
    const decoded = jwt.verify(token, env.PATIENT_JWT_SECRET);
    req.patientSession = decoded;
    next();
  } catch (err) {
    res.status(401).json({
      success: false,
      error: { code: 'INVALID_SESSION', message: 'Invalid or expired patient session' }
    });
  }
};

export const doctorAuth = (req: Request | any, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith('Bearer ')
    ? authHeader.split(' ')[1]
    : authHeader;

  if (!token) {
    res.status(401).json({
      success: false,
      error: { code: 'UNAUTHORIZED', message: 'No doctor authorization token provided' }
    });
    return;
  }

  try {
    const decoded = jwt.verify(token, env.DOCTOR_JWT_SECRET) as any;

    if (decoded.role !== 'doctor') {
      res.status(403).json({
        success: false,
        error: { code: 'FORBIDDEN', message: 'Invalid token role' }
      });
      return;
    }

    req.doctor = decoded;
    next();
  } catch (err) {
    res.status(401).json({
      success: false,
      error: { code: 'INVALID_TOKEN', message: 'Invalid or expired doctor token' }
    });
  }
};
