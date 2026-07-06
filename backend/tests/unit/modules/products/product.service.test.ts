import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ProductService } from '../../../../src/modules/products/product.service.js';

import type {
  DetailProductResponseDto,
  ProductResponseDto,
  ProductSimpleResponseDto,
} from '../../../../src/modules/products/product.dto.js';

const productMocks = vi.hoisted(() => {
  const transactionClient = {
    product: {
      create: vi.fn(),
      update: vi.fn(),
      findMany: vi.fn(),
    },
    productPackage: {
      findMany: vi.fn(),
      update: vi.fn(),
      updateMany: vi.fn(),
    },
    auditLog: {
      create: vi.fn(),
    },
  };

  const transactionMock = vi.fn(
    async <T>(callback: (tx: typeof transactionClient) => Promise<T>) => {
      return await callback(transactionClient);
    },
  );

  return {
    categoryRepository: {
      findById: vi.fn(),
    },
    getSignedUrl: vi.fn(),
    transactionClient,
    transactionMock,
  };
});

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: {
    $transaction: productMocks.transactionMock,
  },
}));

vi.mock('../../../../src/modules/categories/index.js', () => ({
  categoryRepository: productMocks.categoryRepository,
}));

vi.mock('../../../../src/modules/audit-log/index.js', () => ({
  AuditLogRepository: class MockAuditLogRepository {
    constructor(private readonly db: typeof productMocks.transactionClient) {}

    async createLog(data: unknown): Promise<void> {
      await this.db.auditLog.create({ data });
    }
  },
}));

