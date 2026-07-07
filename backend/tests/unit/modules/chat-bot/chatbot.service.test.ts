import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CustomError } from '../../../../src/common/errors/index.js';
import { ChatbotService } from '../../../../src/modules/chat-bot/services/chatbot.service.js';

type MockRedis = {
  get: ReturnType<typeof vi.fn>;
  set: ReturnType<typeof vi.fn>;
  del: ReturnType<typeof vi.fn>;
};

type MockMemory = {
  getChatHistory: ReturnType<typeof vi.fn>;
  saveChatHistory: ReturnType<typeof vi.fn>;
  clearChatHistory: ReturnType<typeof vi.fn>;
  getCartSession: ReturnType<typeof vi.fn>;
  saveCartSession: ReturnType<typeof vi.fn>;
  clearCartSession: ReturnType<typeof vi.fn>;
};

type MockDependencies = {
  inventoryService: { getInventoriesByStoreId: ReturnType<typeof vi.fn> };
  transactionService: {
    createImportTransaction: ReturnType<typeof vi.fn>;
    createExportTransaction: ReturnType<typeof vi.fn>;
    getCrossSellSuggestions: ReturnType<typeof vi.fn>;
  };
  redis: MockRedis;
  memory: MockMemory;
  llmProvider: { createChatCompletion: ReturnType<typeof vi.fn> };
  auditLogService: { getAuditLogs: ReturnType<typeof vi.fn> };
  storeMemberRepository: { findByIdsWithStore: ReturnType<typeof vi.fn> };
  smartDecisionService: {
    getStoreReorderSuggestions: ReturnType<typeof vi.fn>;
  };
};

const createDependencies = (): MockDependencies => ({
  inventoryService: { getInventoriesByStoreId: vi.fn() },
  transactionService: {
    createImportTransaction: vi.fn(),
    createExportTransaction: vi.fn(),
    getCrossSellSuggestions: vi.fn(),
  },
  redis: {
    get: vi.fn(),
    set: vi.fn(),
    del: vi.fn(),
  },
  memory: {
    getChatHistory: vi.fn(),
    saveChatHistory: vi.fn(),
    clearChatHistory: vi.fn(),
    getCartSession: vi.fn(),
    saveCartSession: vi.fn(),
    clearCartSession: vi.fn(),
  },
  llmProvider: { createChatCompletion: vi.fn() },
  auditLogService: { getAuditLogs: vi.fn() },
  storeMemberRepository: { findByIdsWithStore: vi.fn() },
  smartDecisionService: { getStoreReorderSuggestions: vi.fn() },
});

const createService = (deps: MockDependencies): ChatbotService =>
  new ChatbotService(
    deps.inventoryService as never,
    deps.transactionService as never,
    deps.redis as never,
    deps.memory as never,
    deps.llmProvider as never,
    deps.auditLogService as never,
    deps.storeMemberRepository as never,
    deps.smartDecisionService as never,
  );

const createToolResponse = (
  name: string,
  args: Record<string, unknown> = {},
) => ({
  choices: [
    {
      message: {
        role: 'assistant',
        content: null,
        tool_calls: [
          {
            id: 'tool-1',
            type: 'function',
            function: {
              name,
              arguments: JSON.stringify(args),
            },
          },
        ],
      },
    },
  ],
});

const createInventoryItem = (
  productPackageId: string,
  displayName: string,
  quantity = 10,
) => ({
  quantity,
  productPackage: {
    productPackageId,
    displayName,
    sellingPrice: 15000,
    importPrice: 10000,
    unit: { name: 'box' },
  },
});

