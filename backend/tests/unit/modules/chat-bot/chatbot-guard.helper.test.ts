import { describe, expect, it } from 'vitest';

import { ChatbotGuardHelper } from '../../../../src/modules/chat-bot/services/helpers/chatbot-guard.helper.js';

describe('ChatbotGuardHelper', () => {
  it('blocks product lookup when the product name is missing', () => {
    expect(
      ChatbotGuardHelper.isToolCallEligible(
        'get_product_info',
        {},
        'check product',
        'en',
      ),
    ).toMatchObject({ isValid: false });
  });

  it('blocks transaction tools without product and quantity information', () => {
    expect(
      ChatbotGuardHelper.isToolCallEligible(
        'create_export',
        { product_name: 'Milk' },
        'export milk',
        'en',
      ),
    ).toMatchObject({ isValid: false });
  });

  it('blocks non-positive product quantities', () => {
    expect(
      ChatbotGuardHelper.isToolCallEligible(
        'create_import',
        { products: [{ product_name: 'Milk', quantity: 0 }] },
        'import 0 milk',
        'en',
      ),
    ).toEqual({
      isValid: false,
      reason:
        '[SYSTEM INSTRUCTION]: Inform the user that the quantity must be greater than 0.',
    });
  });

  it('allows valid transaction requests', () => {
    expect(
      ChatbotGuardHelper.isToolCallEligible(
        'create_import',
        { product_name: 'Milk', quantity: 2 },
        'import 2 milk',
        'en',
      ),
    ).toEqual({ isValid: true });
  });
});
