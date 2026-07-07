import { describe, expect, it } from 'vitest';

import {
  paramsSchema,
  updateUserProfileBodySchema,
} from '../../../../src/modules/user-profile/validator/user-profile.validator.js';

const uuid = '550e8400-e29b-41d4-a716-446655440000';

describe('user profile validators', () => {
  describe('paramsSchema', () => {
    it('accepts a valid UUID userId', () => {
      const result = paramsSchema.parse({ userId: uuid });

      expect(result.userId).toBe(uuid);
    });

    it('rejects invalid userId format', () => {
      expect(() => paramsSchema.parse({ userId: 'user-1' })).toThrow();
    });
  });

  describe('updateUserProfileBodySchema', () => {
    it('accepts a partial update and trims strings', () => {
      const result = updateUserProfileBodySchema.parse({
        fullName: ' Updated User ',
        address: ' 123 Main Street ',
        phone: ' 1234567890 ',
      });

      expect(result).toEqual({
        fullName: 'Updated User',
        address: '123 Main Street',
        phone: '1234567890',
      });
    });

    it('accepts omitted optional fields', () => {
      expect(updateUserProfileBodySchema.parse({})).toEqual({});
    });

    it('rejects invalid field types', () => {
      expect(() =>
        updateUserProfileBodySchema.parse({ fullName: 123 }),
      ).toThrow();
      expect(() => updateUserProfileBodySchema.parse({ phone: null })).toThrow();
    });

    it('rejects values longer than field limits', () => {
      expect(() =>
        updateUserProfileBodySchema.parse({ fullName: 'a'.repeat(256) }),
      ).toThrow();
      expect(() =>
        updateUserProfileBodySchema.parse({ address: 'a'.repeat(256) }),
      ).toThrow();
      expect(() =>
        updateUserProfileBodySchema.parse({ phone: '1'.repeat(21) }),
      ).toThrow();
    });
  });
});