vi.mock('../../../../src/modules/product-packages/index.js', () => ({
  ProductPackageRepository: class MockProductPackageRepository {
    constructor(private readonly db: typeof productMocks.transactionClient) {}

    async findManyByProductIdForNameSync(
      storeId: string,
      productId: string,
    ): Promise<unknown> {
      return await this.db.productPackage.findMany({
        where: {
          productId,
          activeStatus: 'active',
          product: {
            storeId,
            activeStatus: 'active',
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
        select: {
          productPackageId: true,
          displayName: true,
          variant: true,
        },
      });
    }

    async updateDisplayNameWithProduct(
      productPackageId: string,
      newDisplayName: string,
    ): Promise<unknown> {
      return await this.db.productPackage.update({
        where: { productPackageId },
        data: {
          displayName: newDisplayName,
        },
        select: {
          productPackageId: true,
          displayName: true,
          variant: true,
        },
      });
    }

    async softDeleteManyByProductId(productId: string): Promise<number> {
      const deleted = await this.db.productPackage.updateMany({
        where: { productId },
        data: {
          activeStatus: 'inactive',
        },
      });

      return deleted.count;
    }
  },
}));

vi.mock('../../../../src/common/utils/index.js', async (importActual) => {
  const actual =
    await importActual<
      typeof import('../../../../src/common/utils/index.js')
    >();

  return {
    ...actual,
    StorageService: {
      getSignedUrl: productMocks.getSignedUrl,
    },
  };
});

type MockProductRepository = {
  findManyByStoreId: ReturnType<typeof vi.fn>;
  findDetailOne: ReturnType<typeof vi.fn>;
  findManyByCategoryId: ReturnType<typeof vi.fn>;
  findManyActiveByIds: ReturnType<typeof vi.fn>;
  findOne: ReturnType<typeof vi.fn>;
};

const date = new Date('2026-01-01T00:00:00.000Z');

const productFixture = (
  overrides: Partial<ProductResponseDto> = {},
): ProductResponseDto => ({
  productId: 'product-1',
  name: 'Milk',
  imageUrl: 'products/milk.png',
  brand: 'Dairy Co',
  activeStatus: 'active',
  createdAt: date,
  updatedAt: date,
  storeId: 'store-1',
  category: {
    categoryId: 'category-1',
    name: 'Dairy',
  },
  ...overrides,
});

const simpleProductFixture = (
  overrides: Partial<ProductSimpleResponseDto> = {},
): ProductSimpleResponseDto => ({
  productId: 'product-1',
  name: 'Milk',
  imageUrl: 'products/milk.png',
  brand: 'Dairy Co',
  storeId: 'store-1',
  categoryId: 'category-1',
  ...overrides,
});

const createMockRepository = (): MockProductRepository => ({
  findManyByStoreId: vi.fn(),
  findDetailOne: vi.fn(),
  findManyByCategoryId: vi.fn(),
  findManyActiveByIds: vi.fn(),
  findOne: vi.fn(),
});

describe('ProductService', () => {
  let productRepository: MockProductRepository;
  let productService: ProductService;

  beforeEach(() => {
    vi.clearAllMocks();

    productMocks.getSignedUrl.mockImplementation(
      (_bucket: string, path: string | null) =>
        path ? `signed:${path}` : null,
    );
    productMocks.categoryRepository.findById.mockResolvedValue({
      categoryId: 'category-1',
    });

    productRepository = createMockRepository();
    productService = new ProductService(productRepository as never);
  });

  describe('getProductsbyStoreId', () => {
    it('returns paginated products with signed image URLs', async () => {
      productRepository.findManyByStoreId.mockResolvedValue({
        items: [productFixture(), productFixture({ productId: 'product-2' })],
        totalItems: 2,
      });

      const result = await productService.getProductsbyStoreId('store-1', {
        page: 1,
        limit: 2,
        sortBy: 'name',
        sortOrder: 'asc',
      });

      expect(productRepository.findManyByStoreId).toHaveBeenCalledWith(
        'store-1',
        {
          page: 1,
          limit: 2,
          sortBy: 'name',
          sortOrder: 'asc',
        },
      );
      expect(result.items.map((item) => item.imageUrl)).toEqual([
        'signed:products/milk.png',
        'signed:products/milk.png',
      ]);
      expect(result.meta).toEqual({
        page: 1,
        limit: 2,
        totalItems: 2,
        totalPages: 1,
      });
    });
  });

  describe('getProductById', () => {
    it('returns a product detail with signed image URL', async () => {
      const detailProduct: DetailProductResponseDto = {
        ...productFixture(),
        productPackages: [],
      };

      productRepository.findDetailOne.mockResolvedValue(detailProduct);

      const result = await productService.getProductById(
        'store-1',
        'product-1',
      );

      expect(productRepository.findDetailOne).toHaveBeenCalledWith(
        'store-1',
        'product-1',
      );
      expect(result.imageUrl).toBe('signed:products/milk.png');
    });

    it('throws not found when the product is missing or outside the store', async () => {
      productRepository.findDetailOne.mockResolvedValue(null);

      await expect(
        productService.getProductById('store-1', 'product-1'),
      ).rejects.toMatchObject({
        message: 'Product not found',
        status: StatusCodes.NOT_FOUND,
      });
    });
  });

  describe('getProductsByCategory', () => {
    it('requires an existing category and signs product images', async () => {
      productRepository.findManyByCategoryId.mockResolvedValue({
        count: 1,
        products: [
          {
            productId: 'product-1',
            name: 'Milk',
            imageUrl: 'products/milk.png',
            brand: 'Dairy Co',
          },
        ],
      });

      const result = await productService.getProductsByCategory('category-1');

      expect(productMocks.categoryRepository.findById).toHaveBeenCalledWith(
        'category-1',
      );
      expect(result).toEqual({
        count: 1,
        products: [
          {
            productId: 'product-1',
            name: 'Milk',
            imageUrl: 'signed:products/milk.png',
            brand: 'Dairy Co',
          },
        ],
      });
    });

    it('throws not found when the category is missing', async () => {
      productMocks.categoryRepository.findById.mockResolvedValue(null);

      await expect(
        productService.getProductsByCategory('missing-category'),
      ).rejects.toMatchObject({
        message: 'Category not found',
        status: StatusCodes.NOT_FOUND,
      });
      expect(productRepository.findManyByCategoryId).not.toHaveBeenCalled();
    });
  });

  describe('getActiveProductsByIds', () => {
    it('delegates active product lookup to the repository', async () => {
      productRepository.findManyActiveByIds.mockResolvedValue([
        { productId: 'product-1', name: 'Milk' },
      ]);

      const result = await productService.getActiveProductsByIds('store-1', [
        'product-1',
      ]);

      expect(productRepository.findManyActiveByIds).toHaveBeenCalledWith(
        'store-1',
        ['product-1'],
      );
      expect(result).toEqual([{ productId: 'product-1', name: 'Milk' }]);
    });
  });

  describe('createProduct', () => {
    it('creates a product and audit log in one transaction', async () => {
      const createdProduct = productFixture();

      productMocks.transactionClient.product.create.mockResolvedValue(
        createdProduct,
      );

      const result = await productService.createProduct('store-1', 'user-1', {
        storeId: 'store-1',
        name: 'Milk',
        imageUrl: 'products/milk.png',
        brand: 'Dairy Co',
        categoryId: 'category-1',
      });

      expect(productMocks.categoryRepository.findById).toHaveBeenCalledWith(
        'category-1',
      );
      expect(productMocks.transactionMock).toHaveBeenCalledTimes(1);
      expect(
        productMocks.transactionClient.product.create,
      ).toHaveBeenCalledWith(
        expect.objectContaining({
          data: {
            storeId: 'store-1',
            name: 'Milk',
            imageUrl: 'products/milk.png',
            brand: 'Dairy Co',
            categoryId: 'category-1',
          },
        }),
      );
      expect(
        productMocks.transactionClient.auditLog.create,
      ).toHaveBeenCalledWith({
        data: expect.objectContaining({
          actionType: 'create',
          entityType: 'Product',
          entityId: 'product-1',
          userId: 'user-1',
          storeId: 'store-1',
          oldValue: null,
          newValue: expect.objectContaining({
            productName: 'Milk',
            brand: 'Dairy Co',
          }),
        }),
      });
      expect(result.imageUrl).toBe('signed:products/milk.png');
    });

    it('does not start a transaction when the category is missing', async () => {
      productMocks.categoryRepository.findById.mockResolvedValue(null);

      await expect(
        productService.createProduct('store-1', 'user-1', {
          storeId: 'store-1',
          name: 'Milk',
          categoryId: 'missing-category',
        }),
      ).rejects.toMatchObject({
        message: 'Category not found',
        status: StatusCodes.NOT_FOUND,
      });
      expect(productMocks.transactionMock).not.toHaveBeenCalled();
    });

    it('propagates transaction failures', async () => {
      productMocks.transactionClient.product.create.mockRejectedValue(
        new Error('database unavailable'),
      );

      await expect(
        productService.createProduct('store-1', 'user-1', {
          storeId: 'store-1',
          name: 'Milk',
          categoryId: 'category-1',
        }),
      ).rejects.toThrow('database unavailable');
    });
  });

  describe('syncDisplayNameWithProductName', () => {
    it('updates package display names by replacing the old product name', async () => {
      productMocks.transactionClient.productPackage.findMany.mockResolvedValue([
        {
          productPackageId: 'package-1',
          displayName: 'Milk 1L',
          variant: '1L',
        },
      ]);
      productMocks.transactionClient.productPackage.update.mockResolvedValue({
        productPackageId: 'package-1',
        displayName: 'Oat Milk 1L',
        variant: '1L',
      });

      const result = await productService.syncDisplayNameWithProductName(
        'store-1',
        'product-1',
        'Milk',
        'Oat Milk',
        productMocks.transactionClient as never,
      );

      expect(
        productMocks.transactionClient.productPackage.update,
      ).toHaveBeenCalledWith({
        where: { productPackageId: 'package-1' },
        data: {
          displayName: 'Oat Milk 1L',
        },
        select: {
          productPackageId: true,
          displayName: true,
          variant: true,
        },
      });
      expect(result).toEqual([
        {
          productPackageId: 'package-1',
          displayName: 'Oat Milk 1L',
          variant: '1L',
        },
      ]);
    });

    it('throws when a package displayName is missing', async () => {
      productMocks.transactionClient.productPackage.findMany.mockResolvedValue([
        {
          productPackageId: 'package-1',
          displayName: null,
          variant: '1L',
        },
      ]);

      await expect(
        productService.syncDisplayNameWithProductName(
          'store-1',
          'product-1',
          'Milk',
          'Oat Milk',
          productMocks.transactionClient as never,
        ),
      ).rejects.toMatchObject({
        message: 'Product package displayName not found',
        status: StatusCodes.BAD_REQUEST,
      });
    });
  });

  describe('updateProduct', () => {
    it('updates product, syncs package names, and writes an audit log for changes', async () => {
      productRepository.findOne.mockResolvedValue(simpleProductFixture());
      productMocks.transactionClient.product.update.mockResolvedValue(
        productFixture({ name: 'Oat Milk' }),
      );
      productMocks.transactionClient.productPackage.findMany.mockResolvedValue([
        {
          productPackageId: 'package-1',
          displayName: 'Milk 1L',
          variant: '1L',
        },
      ]);
      productMocks.transactionClient.productPackage.update.mockResolvedValue({
        productPackageId: 'package-1',
        displayName: 'Oat Milk 1L',
        variant: '1L',
      });

      const result = await productService.updateProduct(
        'store-1',
        'user-1',
        'product-1',
        {
          name: 'Oat Milk',
        },
      );

      expect(
        productMocks.transactionClient.product.update,
      ).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { productId: 'product-1' },
          data: { name: 'Oat Milk' },
        }),
      );
      expect(
        productMocks.transactionClient.auditLog.create,
      ).toHaveBeenCalledWith({
        data: expect.objectContaining({
          actionType: 'update',
          entityId: 'product-1',
          oldValue: {
            name: 'Milk',
          },
          newValue: {
            name: 'Oat Milk',
            packageNameSyncedCount: 1,
          },
        }),
      });
      expect(result.imageUrl).toBe('signed:products/milk.png');
    });

    it('updates without audit log when submitted values do not change', async () => {
      productRepository.findOne.mockResolvedValue(simpleProductFixture());
      productMocks.transactionClient.product.update.mockResolvedValue(
        productFixture(),
      );

      await productService.updateProduct('store-1', 'user-1', 'product-1', {
        name: 'Milk',
      });

      expect(
        productMocks.transactionClient.productPackage.findMany,
      ).not.toHaveBeenCalled();
      expect(
        productMocks.transactionClient.auditLog.create,
      ).not.toHaveBeenCalled();
    });

    it('throws not found before update when the product is missing', async () => {
      productRepository.findOne.mockResolvedValue(null);

      await expect(
        productService.updateProduct('store-1', 'user-1', 'product-1', {
          name: 'Oat Milk',
        }),
      ).rejects.toMatchObject({
        message: 'Product not found',
        status: StatusCodes.NOT_FOUND,
      });
      expect(productMocks.transactionMock).not.toHaveBeenCalled();
    });

    it('checks a replacement category before updating', async () => {
      productRepository.findOne.mockResolvedValue(simpleProductFixture());
      productMocks.categoryRepository.findById.mockResolvedValue(null);

      await expect(
        productService.updateProduct('store-1', 'user-1', 'product-1', {
          categoryId: 'missing-category',
        }),
      ).rejects.toMatchObject({
        message: 'Category not found',
        status: StatusCodes.NOT_FOUND,
      });
      expect(productMocks.transactionMock).not.toHaveBeenCalled();
    });
  });

  describe('softDeleteProduct', () => {
    it('soft deletes the product and its packages in one transaction', async () => {
      productRepository.findOne.mockResolvedValue(simpleProductFixture());
      productMocks.transactionClient.product.update.mockResolvedValue({
        productId: 'product-1',
      });
      productMocks.transactionClient.productPackage.updateMany.mockResolvedValue(
        {
          count: 2,
        },
      );

      await productService.softDeleteProduct('store-1', 'user-1', 'product-1');

      expect(
        productMocks.transactionClient.product.update,
      ).toHaveBeenCalledWith({
        where: {
          productId: 'product-1',
        },
        data: {
          activeStatus: 'inactive',
        },
        select: {
          productId: true,
        },
      });
      expect(
        productMocks.transactionClient.productPackage.updateMany,
      ).toHaveBeenCalledWith({
        where: { productId: 'product-1' },
        data: {
          activeStatus: 'inactive',
        },
      });
      expect(
        productMocks.transactionClient.auditLog.create,
      ).toHaveBeenCalledWith({
        data: expect.objectContaining({
          actionType: 'delete',
          entityType: 'Product',
          entityId: 'product-1',
          oldValue: {
            activeStatus: 'active',
          },
          newValue: {
            activeStatus: 'inactive',
            deletedPackageCount: 2,
          },
        }),
      });
    });

    it('throws not found before delete when the product is missing', async () => {
      productRepository.findOne.mockResolvedValue(null);

      await expect(
        productService.softDeleteProduct('store-1', 'user-1', 'product-1'),
      ).rejects.toMatchObject({
        message: 'Product not found',
        status: StatusCodes.NOT_FOUND,
      });
      expect(productMocks.transactionMock).not.toHaveBeenCalled();
    });
  });
});
