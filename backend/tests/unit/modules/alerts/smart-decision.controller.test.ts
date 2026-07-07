import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { SmartDecisionController } from '../../../../src/modules/alerts/controllers/smart-decision.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

import type { ListReorderSuggestionResponseDto } from '../../../../src/modules/alerts/dto/smart-decision.dto.js';

type MockSmartDecisionService = {
  getStoreReorderSuggestions: ReturnType<typeof vi.fn>;
};

const createMockSmartDecisionService = (): MockSmartDecisionService => ({
  getStoreReorderSuggestions: vi.fn(),
});

describe('SmartDecisionController', () => {
  let smartDecisionService: MockSmartDecisionService;
  let controller: SmartDecisionController;

  beforeEach(() => {
    smartDecisionService = createMockSmartDecisionService();
    controller = new SmartDecisionController(smartDecisionService as never);
  });

  it('returns reorder suggestions for the current store context', async () => {
    const payload: ListReorderSuggestionResponseDto = [
      {
        productId: 'product-1',
        productName: 'Milk 1L',
        currentStock: 1,
        suggestedQuantity: 47,
        suggestedThreshold: 9,
        reason: 'Based on an average sales velocity of 3.0 units/day.',
      },
    ];
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'manager',
      },
    });
    const res = createResponse<ListReorderSuggestionResponseDto>();

    smartDecisionService.getStoreReorderSuggestions.mockResolvedValue(payload);

    await controller.getReorderSuggestions(req, res);

    expect(
      smartDecisionService.getStoreReorderSuggestions,
    ).toHaveBeenCalledWith('store-1');
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: payload,
    });
  });

  it('throws when store context is missing', async () => {
    const req = createRequest({});
    const res = createResponse<ListReorderSuggestionResponseDto>();

    await expect(controller.getReorderSuggestions(req, res)).rejects.toThrow(
      'Cannot get store ID',
    );
    expect(
      smartDecisionService.getStoreReorderSuggestions,
    ).not.toHaveBeenCalled();
  });

  it('propagates service failures to async error handling', async () => {
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
    });
    const res = createResponse<ListReorderSuggestionResponseDto>();

    smartDecisionService.getStoreReorderSuggestions.mockRejectedValue(
      new Error('service failed'),
    );

    await expect(controller.getReorderSuggestions(req, res)).rejects.toThrow(
      'service failed',
    );
  });
});
