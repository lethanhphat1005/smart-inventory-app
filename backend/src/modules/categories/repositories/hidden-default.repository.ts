import { prisma } from '../../../db/prismaClient.js';

export class HiddenDefaultRepository {
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
