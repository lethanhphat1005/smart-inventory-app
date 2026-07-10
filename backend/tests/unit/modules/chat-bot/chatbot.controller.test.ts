import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ChatbotController } from '../../../../src/modules/chat-bot/chatbot.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

import type { StoreContext } from '../../../../src/common/types/authorize-request.type.js';

type MockChatbotService = {
  processMessage: ReturnType<typeof vi.fn>;
  confirmDraftAction: ReturnType<typeof vi.fn>;
  clearChatHistory: ReturnType<typeof vi.fn>;
};

const user = {
  userId: 'user-1',
  authUserId: 'auth-user-1',
  email: 'user@example.com',
};

const storeContext: StoreContext = {
  storeId: 'store-1',
  role: 'manager',
};

const createService = (): MockChatbotService => ({
  processMessage: vi.fn(),
  confirmDraftAction: vi.fn(),
  clearChatHistory: vi.fn(),
});

describe('ChatbotController', () => {
  let service: MockChatbotService;
  let controller: ChatbotController;

  beforeEach(() => {
    service = createService();
    controller = new ChatbotController(service as never);
  });

  it('processChat uses store context, authenticated user, payload, and header locale', async () => {
    const result = { aiIntent: 'get_low_stock', botReply: 'reply' };
    const req = createRequest({
      user,
      storeContext,
      headers: { 'x-locale': 'en' },
      body: { message: 'low stock' },
    });
    const res = createResponse<typeof result>();

    service.processMessage.mockResolvedValue(result);

    await controller.processChat(req, res);

    expect(service.processMessage).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      { message: 'low stock' },
      'en',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({ success: true, data: result });
  });

  it('processChat falls back to payload locale and then Vietnamese', async () => {
    const req = createRequest({
      user,
      storeContext,
      headers: {},
      body: { message: 'xin chao', locale: 'en' },
    });
    const res = createResponse();

    service.processMessage.mockResolvedValue({
      aiIntent: 'out_of_domain_or_casual',
      botReply: 'reply',
    });

    await controller.processChat(req, res);

    expect(service.processMessage).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      { message: 'xin chao', locale: 'en' },
      'en',
    );
  });

  it('confirmAction delegates draft confirmation with locale default', async () => {
    const req = createRequest({
      user,
      storeContext,
      headers: {},
      body: { draftActionId: 'draft-1', isConfirmed: true },
    });
    const res = createResponse<{ message: string }>();

    service.confirmDraftAction.mockResolvedValue('confirmed');

    await controller.confirmAction(req, res);

    expect(service.confirmDraftAction).toHaveBeenCalledWith(
      'draft-1',
      true,
      'store-1',
      'user-1',
      'vi',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: { message: 'confirmed' },
    });
  });

  it('clearHistory clears both chat history and temporary sessions', async () => {
    const req = createRequest({ user, storeContext });
    const res = createResponse<{ message: string }>();

    await controller.clearHistory(req, res);

    expect(service.clearChatHistory).toHaveBeenCalledWith('store-1', 'user-1');
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: {
        message: 'Chat history and temporary session cleared successfully ✨',
      },
    });
  });
});
