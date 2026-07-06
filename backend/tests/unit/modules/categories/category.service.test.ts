import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CategoriesService } from '../../../../src/modules/categories/category.service.js';

import type { CategoryResponseDto } from '../../../../src/modules/categories/category.dto.js';

const categoryMocks = vi.hoisted(() => {
  const transactionClient = {
    category: {
      create: vi.fn(),
      update: vi.fn(),
      delete: vi.fn(),
    },
    product: {
      updateMany: vi.fn(),
    },
    auditLog: {
      create: vi.fn(),
    },
    hidedDefault: {
      create: vi.fn(),
      delete: vi.fn(),
    },
  };

  const transactionMock = vi.fn(
    async <T>(callback: (tx: typeof transactionClient) => Promise<T>) => {
      return await callback(transactionClient);
    },
  );

  return {
    productService: {
      getProductsByCategory: vi.fn(),
    },
    transactionClient,
    transactionMock,
  };
});

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: {
    $transaction: categoryMocks.transactionMock,
  },
}));

vi.mock('../../../../src/modules/products/index.js', () => ({
  productService: categoryMocks.productService,
  ProductRepository: class MockProductRepository {
    constructor(private readonly db: typeof categoryMocks.transactionClient) {}

    async uncategorizeMany(
      storeId: string,
      categoryId: string,
      uncategorizedId: string,
    ): Promise<number> {
      const result = await this.db.product.updateMany({
        where: {
          categoryId,
          storeId,
        },
        data: {
          categoryId: uncategorizedId,
        },
      });

      return result.count as number;
    }
  },
}));

vi.mock('../../../../src/modules/audit-log/index.js', () => ({
  AuditLogRepository: class MockAuditLogRepository {
    constructor(private readonly db: typeof categoryMocks.transactionClient) {}

    async createLog(data: unknown): Promise<void> {
      await this.db.auditLog.create({ data });
    }
  },
}));

type MockCategoryRepository = {
  findAll: ReturnType<typeof vi.fn>;
  findById: ReturnType<typeof vi.fn>;
  checkDuplicateName: ReturnType<typeof vi.fn>;
  createOne: ReturnType<typeof vi.fn>;
  updateOne: ReturnType<typeof vi.fn>;
  getUncategorizedId: ReturnType<typeof vi.fn>;
  deleteCustomCategory: ReturnType<typeof vi.fn>;
};

type MockHiddenDefaultRepository = {
  findManyByStore: ReturnType<typeof vi.fn>;
  hideOne: ReturnType<typeof vi.fn>;
  unhideOne: ReturnType<typeof vi.fn>;
  isDefaultOneVisible: ReturnType<typeof vi.fn>;
};

const createMockCategoryRepository = (): MockCategoryRepository => ({
  findAll: vi.fn(),
  findById: vi.fn(),
  checkDuplicateName: vi.fn(),
  createOne: vi.fn(),
  updateOne: vi.fn(),
  getUncategorizedId: vi.fn(),
  deleteCustomCategory: vi.fn(),
});

const createMockHiddenDefaultRepository = (): MockHiddenDefaultRepository => ({
  findManyByStore: vi.fn(),
  hideOne: vi.fn(),
  unhideOne: vi.fn(),
  isDefaultOneVisible: vi.fn(),
});

const categoryFixture = (
  overrides: Partial<CategoryResponseDto> = {},
): CategoryResponseDto => ({
  categoryId: 'category-1',
  name: 'Dairy',
  description: null,
  isDefault: false,
  storeId: 'store-1',
  ...overrides,
});

