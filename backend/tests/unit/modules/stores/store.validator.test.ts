import { describe, expect, it } from 'vitest';

import {
  createStoreBodySchema,
  joinStoreBodySchema,
  paramsSchema,
  updateStoreBodySchema,
} from '../../../../src/modules/stores/store.validator.js';

describe('store validators', () => {
  describe('paramsSchema', () => {
    it('accepts a valid UUID storeId', () => {
      const result = paramsSchema.parse({
        storeId: '550e8400-e29b-41d4-a716-446655440000',
      });

      expect(result.storeId).toBe('550e8400-e29b-41d4-a716-446655440000');
    });

    it('rejects invalid storeId format', () => {
      expect(() => paramsSchema.parse({ storeId: 'not-a-uuid' })).toThrow(
        'Invalid storeId',
      );
    });
  });

  describe('createStoreBodySchema', () => {
    it('accepts valid store creation payload and trims strings', () => {
      const result = createStoreBodySchema.parse({
        name: ' Main Store ',
        address: ' 123 Market Street ',
        timezone: ' Asia/Ho_Chi_Minh ',
        currencyCode: ' VND ',
      });

      expect(result).toEqual({
        name: 'Main Store',
        address: '123 Market Street',
        timezone: 'Asia/Ho_Chi_Minh',
        currencyCode: 'VND',
      });
    });

    it('rejects a missing store name', () => {
      expect(() =>
        createStoreBodySchema.parse({
          currencyCode: 'VND',
        }),
      ).toThrow();
    });

    it('rejects an empty store name after trimming', () => {
      expect(() =>
        createStoreBodySchema.parse({
          name: '   ',
          currencyCode: 'VND',
        }),
      ).toThrow('Store name is required');
    });

    it('rejects store names longer than 100 characters', () => {
      expect(() =>
        createStoreBodySchema.parse({
          name: 'a'.repeat(101),
          currencyCode: 'VND',
        }),
      ).toThrow('Store name must not exceed 100 characters');
    });

    it('accepts nullable optional address and timezone', () => {
      const result = createStoreBodySchema.parse({
        name: 'Main Store',
        address: null,
        timezone: null,
        currencyCode: 'VND',
      });

      expect(result.address).toBeNull();
      expect(result.timezone).toBeNull();
    });

    it('rejects a non-string currency code', () => {
      expect(() =>
        createStoreBodySchema.parse({
          name: 'Main Store',
          currencyCode: 123,
        }),
      ).toThrow();
    });
  });

  describe('updateStoreBodySchema', () => {
    it('accepts a valid partial update payload', () => {
      const result = updateStoreBodySchema.parse({
        name: ' Updated Store ',
      });

      expect(result.name).toBe('Updated Store');
    });

    it('rejects an empty update payload', () => {
      expect(() => updateStoreBodySchema.parse({})).toThrow(
        'Update request body cannot be empty',
      );
    });

    it('rejects an empty updated name after trimming', () => {
      expect(() =>
        updateStoreBodySchema.parse({
          name: '   ',
        }),
      ).toThrow('Store name must not be empty');
    });

    it('currently accepts null currency code', () => {
      const result = updateStoreBodySchema.parse({
        currencyCode: null,
      });

      expect(result.currencyCode).toBeNull();
    });

    it('rejects address longer than 255 characters', () => {
      expect(() =>
        updateStoreBodySchema.parse({
          address: 'a'.repeat(256),
        }),
      ).toThrow('Address must not exceed 255 characters');
    });
  });

  describe('joinStoreBodySchema', () => {
    it('accepts and trims an invite code', () => {
      const result = joinStoreBodySchema.parse({
        inviteCode: ' aaaa-bbbb-cccc-dddd ',
      });

      expect(result.inviteCode).toBe('aaaa-bbbb-cccc-dddd');
    });

    it('rejects an empty invite code', () => {
      expect(() =>
        joinStoreBodySchema.parse({
          inviteCode: '   ',
        }),
      ).toThrow('Invite code is required');
    });
  });
});
