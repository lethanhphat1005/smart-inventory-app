import { describe, expect, it } from 'vitest';

import {
  getStoreMembersQuerySchema,
  paramsSchema,
  updateStoreMemberRoleBodySchema,
} from '../../../../src/modules/store-member/validator/store-member.validator.js';

describe('store-member validators', () => {
  describe('paramsSchema', () => {
    it('accepts a valid UUID userId', () => {
      const result = paramsSchema.parse({
        userId: '550e8400-e29b-41d4-a716-446655440000',
      });

      expect(result.userId).toBe('550e8400-e29b-41d4-a716-446655440000');
    });

    it('rejects invalid userId format', () => {
      expect(() => paramsSchema.parse({ userId: 'not-a-uuid' })).toThrow();
    });

    it('rejects missing userId', () => {
      expect(() => paramsSchema.parse({})).toThrow();
    });
  });

  describe('updateStoreMemberRoleBodySchema', () => {
    it('accepts manager and staff roles', () => {
      expect(
        updateStoreMemberRoleBodySchema.parse({ role: 'manager' }),
      ).toEqual({
        role: 'manager',
      });
      expect(updateStoreMemberRoleBodySchema.parse({ role: 'staff' })).toEqual({
        role: 'staff',
      });
    });

    it('rejects owner role changes through the public payload', () => {
      expect(() =>
        updateStoreMemberRoleBodySchema.parse({ role: 'owner' }),
      ).toThrow();
    });

    it('rejects missing or non-string role values', () => {
      expect(() => updateStoreMemberRoleBodySchema.parse({})).toThrow();
      expect(() =>
        updateStoreMemberRoleBodySchema.parse({ role: 123 }),
      ).toThrow();
    });
  });

  describe('getStoreMembersQuerySchema', () => {
    it('applies default pagination values', () => {
      const result = getStoreMembersQuerySchema.parse({});

      expect(result).toEqual({ page: 1, limit: 10 });
    });

    it('coerces valid pagination query strings', () => {
      const result = getStoreMembersQuerySchema.parse({
        page: '2',
        limit: '25',
        search: '  user@example.com  ',
      });

      expect(result).toEqual({
        page: 2,
        limit: 25,
        search: 'user@example.com',
      });
    });

    it('rejects invalid pagination boundaries', () => {
      expect(() => getStoreMembersQuerySchema.parse({ page: '0' })).toThrow();
      expect(() =>
        getStoreMembersQuerySchema.parse({ limit: '101' }),
      ).toThrow();
    });
  });
});
