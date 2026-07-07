import { describe, expect, it } from 'vitest';

import {
  registerTokenBodySchema,
  removeTokenBodySchema,
} from '../../../../src/modules/notification/validators/notification.validator.js';

describe('notification validators', () => {
  describe('registerTokenBodySchema', () => {
    it('accepts a valid token and trims whitespace', () => {
      expect(registerTokenBodySchema.parse({ token: ' token-1 ' })).toEqual({
        token: 'token-1',
      });
    });

    it('rejects missing, non-string, empty, and whitespace tokens', () => {
      expect(() => registerTokenBodySchema.parse({})).toThrow();
      expect(() => registerTokenBodySchema.parse({ token: 123 })).toThrow();
      expect(() => registerTokenBodySchema.parse({ token: '' })).toThrow(
        'FCM Token is required',
      );
      expect(() => registerTokenBodySchema.parse({ token: '   ' })).toThrow(
        'FCM Token is required',
      );
    });
  });

  describe('removeTokenBodySchema', () => {
    it('accepts a valid token and trims whitespace', () => {
      expect(removeTokenBodySchema.parse({ token: ' token-1 ' })).toEqual({
        token: 'token-1',
      });
    });

    it('rejects missing, non-string, empty, and whitespace tokens', () => {
      expect(() => removeTokenBodySchema.parse({})).toThrow();
      expect(() => removeTokenBodySchema.parse({ token: false })).toThrow();
      expect(() => removeTokenBodySchema.parse({ token: '' })).toThrow(
        'FCM Token is required',
      );
      expect(() => removeTokenBodySchema.parse({ token: '   ' })).toThrow(
        'FCM Token is required',
      );
    });
  });
});