describe('CategoriesService', () => {
  let categoryRepository: MockCategoryRepository;
  let hiddenDefaultRepository: MockHiddenDefaultRepository;
  let categoriesService: CategoriesService;

  beforeEach(() => {
    vi.clearAllMocks();

    categoryRepository = createMockCategoryRepository();
    hiddenDefaultRepository = createMockHiddenDefaultRepository();
    categoriesService = new CategoriesService(
      categoryRepository as never,
      hiddenDefaultRepository as never,
    );

    categoryRepository.getUncategorizedId.mockResolvedValue('uncategorized');
    categoryMocks.transactionClient.category.create.mockResolvedValue(
      categoryFixture({ categoryId: 'category-created' }),
    );
    categoryMocks.transactionClient.category.update.mockResolvedValue(
      categoryFixture({ name: 'Frozen' }),
    );
    categoryMocks.transactionClient.product.updateMany.mockResolvedValue({
      count: 2,
    });
  });

  it('findAll delegates to the category repository', async () => {
    categoryRepository.findAll.mockResolvedValue([categoryFixture()]);

    const result = await categoriesService.findAll('store-1');

    expect(result).toEqual([categoryFixture()]);
    expect(categoryRepository.findAll).toHaveBeenCalledWith('store-1');
  });

  it('findAllHiddenInStore delegates to hidden default repository', async () => {
    hiddenDefaultRepository.findManyByStore.mockResolvedValue([
      {
        categoryId: 'category-1',
        name: 'Dairy',
        description: null,
      },
    ]);

    const result = await categoriesService.findAllHiddenInStore('store-1');

    expect(result).toEqual([
      {
        categoryId: 'category-1',
        name: 'Dairy',
        description: null,
      },
    ]);
    expect(hiddenDefaultRepository.findManyByStore).toHaveBeenCalledWith(
      'store-1',
    );
  });

  it('getProductsInCategory delegates to the product service', async () => {
    categoryMocks.productService.getProductsByCategory.mockResolvedValue({
      count: 0,
      products: [],
    });

    await categoriesService.getProductsInCategory('category-1');

    expect(
      categoryMocks.productService.getProductsByCategory,
    ).toHaveBeenCalledWith('category-1');
  });

  it('creates a category and audit log in one transaction', async () => {
    categoryRepository.checkDuplicateName.mockResolvedValue(false);

    const result = await categoriesService.createOne('store-1', 'user-1', {
      name: 'Dairy',
      description: null,
    });

    expect(result).toEqual(
      categoryFixture({
        categoryId: 'category-created',
        name: 'Dairy',
        description: null,
      }),
    );
    expect(categoryRepository.checkDuplicateName).toHaveBeenCalledWith(
      'store-1',
      'Dairy',
    );
    expect(categoryMocks.transactionMock).toHaveBeenCalledTimes(1);
    expect(
      categoryMocks.transactionClient.category.create,
    ).toHaveBeenCalledWith(
      expect.objectContaining({
        data: {
          name: 'Dairy',
          description: null,
          isDefault: false,
          storeId: 'store-1',
        },
      }),
    );
    expect(
      categoryMocks.transactionClient.auditLog.create,
    ).toHaveBeenCalledWith({
      data: expect.objectContaining({
        actionType: 'create',
        entityType: 'Category',
        entityId: 'category-created',
        userId: 'user-1',
        storeId: 'store-1',
      }),
    });
  });

  it('rejects duplicate category names before opening a transaction', async () => {
    categoryRepository.checkDuplicateName.mockResolvedValue(true);

    await expect(
      categoriesService.createOne('store-1', 'user-1', {
        name: 'Dairy',
        description: null,
      }),
    ).rejects.toMatchObject({
      message: 'Category name already exists',
      status: StatusCodes.CONFLICT,
    });
    expect(categoryMocks.transactionMock).not.toHaveBeenCalled();
  });

  it('updates a custom category and logs changed fields', async () => {
    categoryRepository.findById.mockResolvedValue(categoryFixture());
    categoryRepository.checkDuplicateName.mockResolvedValue(false);
    categoryMocks.transactionClient.category.update.mockResolvedValue(
      categoryFixture({ name: 'Frozen' }),
    );

    const result = await categoriesService.updateOne(
      'store-1',
      'user-1',
      'category-1',
      { name: 'Frozen' },
    );

    expect(result.name).toBe('Frozen');
    expect(categoryRepository.checkDuplicateName).toHaveBeenCalledWith(
      'store-1',
      'Frozen',
    );
    expect(
      categoryMocks.transactionClient.category.update,
    ).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { categoryId: 'category-1' },
        data: { name: 'Frozen' },
      }),
    );
    expect(
      categoryMocks.transactionClient.auditLog.create,
    ).toHaveBeenCalledWith({
      data: expect.objectContaining({
        actionType: 'update',
        oldValue: { name: 'Dairy' },
        newValue: { name: 'Frozen' },
      }),
    });
  });

  it('does not check duplicate name or log audit when update has no changes', async () => {
    categoryRepository.findById.mockResolvedValue(categoryFixture());

    await categoriesService.updateOne('store-1', 'user-1', 'category-1', {
      name: 'Dairy',
    });

    expect(categoryRepository.checkDuplicateName).not.toHaveBeenCalled();
    expect(
      categoryMocks.transactionClient.auditLog.create,
    ).not.toHaveBeenCalled();
  });

  it('rejects updates for missing, default, foreign, and duplicate categories', async () => {
    categoryRepository.findById.mockResolvedValueOnce(null);

    await expect(
      categoriesService.updateOne('store-1', 'user-1', 'missing', {
        name: 'Frozen',
      }),
    ).rejects.toMatchObject({
      message: 'Category not found',
      status: StatusCodes.NOT_FOUND,
    });

    categoryRepository.findById.mockResolvedValueOnce(
      categoryFixture({ isDefault: true, storeId: null }),
    );

    await expect(
      categoriesService.updateOne('store-1', 'user-1', 'default', {
        name: 'Frozen',
      }),
    ).rejects.toMatchObject({
      message: 'Default category cannot be edited',
      status: StatusCodes.FORBIDDEN,
    });

    categoryRepository.findById.mockResolvedValueOnce(
      categoryFixture({ storeId: 'store-2' }),
    );

    await expect(
      categoriesService.updateOne('store-1', 'user-1', 'category-1', {
        name: 'Frozen',
      }),
    ).rejects.toMatchObject({
      message: 'You do not have permission to update this category',
      status: StatusCodes.FORBIDDEN,
    });

    categoryRepository.findById.mockResolvedValueOnce(categoryFixture());
    categoryRepository.checkDuplicateName.mockResolvedValueOnce(true);

    await expect(
      categoriesService.updateOne('store-1', 'user-1', 'category-1', {
        name: 'Frozen',
      }),
    ).rejects.toMatchObject({
      message: 'Category name already exists',
      status: StatusCodes.CONFLICT,
    });
  });

  it('hides an unused visible default category without transaction', async () => {
    categoryRepository.findById.mockResolvedValue(
      categoryFixture({ isDefault: true, storeId: null }),
    );
    hiddenDefaultRepository.isDefaultOneVisible.mockResolvedValue(true);
    categoryMocks.productService.getProductsByCategory.mockResolvedValue({
      count: 0,
      products: [],
    });

    await categoriesService.hideDefaultCategory('store-1', 'category-1', false);

    expect(hiddenDefaultRepository.hideOne).toHaveBeenCalledWith(
      'store-1',
      'category-1',
    );
    expect(categoryMocks.transactionMock).not.toHaveBeenCalled();
  });

  it('requires confirmation before hiding a default category with products', async () => {
    categoryRepository.findById.mockResolvedValue(
      categoryFixture({ isDefault: true, storeId: null }),
    );
    hiddenDefaultRepository.isDefaultOneVisible.mockResolvedValue(true);
    categoryMocks.productService.getProductsByCategory.mockResolvedValue({
      count: 1,
      products: [{ productId: 'product-1', name: 'Milk' }],
    });

    await expect(
      categoriesService.hideDefaultCategory('store-1', 'category-1', false),
    ).rejects.toMatchObject({
      message: 'Category is being used by products',
      status: StatusCodes.CONFLICT,
      code: 'CATEGORY_IN_USE',
      details: {
        productCount: 1,
        products: [{ productId: 'product-1', name: 'Milk' }],
      },
    });
    expect(categoryMocks.transactionMock).not.toHaveBeenCalled();
  });

  it('reassigns products before hiding a confirmed default category', async () => {
    categoryRepository.findById.mockResolvedValue(
      categoryFixture({ isDefault: true, storeId: null }),
    );
    hiddenDefaultRepository.isDefaultOneVisible.mockResolvedValue(true);
    categoryMocks.productService.getProductsByCategory.mockResolvedValue({
      count: 2,
      products: [],
    });

    await categoriesService.hideDefaultCategory('store-1', 'category-1', true);

    expect(categoryRepository.getUncategorizedId).toHaveBeenCalled();
    expect(
      categoryMocks.transactionClient.product.updateMany,
    ).toHaveBeenCalledWith({
      where: {
        categoryId: 'category-1',
        storeId: 'store-1',
      },
      data: {
        categoryId: 'uncategorized',
      },
    });
    expect(
      categoryMocks.transactionClient.hidedDefault.create,
    ).toHaveBeenCalledWith({
      data: {
        storeId: 'store-1',
        categoryId: 'category-1',
      },
    });
  });

  it('rejects invalid hide and restore default category states', async () => {
    categoryRepository.findById.mockResolvedValueOnce(null);

    await expect(
      categoriesService.hideDefaultCategory('store-1', 'missing', false),
    ).rejects.toMatchObject({
      message: 'Category not found',
      status: StatusCodes.NOT_FOUND,
    });

    categoryRepository.findById.mockResolvedValueOnce(categoryFixture());

    await expect(
      categoriesService.hideDefaultCategory('store-1', 'category-1', false),
    ).rejects.toMatchObject({
      message: 'Cannot hide the custom category',
      status: StatusCodes.BAD_REQUEST,
    });

    categoryRepository.findById.mockResolvedValueOnce(
      categoryFixture({ isDefault: true, storeId: null }),
    );
    hiddenDefaultRepository.isDefaultOneVisible.mockResolvedValueOnce(false);

    await expect(
      categoriesService.hideDefaultCategory('store-1', 'category-1', false),
    ).rejects.toMatchObject({
      message: 'Default category has already been hidden',
      status: StatusCodes.CONFLICT,
    });

    categoryRepository.findById.mockResolvedValueOnce(
      categoryFixture({ isDefault: true, storeId: null }),
    );
    hiddenDefaultRepository.isDefaultOneVisible.mockResolvedValueOnce(true);

    await expect(
      categoriesService.restoreDefault('store-1', 'category-1'),
    ).rejects.toMatchObject({
      message: 'The default category is already visible',
      status: StatusCodes.CONFLICT,
    });
  });

  it('rejects restore for missing and custom categories', async () => {
    categoryRepository.findById.mockResolvedValueOnce(null);

    await expect(
      categoriesService.restoreDefault('store-1', 'missing'),
    ).rejects.toMatchObject({
      message: 'Category not found',
      status: StatusCodes.NOT_FOUND,
    });

    categoryRepository.findById.mockResolvedValueOnce(categoryFixture());

    await expect(
      categoriesService.restoreDefault('store-1', 'category-1'),
    ).rejects.toMatchObject({
      message: 'Cannot hide the custom category',
      status: StatusCodes.BAD_REQUEST,
    });
  });

  it('restores a hidden default category', async () => {
    categoryRepository.findById.mockResolvedValue(
      categoryFixture({ isDefault: true, storeId: null }),
    );
    hiddenDefaultRepository.isDefaultOneVisible.mockResolvedValue(false);

    await categoriesService.restoreDefault('store-1', 'category-1');

    expect(hiddenDefaultRepository.unhideOne).toHaveBeenCalledWith(
      'store-1',
      'category-1',
    );
  });

  it('deletes an unused custom category and writes an audit log', async () => {
    categoryRepository.findById.mockResolvedValue(categoryFixture());
    categoryMocks.productService.getProductsByCategory.mockResolvedValue({
      count: 0,
      products: [],
    });

    await categoriesService.deleteCustomCategory(
      'store-1',
      'user-1',
      'category-1',
      false,
    );

    expect(
      categoryMocks.transactionClient.category.delete,
    ).toHaveBeenCalledWith({
      where: { categoryId: 'category-1' },
    });
    expect(
      categoryMocks.transactionClient.auditLog.create,
    ).toHaveBeenCalledWith({
      data: expect.objectContaining({
        actionType: 'delete',
        entityId: 'category-1',
        oldValue: { activeStatus: 'active' },
        newValue: { activeStatus: 'inactive' },
      }),
    });
  });

  it('requires confirmation before deleting a custom category with products', async () => {
    categoryRepository.findById.mockResolvedValue(categoryFixture());
    categoryMocks.productService.getProductsByCategory.mockResolvedValue({
      count: 1,
      products: [{ productId: 'product-1', name: 'Milk' }],
    });

    await expect(
      categoriesService.deleteCustomCategory(
        'store-1',
        'user-1',
        'category-1',
        false,
      ),
    ).rejects.toMatchObject({
      message: 'Category is being used by products',
      status: StatusCodes.CONFLICT,
      code: 'CATEGORY_IN_USE',
    });
    expect(categoryMocks.transactionMock).not.toHaveBeenCalled();
  });

  it('reassigns products before deleting a confirmed custom category', async () => {
    categoryRepository.findById.mockResolvedValue(categoryFixture());
    categoryMocks.productService.getProductsByCategory.mockResolvedValue({
      count: 2,
      products: [],
    });

    await categoriesService.deleteCustomCategory(
      'store-1',
      'user-1',
      'category-1',
      true,
    );

    expect(
      categoryMocks.transactionClient.product.updateMany,
    ).toHaveBeenCalledWith({
      where: {
        categoryId: 'category-1',
        storeId: 'store-1',
      },
      data: {
        categoryId: 'uncategorized',
      },
    });
    expect(
      categoryMocks.transactionClient.category.delete,
    ).toHaveBeenCalledWith({
      where: { categoryId: 'category-1' },
    });
    expect(
      categoryMocks.transactionClient.auditLog.create,
    ).toHaveBeenCalledWith({
      data: expect.objectContaining({
        newValue: {
          activeStatus: 'inactive',
          reassignedProductCount: 2,
        },
      }),
    });
  });

  it('rejects delete for missing, default, and foreign categories', async () => {
    categoryRepository.findById.mockResolvedValueOnce(null);

    await expect(
      categoriesService.deleteCustomCategory(
        'store-1',
        'user-1',
        'missing',
        false,
      ),
    ).rejects.toMatchObject({
      message: 'Category not found',
      status: StatusCodes.NOT_FOUND,
    });

    categoryRepository.findById.mockResolvedValueOnce(
      categoryFixture({ isDefault: true, storeId: null }),
    );

    await expect(
      categoriesService.deleteCustomCategory(
        'store-1',
        'user-1',
        'category-1',
        false,
      ),
    ).rejects.toMatchObject({
      message: 'Default category cannot be hard deleted',
      status: StatusCodes.BAD_REQUEST,
    });

    categoryRepository.findById.mockResolvedValueOnce(
      categoryFixture({ storeId: 'store-2' }),
    );

    await expect(
      categoriesService.deleteCustomCategory(
        'store-1',
        'user-1',
        'category-1',
        false,
      ),
    ).rejects.toMatchObject({
      message: 'You do not have permission to delete this category',
      status: StatusCodes.FORBIDDEN,
    });
  });
});
