import { beforeEach, describe, expect, it, vi } from 'vitest';

const repositoryMocks = vi.hoisted(() => ({
  prisma: {
    unit: {
      findUnique: vi.fn(),
      findMany: vi.fn(),
    },
  },
}));

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: repositoryMocks.prisma,
}));

describe('UnitRepository', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('findOneById queries a unit by id', async () => {
    const { UnitRepository: unitRepositoryClass } =
      await import('../../../../src/modules/product-packages/repositories/unit.repository.js');
    const repository = new unitRepositoryClass();

    repositoryMocks.prisma.unit.findUnique.mockResolvedValue({
      unitId: 'unit-1',
      code: 'PCS',
      name: 'piece',
    });

    await repository.findOneById('unit-1');

    expect(repositoryMocks.prisma.unit.findUnique).toHaveBeenCalledWith({
      where: {
        unitId: 'unit-1',
      },
      select: {
        unitId: true,
        code: true,
        name: true,
      },
    });
  });

  it('findManyByIds returns early for empty input and queries id lists', async () => {
    const { UnitRepository: unitRepositoryClass } =
      await import('../../../../src/modules/product-packages/repositories/unit.repository.js');
    const repository = new unitRepositoryClass();

    await expect(repository.findManyByIds([])).resolves.toEqual([]);
    expect(repositoryMocks.prisma.unit.findMany).not.toHaveBeenCalled();

    repositoryMocks.prisma.unit.findMany.mockResolvedValue([]);
    await repository.findManyByIds(['unit-1']);

    expect(repositoryMocks.prisma.unit.findMany).toHaveBeenCalledWith({
      where: {
        unitId: {
          in: ['unit-1'],
        },
      },
      select: {
        unitId: true,
        code: true,
        name: true,
      },
    });
  });

  it('findAll returns all unit DTO fields', async () => {
    const { UnitRepository: unitRepositoryClass } =
      await import('../../../../src/modules/product-packages/repositories/unit.repository.js');
    const repository = new unitRepositoryClass();

    await repository.findAll();

    expect(repositoryMocks.prisma.unit.findMany).toHaveBeenCalledWith({
      select: {
        unitId: true,
        code: true,
        name: true,
      },
    });
  });
});
