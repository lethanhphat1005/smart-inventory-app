import { z } from 'zod';

import { validateSchema } from '../../common/utils/index.js';

import type { NextFunction, Request, Response } from 'express';

const barcodeTypeSchema = z.enum(['upc', 'ean', 'code128', 'qr']);

export const scanBarcodeBodySchema = z.object({
  barcode: z
    .string()
    .trim()
    .min(6, 'Barcode value is invalid')
    .max(50, 'Barcode value is invalid'),
  type: barcodeTypeSchema.optional(),
});

export const confirmBarcodeMappingBodySchema = z.object({
  barcode: z
    .string()
    .trim()
    .min(6, 'Barcode value is invalid')
    .max(50, 'Barcode value is invalid'),
  productPackageId: z.uuid('Invalid productPackageId'),
  type: barcodeTypeSchema.optional(),
});

export const createProductPackageBarcodeMappingParamsSchema = z.object({
  productPackageId: z.uuid('Invalid productPackageId'),
});

export const createProductPackageBarcodeMappingBodySchema = z.object({
  barcode: z
    .string()
    .trim()
    .min(6, 'Barcode value is invalid')
    .max(50, 'Barcode value is invalid'),
  type: barcodeTypeSchema.optional(),
});

export const removeProductPackageBarcodeMappingParamsSchema = z.object({
  productPackageId: z.uuid('Invalid productPackageId'),
  barcode: z
    .string()
    .trim()
    .min(6, 'Barcode value is invalid')
    .max(50, 'Barcode value is invalid'),
});

export const validateCreateProductPackageBarcodeMapping = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(
    createProductPackageBarcodeMappingParamsSchema,
    req.params,
  );

  req.body = validateSchema(
    createProductPackageBarcodeMappingBodySchema,
    req.body,
  );

  next();
};

export const validateRemoveProductPackageBarcodeMapping = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(
    removeProductPackageBarcodeMappingParamsSchema,
    req.params,
  );

  next();
};

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
