import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CategoryRepository } from '../../../../src/modules/categories/repositories/category.repository.js';
import { HiddenDefaultRepository } from '../../../../src/modules/categories/repositories/hidden-default.repository.js';

const createMockDb = () => ({
  category: {
    findMany: vi.fn(),
    findUnique: vi.fn(),
    findFirst: vi.fn(),
    findFirstOrThrow: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
  },
  hidedDefault: {
    findMany: vi.fn(),
    create: vi.fn(),
    delete: vi.fn(),
    findUnique: vi.fn(),
  },
});

describe('CategoryRepository', () => {
  let db: ReturnType<typeof createMockDb>;
  let categoryRepository: CategoryRepository;

  beforeEach(() => {
    db = createMockDb();
    categoryRepository = new CategoryRepository(db as never);
  });

  it('findAll returns custom categories for the store and visible defaults', async () => {
    db.category.findMany.mockResolvedValue([]);

    await categoryRepository.findAll('store-1');

    expect(db.category.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          OR: [
            {
              storeId: 'store-1',
              isDefault: false,
            },
            {
              isDefault: true,
              storeId: null,
              hidedDefaults: {
                none: {
                  storeId: 'store-1',
                },
              },
            },
          ],
        },
        orderBy: [{ isDefault: 'desc' }, { name: 'asc' }],
      }),
    );
  });

  it('checkDuplicateName compares custom and default names case-insensitively', async () => {
    db.category.findFirst.mockResolvedValue({ categoryId: 'category-1' });

    const isDuplicate = await categoryRepository.checkDuplicateName(
      'store-1',
      'Dairy',
    );

    expect(isDuplicate).toBe(true);
    expect(db.category.findFirst).toHaveBeenCalledWith({
      where: {
        name: {
          equals: 'Dairy',
          mode: 'insensitive',
        },
        OR: [
          {
            storeId: 'store-1',
            isDefault: false,
          },
          {
            isDefault: true,
            storeId: null,
          },
        ],
      },
      select: {
        categoryId: true,
      },
    });
  });

  it('findById selects the category DTO fields by id', async () => {
    db.category.findUnique.mockResolvedValue({
      categoryId: 'category-1',
      name: 'Dairy',
      description: null,
      isDefault: false,
      storeId: 'store-1',
    });

    const result = await categoryRepository.findById('category-1');

    expect(result).toEqual({
      categoryId: 'category-1',
      name: 'Dairy',
      description: null,
      isDefault: false,
      storeId: 'store-1',
    });
    expect(db.category.findUnique).toHaveBeenCalledWith({
      where: {
        categoryId: 'category-1',
      },
      select: {
        categoryId: true,
        name: true,
        description: true,
        isDefault: true,
        storeId: true,
      },
    });
  });

  it('createOne creates a custom category scoped to the store', async () => {
    db.category.create.mockResolvedValue({ categoryId: 'category-1' });

    await categoryRepository.createOne('store-1', {
      name: 'Dairy',
      description: null,
    });

    expect(db.category.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: {
          name: 'Dairy',
          description: null,
          isDefault: false,
          storeId: 'store-1',
        },
      }),
    );
  });

  it('updateOne only writes provided fields', async () => {
    db.category.update.mockResolvedValue({ categoryId: 'category-1' });

    await categoryRepository.updateOne('category-1', { description: null });

    expect(db.category.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { categoryId: 'category-1' },
        data: { description: null },
      }),
    );
  });

  it('getUncategorizedId returns the default uncategorized category id', async () => {
    db.category.findFirstOrThrow.mockResolvedValue({
      categoryId: 'uncategorized',
    });

    const result = await categoryRepository.getUncategorizedId();

    expect(result).toBe('uncategorized');
    expect(db.category.findFirstOrThrow).toHaveBeenCalledWith({
      where: {
        name: 'Uncategorized',
        isDefault: true,
        storeId: null,
      },
      select: {
        categoryId: true,
      },
    });
  });

  it('deleteCustomCategory deletes by categoryId', async () => {
    await categoryRepository.deleteCustomCategory('category-1');

    expect(db.category.delete).toHaveBeenCalledWith({
      where: { categoryId: 'category-1' },
    });
  });
});

describe('HiddenDefaultRepository', () => {
  let db: ReturnType<typeof createMockDb>;
  let hiddenDefaultRepository: HiddenDefaultRepository;

  beforeEach(() => {
    db = createMockDb();
    hiddenDefaultRepository = new HiddenDefaultRepository(db as never);
  });

  it('findManyByStore maps hidden default records to category DTOs', async () => {
    db.hidedDefault.findMany.mockResolvedValue([
      {
        category: {
          categoryId: 'category-1',
          name: 'Dairy',
          description: null,
        },
      },
    ]);

    const result = await hiddenDefaultRepository.findManyByStore('store-1');

    expect(result).toEqual([
      {
        categoryId: 'category-1',
        name: 'Dairy',
        description: null,
      },
    ]);
    expect(db.hidedDefault.findMany).toHaveBeenCalledWith({
      where: {
        storeId: 'store-1',
      },
      orderBy: {
        category: {
          name: 'asc',
        },
      },
      select: {
        category: {
          select: {
            categoryId: true,
            name: true,
            description: true,
          },
        },
      },
    });
  });

  it('hideOne creates a hidden default record', async () => {
    await hiddenDefaultRepository.hideOne('store-1', 'category-1');

    expect(db.hidedDefault.create).toHaveBeenCalledWith({
      data: {
        storeId: 'store-1',
        categoryId: 'category-1',
      },
    });
  });

  it('unhideOne deletes by compound key', async () => {
    await hiddenDefaultRepository.unhideOne('store-1', 'category-1');

    expect(db.hidedDefault.delete).toHaveBeenCalledWith({
      where: {
        storeId_categoryId: {
          storeId: 'store-1',
          categoryId: 'category-1',
        },
      },
    });
  });

  it('isDefaultOneVisible returns false when a hidden record exists', async () => {
    db.hidedDefault.findUnique.mockResolvedValue({
      storeId: 'store-1',
      categoryId: 'category-1',
    });

    await expect(
      hiddenDefaultRepository.isDefaultOneVisible('store-1', 'category-1'),
    ).resolves.toBe(false);
  });
});
