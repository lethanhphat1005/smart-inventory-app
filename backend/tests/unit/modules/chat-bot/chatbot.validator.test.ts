import { describe, expect, it } from 'vitest';

import {
  chatPayloadBodySchema,
  confirmActionBodySchema,
} from '../../../../src/modules/chat-bot/chatbot.validator.js';

describe('chatbot validators', () => {
  describe('chatPayloadBodySchema', () => {
    it('accepts and trims a valid chat message', () => {
      const result = chatPayloadBodySchema.parse({ message: '  check milk  ' });

      expect(result).toEqual({ message: 'check milk' });
    });

    it('rejects empty and whitespace-only messages', () => {
      expect(() => chatPayloadBodySchema.parse({ message: '' })).toThrow(
        'Message cannot be empty',
      );
      expect(() => chatPayloadBodySchema.parse({ message: '   ' })).toThrow(
        'Message cannot be empty',
      );
    });

    it('rejects messages longer than 100 characters', () => {
      expect(() =>
        chatPayloadBodySchema.parse({ message: 'a'.repeat(101) }),
      ).toThrow('Message cannot exceed 100 characters');
    });

    it('rejects missing or non-string message values', () => {
      expect(chatPayloadBodySchema.safeParse({}).success).toBe(false);
      expect(chatPayloadBodySchema.safeParse({ message: 123 }).success).toBe(
        false,
      );
    });
  });

  describe('confirmActionBodySchema', () => {
    it('accepts and trims a draft action confirmation', () => {
      const result = confirmActionBodySchema.parse({
        draftActionId: '  draft-1  ',
        isConfirmed: true,
      });

      expect(result).toEqual({ draftActionId: 'draft-1', isConfirmed: true });
    });

    it('rejects empty draft IDs and non-boolean confirmation flags', () => {
      expect(() =>
        confirmActionBodySchema.parse({
          draftActionId: '   ',
          isConfirmed: true,
        }),
      ).toThrow('Draft action ID is required');
      expect(
        confirmActionBodySchema.safeParse({
          draftActionId: 'draft-1',
          isConfirmed: 'true',
        }).success,
      ).toBe(false);
    });
  });
});
