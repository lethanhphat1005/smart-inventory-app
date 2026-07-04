import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CategoryController } from '../../../../src/modules/categories/category.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

import type {
  CategoryResponseDto,
  HiddenDefaultResponseDto,
} from '../../../../src/modules/categories/category.dto.js';

vi.mock('../../../../src/modules/categories/category.service.js', () => ({
  CategoriesService: class MockCategoriesService {},
}));

type MockCategoryService = {
  findAll: ReturnType<typeof vi.fn>;
  findAllHiddenInStore: ReturnType<typeof vi.fn>;
  createOne: ReturnType<typeof vi.fn>;
  updateOne: ReturnType<typeof vi.fn>;
  hideDefaultCategory: ReturnType<typeof vi.fn>;
  restoreDefault: ReturnType<typeof vi.fn>;
  deleteCustomCategory: ReturnType<typeof vi.fn>;
};

const categoryFixture = (
  overrides: Partial<CategoryResponseDto> = {},
): CategoryResponseDto => ({
  categoryId: '550e8400-e29b-41d4-a716-446655440000',
  name: 'Dairy',
  description: null,
  isDefault: false,
  storeId: 'store-1',
  ...overrides,
});

const createMockService = (): MockCategoryService => ({
  findAll: vi.fn(),
  findAllHiddenInStore: vi.fn(),
  createOne: vi.fn(),
  updateOne: vi.fn(),
  hideDefaultCategory: vi.fn(),
  restoreDefault: vi.fn(),
  deleteCustomCategory: vi.fn(),
});

describe('CategoryController', () => {
  let categoryService: MockCategoryService;
  let categoryController: CategoryController;

  beforeEach(() => {
    categoryService = createMockService();
    categoryController = new CategoryController(categoryService as never);
  });

  it('returns categories for the current store', async () => {
    const categories = [categoryFixture()];
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
    });
    const res = createResponse<CategoryResponseDto[]>();

    categoryService.findAll.mockResolvedValue(categories);

    await categoryController.findAll(req, res);

    expect(categoryService.findAll).toHaveBeenCalledWith('store-1');
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: categories,
    });
  });

  it('returns hidden defaults for the current store', async () => {
    const hiddenCategories: HiddenDefaultResponseDto[] = [
      {
        categoryId: '550e8400-e29b-41d4-a716-446655440000',
        name: 'Dairy',
        description: null,
      },
    ];
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
    });
    const res = createResponse<HiddenDefaultResponseDto[]>();

    categoryService.findAllHiddenInStore.mockResolvedValue(hiddenCategories);

    await categoryController.findAllHidden(req, res);

    expect(categoryService.findAllHiddenInStore).toHaveBeenCalledWith(
      'store-1',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('creates a category for the current store and user', async () => {
    const body = {
      name: 'Dairy',
      description: null,
    };
    const category = categoryFixture(body);
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
    const res = createResponse<CategoryResponseDto>();

    categoryService.createOne.mockResolvedValue(category);

    await categoryController.createOne(req, res);

    expect(categoryService.createOne).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      body,
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.CREATED);
  });

  it('updates a category by path id', async () => {
    const category = categoryFixture({ name: 'Frozen' });
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
        categoryId: '550e8400-e29b-41d4-a716-446655440000',
      },
      body: {
        name: 'Frozen',
      },
    });
    const res = createResponse<CategoryResponseDto>();

    categoryService.updateOne.mockResolvedValue(category);

    await categoryController.updateOne(req, res);

    expect(categoryService.updateOne).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      '550e8400-e29b-41d4-a716-446655440000',
      { name: 'Frozen' },
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('hides a default category and defaults reassignment confirmation to false', async () => {
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
      params: {
        categoryId: '550e8400-e29b-41d4-a716-446655440000',
      },
      body: {},
    });
    const res = createResponse<null>();

    categoryService.hideDefaultCategory.mockResolvedValue(undefined);

    await categoryController.hideDefaultCategory(req, res);

    expect(categoryService.hideDefaultCategory).toHaveBeenCalledWith(
      'store-1',
      '550e8400-e29b-41d4-a716-446655440000',
      false,
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: null,
    });
  });

  it('restores a default category by path id', async () => {
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
      params: {
        categoryId: '550e8400-e29b-41d4-a716-446655440000',
      },
    });
    const res = createResponse<null>();

    categoryService.restoreDefault.mockResolvedValue(undefined);

    await categoryController.restoreDefaultOne(req, res);

    expect(categoryService.restoreDefault).toHaveBeenCalledWith(
      'store-1',
      '550e8400-e29b-41d4-a716-446655440000',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('deletes a custom category using explicit reassignment confirmation', async () => {
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
        categoryId: '550e8400-e29b-41d4-a716-446655440000',
      },
      body: {
        canReassignToUncategorized: true,
      },
    });
    const res = createResponse<null>();

    categoryService.deleteCustomCategory.mockResolvedValue(undefined);

    await categoryController.deleteCustomCategory(req, res);

    expect(categoryService.deleteCustomCategory).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      '550e8400-e29b-41d4-a716-446655440000',
      true,
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('deletes a custom category and defaults reassignment confirmation to false', async () => {
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
        categoryId: '550e8400-e29b-41d4-a716-446655440000',
      },
      body: {},
    });
    const res = createResponse<null>();

    categoryService.deleteCustomCategory.mockResolvedValue(undefined);

    await categoryController.deleteCustomCategory(req, res);

    expect(categoryService.deleteCustomCategory).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      '550e8400-e29b-41d4-a716-446655440000',
      false,
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });
});
