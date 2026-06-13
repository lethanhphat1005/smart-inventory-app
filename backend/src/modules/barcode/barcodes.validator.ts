import { z } from 'zod';

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

export const createBarcodeMappingParamsSchema = z.object({
  productPackageId: z.uuid('Invalid productPackageId'),
});

export const createBarcodeMappingBodySchema = z.object({
  barcode: z
    .string()
    .trim()
    .min(6, 'Barcode value is invalid')
    .max(50, 'Barcode value is invalid'),
  type: barcodeTypeSchema.optional(),
});

export const removeBarcodeMappingParamsSchema = z.object({
  productPackageId: z.uuid('Invalid productPackageId'),
  barcode: z
    .string()
    .trim()
    .min(6, 'Barcode value is invalid')
    .max(50, 'Barcode value is invalid'),
});
