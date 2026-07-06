import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ProductController } from '../../../../src/modules/products/product.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

import type {
  ListProductsResponseDto,
  ProductResponseDto,
} from '../../../../src/modules/products/product.dto.js';

vi.mock('../../../../src/modules/products/product.service.js', () => ({
  ProductService: class MockProductService {},
}));

type MockProductService = {
  getProductsbyStoreId: ReturnType<typeof vi.fn>;
  getProductById: ReturnType<typeof vi.fn>;
  createProduct: ReturnType<typeof vi.fn>;
  updateProduct: ReturnType<typeof vi.fn>;
  softDeleteProduct: ReturnType<typeof vi.fn>;
};

const productFixture = (
  overrides: Partial<ProductResponseDto> = {},
): ProductResponseDto => ({
  productId: '550e8400-e29b-41d4-a716-446655440000',
  name: 'Milk',
  imageUrl: 'signed:products/milk.png',
  brand: 'Dairy Co',
  activeStatus: 'active',
  createdAt: new Date('2026-01-01T00:00:00.000Z'),
  updatedAt: new Date('2026-01-01T00:00:00.000Z'),
  storeId: 'store-1',
  category: {
    categoryId: '660e8400-e29b-41d4-a716-446655440000',
    name: 'Dairy',
  },
  ...overrides,
});

const createMockService = (): MockProductService => ({
  getProductsbyStoreId: vi.fn(),
  getProductById: vi.fn(),
  createProduct: vi.fn(),
  updateProduct: vi.fn(),
  softDeleteProduct: vi.fn(),
});

describe('ProductController', () => {
  let productService: MockProductService;
  let productController: ProductController;

  beforeEach(() => {
    productService = createMockService();
    productController = new ProductController(productService as never);
  });

  it('returns products for the current store using validated query', async () => {
    const payload: ListProductsResponseDto = {
      items: [productFixture()],
      meta: {
        page: 1,
        limit: 50,
        totalItems: 1,
        totalPages: 1,
      },
    };
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
    });
    const res = createResponse<ListProductsResponseDto>({
      validatedQuery: {
        page: 1,
        limit: 50,
        sortBy: 'name',
        sortOrder: 'desc',
      },
    });

    productService.getProductsbyStoreId.mockResolvedValue(payload);

    await productController.getProducts(req, res);

    expect(productService.getProductsbyStoreId).toHaveBeenCalledWith(
      'store-1',
      {
        page: 1,
        limit: 50,
        sortBy: 'name',
        sortOrder: 'desc',
      },
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: payload,
    });
  });

  it('returns a product detail by path id', async () => {
    const product = productFixture();
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
      params: {
        productId: '550e8400-e29b-41d4-a716-446655440000',
      },
    });
    const res = createResponse<ProductResponseDto>();

    productService.getProductById.mockResolvedValue(product);

    await productController.getProductById(req, res);

    expect(productService.getProductById).toHaveBeenCalledWith(
      'store-1',
      '550e8400-e29b-41d4-a716-446655440000',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('creates a product for the current store and user', async () => {
    const product = productFixture();
    const body = {
      name: 'Milk',
      imageUrl: 'products/milk.png',
      brand: 'Dairy Co',
      categoryId: '660e8400-e29b-41d4-a716-446655440000',
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
      body,
    });
    const res = createResponse<ProductResponseDto>();

    productService.createProduct.mockResolvedValue(product);

    await productController.createProduct(req, res);

    expect(productService.createProduct).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      {
        ...body,
        storeId: 'store-1',
      },
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.CREATED);
  });

  it('updates a product by path id', async () => {
    const product = productFixture({ name: 'Oat Milk' });
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
      params: {
        productId: '550e8400-e29b-41d4-a716-446655440000',
      },
      body: {
        name: 'Oat Milk',
      },
    });
    const res = createResponse<ProductResponseDto>();

    productService.updateProduct.mockResolvedValue(product);

    await productController.updateProduct(req, res);

    expect(productService.updateProduct).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      '550e8400-e29b-41d4-a716-446655440000',
      {
        name: 'Oat Milk',
      },
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('soft deletes a product by path id', async () => {
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
      params: {
        productId: '550e8400-e29b-41d4-a716-446655440000',
      },
    });
    const res = createResponse<null>();

    productService.softDeleteProduct.mockResolvedValue(undefined);

    await productController.softDeleteProduct(req, res);

    expect(productService.softDeleteProduct).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      '550e8400-e29b-41d4-a716-446655440000',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: null,
    });
  });
});