describe('ChatbotService', () => {
  let deps: MockDependencies;
  let service: ChatbotService;

  beforeEach(() => {
    vi.clearAllMocks();
    deps = createDependencies();
    service = createService(deps);

    deps.redis.set.mockResolvedValue('OK');
    deps.redis.get.mockResolvedValue(null);
    deps.memory.getChatHistory.mockResolvedValue([]);
    deps.memory.getCartSession.mockResolvedValue(null);
    deps.memory.saveChatHistory.mockResolvedValue(undefined);
    deps.memory.saveCartSession.mockResolvedValue(undefined);
    deps.memory.clearChatHistory.mockResolvedValue(undefined);
    deps.memory.clearCartSession.mockResolvedValue(undefined);
    deps.redis.del.mockResolvedValue(1);
  });

  it('rejects a new message when the Redis processing lock is already held', async () => {
    deps.redis.set.mockResolvedValue(null);

    await expect(
      service.processMessage(
        'store-1',
        'user-1',
        { message: 'low stock' },
        'en',
      ),
    ).rejects.toMatchObject({
      message:
        'Tori is still processing your previous message ⏳ Please wait a moment!',
      status: StatusCodes.TOO_MANY_REQUESTS,
    });

    expect(deps.memory.getChatHistory).not.toHaveBeenCalled();
    expect(deps.redis.del).not.toHaveBeenCalled();
  });

  it('returns a casual response without saving out-of-domain history', async () => {
    deps.llmProvider.createChatCompletion
      .mockResolvedValueOnce({ choices: [{ message: { role: 'assistant' } }] })
      .mockResolvedValueOnce({
        choices: [{ message: { content: 'I can help with inventory.' } }],
      });

    const result = await service.processMessage(
      'store-1',
      'user-1',
      { message: 'hello' },
      'en',
    );

    expect(result).toEqual({
      aiIntent: 'out_of_domain_or_casual',
      botReply: 'I can help with inventory.',
    });
    expect(deps.memory.saveChatHistory).not.toHaveBeenCalled();
    expect(deps.redis.del).toHaveBeenCalledWith('chatbot:lock:store-1:user-1');
  });

  it('handles an empty low-stock inventory and saves assistant history', async () => {
    deps.llmProvider.createChatCompletion
      .mockResolvedValueOnce(createToolResponse('get_low_stock'))
      .mockResolvedValueOnce({
        choices: [{ message: { content: 'Your store is empty.' } }],
      });
    deps.inventoryService.getInventoriesByStoreId.mockResolvedValue({
      items: [],
    });

    const result = await service.processMessage(
      'store-1',
      'user-1',
      { message: 'show low stock' },
      'en',
    );

    expect(deps.inventoryService.getInventoriesByStoreId).toHaveBeenCalledWith(
      'store-1',
      expect.objectContaining({
        limit: 100,
        page: 1,
        sortBy: 'quantity',
        sortOrder: 'asc',
      }),
    );
    expect(result).toEqual({
      aiIntent: 'get_low_stock',
      botReply: 'Your store is empty.',
      data: { totalCount: 0, items: [] },
    });
    expect(deps.memory.saveChatHistory).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      expect.arrayContaining([
        expect.objectContaining({ role: 'user', content: 'show low stock' }),
        expect.objectContaining({
          role: 'assistant',
          content: 'Your store is empty.',
        }),
      ]),
    );
  });

  it('blocks staff users from querying audit logs', async () => {
    deps.llmProvider.createChatCompletion
      .mockResolvedValueOnce(
        createToolResponse('query_audit_logs', {
          action_type: 'delete',
        }),
      )
      .mockResolvedValueOnce({
        choices: [{ message: { content: 'Only managers can view history.' } }],
      });
    deps.storeMemberRepository.findByIdsWithStore.mockResolvedValue({
      role: 'STAFF',
    });

    const result = await service.processMessage(
      'store-1',
      'user-1',
      { message: 'show deleted actions' },
      'en',
    );

    expect(result).toEqual({
      aiIntent: 'unauthorized',
      botReply: 'Only managers can view history.',
    });
    expect(deps.auditLogService.getAuditLogs).not.toHaveBeenCalled();
  });

  it('returns product information for an exact inventory match', async () => {
    const item = createInventoryItem('pkg-1', 'Milk Box', 7);

    deps.llmProvider.createChatCompletion
      .mockResolvedValueOnce(
        createToolResponse('get_product_info', { product_name: 'Milk Box' }),
      )
      .mockResolvedValueOnce({
        choices: [{ message: { content: 'Milk has 7 boxes.' } }],
      });
    deps.inventoryService.getInventoriesByStoreId.mockResolvedValue({
      items: [item],
    });

    const result = await service.processMessage(
      'store-1',
      'user-1',
      { message: 'check Milk Box' },
      'en',
    );

    expect(result).toEqual({
      aiIntent: 'get_product_info',
      botReply: 'Milk has 7 boxes.',
      data: item,
    });
  });

  it('asks the user to choose when product lookup has multiple non-exact matches', async () => {
    const items = [
      createInventoryItem('pkg-1', 'Milk Box'),
      createInventoryItem('pkg-2', 'Milk Bottle'),
    ];

    deps.llmProvider.createChatCompletion
      .mockResolvedValueOnce(
        createToolResponse('get_product_info', { product_name: 'Milk' }),
      )
      .mockResolvedValueOnce({
        choices: [{ message: { content: 'Please choose the exact product.' } }],
      });
    deps.inventoryService.getInventoriesByStoreId.mockResolvedValue({ items });

    const result = await service.processMessage(
      'store-1',
      'user-1',
      { message: 'check Milk' },
      'en',
    );

    expect(result).toEqual({
      aiIntent: 'choose_product',
      botReply: 'Please choose the exact product.',
      data: { originalIntent: 'get_product_info', items },
    });
  });

  it('saves current cart progress and refuses export quantities above stock', async () => {
    deps.llmProvider.createChatCompletion
      .mockResolvedValueOnce(
        createToolResponse('create_export', {
          product_name: 'Milk',
          quantity: 12,
        }),
      )
      .mockResolvedValueOnce({
        choices: [{ message: { content: 'Not enough stock.' } }],
      });
    deps.inventoryService.getInventoriesByStoreId.mockResolvedValue({
      items: [createInventoryItem('pkg-1', 'Milk', 5)],
    });

    const result = await service.processMessage(
      'store-1',
      'user-1',
      { message: 'export 12 Milk' },
      'en',
    );

    expect(result).toEqual({
      aiIntent: 'create_export',
      botReply: 'Not enough stock.',
    });
    expect(deps.memory.saveCartSession).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      { type: 'create_export', items: [] },
    );
  });

  it('allows managers to query audit logs and maps audit log display data', async () => {
    deps.llmProvider.createChatCompletion
      .mockResolvedValueOnce(
        createToolResponse('query_audit_logs', {
          action_type: 'export',
          keyword: 'Milk',
          time_period: 'today',
        }),
      )
      .mockResolvedValueOnce({
        choices: [{ message: { content: 'Found one export.' } }],
      });
    deps.storeMemberRepository.findByIdsWithStore.mockResolvedValue({
      role: 'MANAGER',
    });
    deps.auditLogService.getAuditLogs.mockResolvedValue({
      items: [
        {
          actionType: 'EXPORT',
          entityType: 'Transaction',
          note: 'export transaction',
          newValue: JSON.stringify({ displayName: 'Milk Box' }),
          performedAt: '2026-07-08T01:00:00.000Z',
          user: { fullName: 'Manager One' },
        },
      ],
    });

    const result = await service.processMessage(
      'store-1',
      'user-1',
      { message: 'show exported Milk today' },
      'en',
    );

    expect(deps.auditLogService.getAuditLogs).toHaveBeenCalledWith(
      'store-1',
      expect.objectContaining({
        actionType: 'export',
        search: 'Milk',
        startDate: expect.any(String),
      }),
    );
    expect(result).toEqual({
      aiIntent: 'query_audit_logs',
      botReply: 'Found one export.',
      data: [
        expect.objectContaining({
          action: 'EXPORT',
          target: 'Milk Box',
          userFullName: 'Manager One',
          entityType: 'Transaction',
        }),
      ],
    });
  });

  it('returns general restock suggestions from smart decision analysis', async () => {
    const suggestions = [
      { productName: 'Milk', currentStock: 2, suggestedQuantity: 10 },
      { productName: 'Coffee', currentStock: 1, suggestedQuantity: 8 },
    ];

    deps.llmProvider.createChatCompletion
      .mockResolvedValueOnce(createToolResponse('analyze_restock'))
      .mockResolvedValueOnce({
        choices: [{ message: { content: 'Restock Milk and Coffee.' } }],
      });
    deps.smartDecisionService.getStoreReorderSuggestions.mockResolvedValue(
      suggestions,
    );

    const result = await service.processMessage(
      'store-1',
      'user-1',
      { message: 'analyze restock' },
      'en',
    );

    expect(result).toEqual({
      aiIntent: 'analyze_restock',
      botReply: 'Restock Milk and Coffee.',
      data: { type: 'general_restock', suggestions },
    });
  });

  it('clears stale draft references before creating a transaction draft', async () => {
    deps.llmProvider.createChatCompletion
      .mockResolvedValueOnce(
        createToolResponse('create_import', {
          product_name: 'Milk',
          quantity: 2,
        }),
      )
      .mockResolvedValueOnce({
        choices: [{ message: { content: 'Draft is ready.' } }],
      });
    deps.redis.get
      .mockResolvedValueOnce('draft-old')
      .mockResolvedValueOnce(null);
    deps.inventoryService.getInventoriesByStoreId.mockResolvedValue({
      items: [
        {
          quantity: 10,
          productPackage: {
            productPackageId: 'pkg-1',
            displayName: 'Milk',
            sellingPrice: 15000,
            importPrice: 10000,
            unit: { name: 'box' },
          },
        },
      ],
    });

    const result = await service.processMessage(
      'store-1',
      'user-1',
      { message: 'import 2 Milk' },
      'en',
    );

    expect(result.aiIntent).toBe('confirm_import');
    expect(deps.redis.del).toHaveBeenCalledWith(
      'chatbot:draft:ref:store-1:user-1',
    );
    expect(deps.memory.saveCartSession).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      expect.objectContaining({
        type: 'create_import',
        items: [
          {
            productPackageId: 'pkg-1',
            displayName: 'Milk',
            quantity: 2,
            unitPrice: 10000,
          },
        ],
      }),
    );
  });

  it('throws gone when confirming an expired draft action', async () => {
    deps.redis.get.mockResolvedValue(null);

    await expect(
      service.confirmDraftAction('draft-1', true, 'store-1', 'user-1', 'en'),
    ).rejects.toMatchObject({
      message: 'The request has expired or does not exist (over 5 minutes).',
      status: StatusCodes.GONE,
    });
  });

  it('forbids confirming another store or user draft action', async () => {
    deps.redis.get.mockResolvedValue(
      JSON.stringify({
        id: 'draft-1',
        type: 'create_export',
        storeId: 'store-2',
        userId: 'user-1',
        payload: { note: 'Export', items: [] },
        createdAt: Date.now(),
      }),
    );

    await expect(
      service.confirmDraftAction('draft-1', true, 'store-1', 'user-1', 'en'),
    ).rejects.toMatchObject({
      message: 'Forbidden',
      status: StatusCodes.FORBIDDEN,
    });
  });

  it('cancels a draft and clears chat, cart, draft, and draft reference state', async () => {
    deps.redis.get.mockResolvedValue(
      JSON.stringify({
        id: 'draft-1',
        type: 'create_export',
        storeId: 'store-1',
        userId: 'user-1',
        payload: { note: 'Export', items: [] },
        createdAt: Date.now(),
      }),
    );
    deps.memory.getChatHistory.mockResolvedValue([
      { role: 'user', content: 'export 2 milk' },
    ]);
    deps.llmProvider.createChatCompletion.mockResolvedValue({
      choices: [{ message: { content: 'Cancelled.' } }],
    });

    await expect(
      service.confirmDraftAction('draft-1', false, 'store-1', 'user-1', 'en'),
    ).resolves.toBe('Cancelled.');

    expect(
      deps.transactionService.createExportTransaction,
    ).not.toHaveBeenCalled();
    expect(deps.memory.clearChatHistory).toHaveBeenCalledWith(
      'store-1',
      'user-1',
    );
    expect(deps.memory.clearCartSession).toHaveBeenCalledWith(
      'store-1',
      'user-1',
    );
    expect(deps.redis.del).toHaveBeenCalledWith('chatbot:draft:draft-1');
    expect(deps.redis.del).toHaveBeenCalledWith(
      'chatbot:draft:ref:store-1:user-1',
    );
  });

  it('confirms an import draft and clears temporary state', async () => {
    const payload = {
      note: 'Import',
      items: [{ productPackageId: 'pkg-1', quantity: 2, unitPrice: 10000 }],
    };

    deps.redis.get.mockResolvedValue(
      JSON.stringify({
        id: 'draft-1',
        type: 'create_import',
        storeId: 'store-1',
        userId: 'user-1',
        payload,
        createdAt: Date.now(),
      }),
    );
    deps.memory.getChatHistory.mockResolvedValue([]);
    deps.llmProvider.createChatCompletion.mockResolvedValue({
      choices: [{ message: { content: 'Recorded.' } }],
    });

    await expect(
      service.confirmDraftAction('draft-1', true, 'store-1', 'user-1', 'en'),
    ).resolves.toBe('Recorded.');

    expect(
      deps.transactionService.createImportTransaction,
    ).toHaveBeenCalledWith('store-1', 'user-1', payload);
    expect(deps.memory.clearChatHistory).toHaveBeenCalledWith(
      'store-1',
      'user-1',
    );
    expect(deps.memory.clearCartSession).toHaveBeenCalledWith(
      'store-1',
      'user-1',
    );
  });

  it('wraps unexpected processMessage failures as AI system errors and releases the lock', async () => {
    deps.llmProvider.createChatCompletion.mockRejectedValue(
      new Error('network down'),
    );

    await expect(
      service.processMessage('store-1', 'user-1', { message: 'hello' }, 'en'),
    ).rejects.toBeInstanceOf(CustomError);
    await expect(
      service.processMessage('store-1', 'user-1', { message: 'hello' }, 'en'),
    ).rejects.toMatchObject({
      message: 'Connection to the AI model system failed.',
      status: StatusCodes.INTERNAL_SERVER_ERROR,
    });

    expect(deps.redis.del).toHaveBeenCalledWith('chatbot:lock:store-1:user-1');
  });

  it('clears chat history, cart session, and draft reference for a user', async () => {
    await service.clearChatHistory('store-1', 'user-1');

    expect(deps.memory.clearChatHistory).toHaveBeenCalledWith(
      'store-1',
      'user-1',
    );
    expect(deps.memory.clearCartSession).toHaveBeenCalledWith(
      'store-1',
      'user-1',
    );
    expect(deps.redis.del).toHaveBeenCalledWith(
      'chatbot:draft:ref:store-1:user-1',
    );
  });
});
