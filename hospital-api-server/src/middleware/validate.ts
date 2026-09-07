import { z } from 'zod';
import { Request, Response, NextFunction } from 'express';
import { sendError } from '../utils/apiResponse';

export const validate = (schema: any) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      req.body = schema.parse(req.body);
      next();
    } catch (error) {
      if (error instanceof z.ZodError) {
        const errorMessages = error.issues.map((err) => err.message).join(', ');
        sendError(res, errorMessages, 'VALIDATION_ERROR', 400);
      } else {
        next(error);
      }
    }
  };
};
