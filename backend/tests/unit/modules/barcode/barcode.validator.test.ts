import { describe, expect, it } from 'vitest';

import {
  confirmBarcodeMappingBodySchema,
  createBarcodeMappingBodySchema,
  createBarcodeMappingParamsSchema,
  removeBarcodeMappingParamsSchema,
  scanBarcodeBodySchema,
} from '../../../../src/modules/barcode/barcodes.validator.js';

const uuid = '550e8400-e29b-41d4-a716-446655440000';

describe('barcode validators', () => {
  describe('scanBarcodeBodySchema', () => {
    it('accepts a valid barcode and trims whitespace', () => {
      const result = scanBarcodeBodySchema.parse({
        barcode: ' 8938505974192 ',
        type: 'ean',
      });

      expect(result).toEqual({
        barcode: '8938505974192',
        type: 'ean',
      });
    });

    it('rejects short, long, and unsupported barcode values', () => {
      expect(() => scanBarcodeBodySchema.parse({ barcode: '12345' })).toThrow(
        'Barcode value is invalid',
      );
      expect(() =>
        scanBarcodeBodySchema.parse({ barcode: '1'.repeat(51) }),
      ).toThrow('Barcode value is invalid');
      expect(() =>
        scanBarcodeBodySchema.parse({ barcode: '123456', type: 'isbn' }),
      ).toThrow();
    });
  });

  describe('confirmBarcodeMappingBodySchema', () => {
    it('accepts a valid confirm payload', () => {
      const result = confirmBarcodeMappingBodySchema.parse({
        barcode: ' 123456789012 ',
        productPackageId: uuid,
        type: 'upc',
      });

      expect(result).toEqual({
        barcode: '123456789012',
        productPackageId: uuid,
        type: 'upc',
      });
    });

    it('rejects missing barcode and invalid productPackageId', () => {
      expect(() =>
        confirmBarcodeMappingBodySchema.parse({ productPackageId: uuid }),
      ).toThrow();
      expect(() =>
        confirmBarcodeMappingBodySchema.parse({
          barcode: '123456',
          productPackageId: 'package-1',
        }),
      ).toThrow('Invalid productPackageId');
    });
  });

  describe('package barcode mapping schemas', () => {
    it('accepts create params and body', () => {
      expect(
        createBarcodeMappingParamsSchema.parse({ productPackageId: uuid }),
      ).toEqual({ productPackageId: uuid });
      expect(
        createBarcodeMappingBodySchema.parse({
          barcode: ' 123456789012 ',
          type: 'code128',
        }),
      ).toEqual({
        barcode: '123456789012',
        type: 'code128',
      });
    });

    it('accepts remove params and trims barcode', () => {
      const result = removeBarcodeMappingParamsSchema.parse({
        productPackageId: uuid,
        barcode: ' 123456789012 ',
      });

      expect(result).toEqual({
        productPackageId: uuid,
        barcode: '123456789012',
      });
    });

    it('rejects invalid mapping params', () => {
      expect(() =>
        createBarcodeMappingParamsSchema.parse({ productPackageId: 'bad' }),
      ).toThrow('Invalid productPackageId');
      expect(() =>
        removeBarcodeMappingParamsSchema.parse({
          productPackageId: uuid,
          barcode: '   ',
        }),
      ).toThrow('Barcode value is invalid');
    });
  });
});
