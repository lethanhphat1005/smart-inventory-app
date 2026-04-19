import type { DbClient } from '../../../common/types/index.js';
import type { BarcodeApiCache } from '../../../generated/prisma/client.js';
import type { BarcodeApiCacheUpsertInput } from '../barcodes.type.js';

export class BarcodeApiCacheRepository {
  constructor(private readonly db: DbClient) {}

  async findOneByBarcode(barcode: string): Promise<BarcodeApiCache | null> {
    return await this.db.barcodeApiCache.findFirst({
      where: {
        barcode,
      },
      orderBy: {
        fetchedAt: 'desc',
      },
    });
  }

  async createOne(data: BarcodeApiCacheUpsertInput): Promise<BarcodeApiCache> {
    return await this.db.barcodeApiCache.create({
      data: {
        barcode: data.barcode,
        payload: data.payload,
        status: data.status,
        ...(data.provider !== undefined && {
          provider: data.provider,
        }),
        ...(data.type !== undefined && {
          type: data.type,
        }),
        ...(data.normalizedName !== undefined && {
          normalizedName: data.normalizedName,
        }),
        ...(data.normalizedBrand !== undefined && {
          normalizedBrand: data.normalizedBrand,
        }),
        ...(data.normalizedPackageText !== undefined && {
          normalizedPackageText: data.normalizedPackageText,
        }),
      },
    });
  }

  async updateOne(
    barcodeCacheId: string,
    data: BarcodeApiCacheUpsertInput,
  ): Promise<BarcodeApiCache> {
    return await this.db.barcodeApiCache.update({
      where: {
        barcodeCacheId,
      },
      data: {
        payload: data.payload,
        status: data.status,
        fetchedAt: new Date(),
        ...(data.provider !== undefined && {
          provider: data.provider,
        }),
        ...(data.type !== undefined && {
          type: data.type,
        }),
        ...(data.normalizedName !== undefined && {
          normalizedName: data.normalizedName,
        }),
        ...(data.normalizedBrand !== undefined && {
          normalizedBrand: data.normalizedBrand,
        }),
        ...(data.normalizedPackageText !== undefined && {
          normalizedPackageText: data.normalizedPackageText,
        }),
      },
    });
  }

  async markAsUsed(barcodeCacheId: string): Promise<void> {
    await this.db.barcodeApiCache.update({
      where: {
        barcodeCacheId,
      },
      data: {
        lastUsedAt: new Date(),
        hitCount: {
          increment: 1,
        },
      },
    });
  }
}
