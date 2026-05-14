import { prisma } from '../../../db/prismaClient.js';

import type { HiddenDefaultResponseDto } from '../category.dto.js';

export class HiddenDefaultRepository {
  async findManyByStore(storeId: string): Promise<HiddenDefaultResponseDto[]> {
    const result = await prisma.hidedDefault.findMany({
      where: {
        storeId,
      },
      orderBy: {
        category: {
          name: 'asc'
        }
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

    return result.map((item) => {
      return {
        categoryId: item.category.categoryId,
        name: item.category.name,
        description: item.category.description,
      };
    });
  }

  async hideOne(storeId: string, categoryId: string): Promise<void> {
    await prisma.hidedDefault.create({
      data: {
        storeId,
        categoryId,
      },
    });
  }

  async unhideOne(storeId: string, categoryId: string): Promise<void> {
    await prisma.hidedDefault.delete({
      where: {
        storeId_categoryId: {
          storeId,
          categoryId,
        },
      },
    });
  }

  async isDefaultOneVisible(
    storeId: string,
    categoryId: string,
  ): Promise<boolean> {
    const hiddenRecord = await prisma.hidedDefault.findUnique({
      where: {
        storeId_categoryId: {
          storeId,
          categoryId,
        },
      },
    });

    return !hiddenRecord;
  }
}
