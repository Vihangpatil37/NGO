import { Response } from 'express';
import { ApiResponse } from '../types';

export const sendSuccess = <T>(res: Response, data?: T, message?: string, statusCode: number = 200) => {
  const responsePayload: ApiResponse<T> = {
    success: true,
    message,
    data
  };
  return res.status(statusCode).json(responsePayload);
};

export const sendError = (res: Response, message: string, errorCode: string = 'ERROR', statusCode: number = 400) => {
  const responsePayload: ApiResponse = {
    success: false,
    error: {
      code: errorCode,
      message
    }
  };
  return res.status(statusCode).json(responsePayload);
};
