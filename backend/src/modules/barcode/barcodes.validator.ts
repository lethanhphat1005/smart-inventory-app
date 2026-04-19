import { z } from 'zod';

import { validateSchema } from '../../common/utils/index.js';

import type { NextFunction, Request, Response } from 'express';

const barcodeTypeSchema = z.enum(['upc', 'ean', 'code128', 'qr']);

export const scanBarcodeBodySchema = z.object({
  barcode: z
    .string()
    .trim()
    .min(1, 'Barcode is required')
    .max(255, 'Barcode must be at most 255 characters'),
  type: barcodeTypeSchema.optional(),
});

export const confirmBarcodeMappingBodySchema = z.object({
  barcode: z
    .string()
    .trim()
    .min(1, 'Barcode is required')
    .max(255, 'Barcode must be at most 255 characters'),
  productPackageId: z.uuid('Invalid productPackageId'),
  type: barcodeTypeSchema.optional(),
});

export const validateScanBarcode = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.body = validateSchema(scanBarcodeBodySchema, req.body);
  next();
};

export const validateConfirmBarcodeMapping = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.body = validateSchema(confirmBarcodeMappingBodySchema, req.body);
  next();
};
