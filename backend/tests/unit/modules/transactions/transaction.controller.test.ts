import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { TransactionController } from '../../../../src/modules/transactions/transaction.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

type MockTransactionService = {
  getTransactionsByStoreId: ReturnType<typeof vi.fn>;
  getTransactionById: ReturnType<typeof vi.fn>;
  createImportTransaction: ReturnType<typeof vi.fn>;
  createExportTransaction: ReturnType<typeof vi.fn>;
};

const createMockTransactionService = (): MockTransactionService => ({
  getTransactionsByStoreId: vi.fn(),
  getTransactionById: vi.fn(),
  createImportTransaction: vi.fn(),
  createExportTransaction: vi.fn(),
});

describe('TransactionController', () => {
  let transactionService: MockTransactionService;
  let transactionController: TransactionController;

  beforeEach(() => {
    transactionService = createMockTransactionService();
    transactionController = new TransactionController(
      transactionService as never,
    );
  });

  it('returns transactions for the request store context', async () => {
    const transactions = {
      items: [],
      meta: {
        page: 1,
        limit: 50,
        totalItems: 0,
        totalPages: 0,
      },
    };
    const query = {
      page: 1,
      limit: 50,
      sortBy: 'createdAt',
      sortOrder: 'desc',
    };
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
    });
    const res = createResponse({ validatedQuery: query });

    transactionService.getTransactionsByStoreId.mockResolvedValue(transactions);

    await transactionController.getTransactions(req, res);

    expect(transactionService.getTransactionsByStoreId).toHaveBeenCalledWith(
      'store-1',
      query,
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: transactions,
    });
  });

  it('returns a transaction detail by path id for the current store', async () => {
    const transaction = {
      transactionId: 'transaction-1',
      items: [],
    };
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
      params: {
        transactionId: 'transaction-1',
      },
    });
    const res = createResponse();

    transactionService.getTransactionById.mockResolvedValue(transaction);

    await transactionController.getTransactionById(req, res);

    expect(transactionService.getTransactionById).toHaveBeenCalledWith(
      'store-1',
      'transaction-1',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: transaction,
    });
  });

  it('creates an import transaction for the authenticated user and current store', async () => {
    const payload = {
      items: [{ productPackageId: 'package-1', quantity: 1, unitPrice: 1000 }],
    };
    const transaction = {
      transactionId: 'transaction-1',
      priceUpdateSuggestions: [],
    };
    const req = createRequest({
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
      body: payload,
    });
    const res = createResponse();

    transactionService.createImportTransaction.mockResolvedValue(transaction);

    await transactionController.createImportTransaction(req, res);

    expect(transactionService.createImportTransaction).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      payload,
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.CREATED);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: transaction,
    });
  });

  it('creates an export transaction for the authenticated user and current store', async () => {
    const payload = {
      items: [{ productPackageId: 'package-1', quantity: 1, unitPrice: 1000 }],
    };
    const transaction = {
      transactionId: 'transaction-2',
      items: payload.items,
    };
    const req = createRequest({
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
      body: payload,
    });
    const res = createResponse();

    transactionService.createExportTransaction.mockResolvedValue(transaction);

    await transactionController.createExportTransaction(req, res);

    expect(transactionService.createExportTransaction).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      payload,
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.CREATED);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: transaction,
    });
  });
});
