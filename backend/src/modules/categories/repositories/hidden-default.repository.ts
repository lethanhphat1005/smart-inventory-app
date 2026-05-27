import type { DbClient } from '../../../common/types/index.js';
import type { HiddenDefaultResponseDto } from '../category.dto.js';

export class HiddenDefaultRepository {
    constructor(private readonly db: DbClient) {}

  async findManyByStore(storeId: string): Promise<HiddenDefaultResponseDto[]> {
    const result = await this.db.hidedDefault.findMany({
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
    await this.db.hidedDefault.create({
      data: {
        storeId,
        categoryId,
      },
    });
  }

  async unhideOne(storeId: string, categoryId: string): Promise<void> {
    await this.db.hidedDefault.delete({
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
    const hiddenRecord = await this.db.hidedDefault.findUnique({
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
