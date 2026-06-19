import { prisma } from '../../../db/prismaClient.js';

import type { UnitResponseDto } from '../product-package.dto.js';

export class UnitRepository {
  async findOneById(unitId: string): Promise<UnitResponseDto | null> {
    return await prisma.unit.findUnique({
      where: {
        unitId,
      },
      select: {
        unitId: true,
        code: true,
        name: true,
      },
    });
  }

  async findManyByIds(unitIds: string[]): Promise<UnitResponseDto[]> {
    if (unitIds.length === 0) {
      return [];
    }

    return await prisma.unit.findMany({
      where: {
        unitId: {
          in: unitIds,
        },
      },
      select: {
        unitId: true,
        code: true,
        name: true,
      },
    });
  }

  async findAll(): Promise<UnitResponseDto[]> {
    return await prisma.unit.findMany({
      select: {
        unitId: true,
        code: true,
        name: true,
      },
    });
  }
}
