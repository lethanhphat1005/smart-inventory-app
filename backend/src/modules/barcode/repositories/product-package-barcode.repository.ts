import type { DbClient } from '../../../common/types/index.js';
import type {
  BarcodeType,
  PackageBarcodeSource,
  Prisma,
} from '../../../generated/prisma/client.js';
import type { ProductPackageResponseDto } from '../../product-packages/index.js';
import type {
  CreateBarcodeMappingInput,
  ProductPackageInput,
} from '../barcodes.type.js';

type ProductPackageBarcodeMappingRecord = {
  barcode: string;
  type: BarcodeType | null;
  source: PackageBarcodeSource;
  isVerified: boolean;
  confidence: number | null;
  productPackage: ProductPackageResponseDto;
};

export class PackageBarcodeRepository {
  constructor(private readonly db: DbClient) {}

  private mapProductPackage(
    productPackage: ProductPackageInput,
  ): ProductPackageResponseDto {
    return {
      productPackageId: productPackage.productPackageId,
      displayName: productPackage.displayName,
      variant: productPackage.variant,
      importPrice: productPackage.importPrice?.toNumber() ?? null,
      sellingPrice: productPackage.sellingPrice?.toNumber() ?? null,
      unitId: productPackage.unitId,
      productId: productPackage.productId,
    };
  }

  private mapMappingRecord(mapping: {
    barcode: string;
    type: BarcodeType | null;
    source: PackageBarcodeSource;
    isVerified: boolean;
    confidence: Prisma.Decimal | null;
    productPackage: ProductPackageInput;
  }): ProductPackageBarcodeMappingRecord {
    return {
      barcode: mapping.barcode,
      type: mapping.type,
      source: mapping.source,
      isVerified: mapping.isVerified,
      confidence: mapping.confidence?.toNumber() ?? null,
      productPackage: this.mapProductPackage(mapping.productPackage),
    };
  }

  async findByBarcode(
    storeId: string,
    barcode: string,
  ): Promise<ProductPackageBarcodeMappingRecord | null> {
    const mapping = await this.db.productPackageBarcode.findFirst({
      where: {
        barcode,
        productPackage: {
          activeStatus: 'active',
          product: {
            storeId,
            activeStatus: 'active',
          },
        },
      },
      select: {
        barcode: true,
        type: true,
        source: true,
        isVerified: true,
        confidence: true,
        productPackage: {
          select: {
            productPackageId: true,
            displayName: true,
            variant: true,
            importPrice: true,
            sellingPrice: true,
            unitId: true,
            productId: true,
          },
        },
      },
    });

    return mapping ? this.mapMappingRecord(mapping) : null;
  }

  async findOneByBarcode(
    barcode: string,
  ): Promise<ProductPackageBarcodeMappingRecord | null> {
    const mapping = await this.db.productPackageBarcode.findFirst({
      where: {
        barcode,
      },
      select: {
        barcode: true,
        type: true,
        source: true,
        isVerified: true,
        confidence: true,
        productPackage: {
          select: {
            productPackageId: true,
            displayName: true,
            variant: true,
            importPrice: true,
            sellingPrice: true,
            unitId: true,
            productId: true,
          },
        },
      },
    });

    return mapping ? this.mapMappingRecord(mapping) : null;
  }

  async findByProductPackageId(
    productPackageId: string,
  ): Promise<{ barcode: string; type: string | null } | null> {
    return await this.db.productPackageBarcode.findFirst({
      where: {
        productPackageId,
        productPackage: { activeStatus: 'active' },
      },
      select: {
        barcode: true,
        type: true,
      },
    });
  }

  async createMapping(
    data: CreateBarcodeMappingInput,
  ): Promise<ProductPackageBarcodeMappingRecord> {
    const mapping = await this.db.productPackageBarcode.create({
      data: {
        barcode: data.barcode,
        productPackageId: data.productPackageId,
        source: data.source,
        isVerified: data.isVerified,
        ...(data.confidence !== undefined && {
          confidence: data.confidence,
        }),
        ...(data.type !== undefined && {
          type: data.type,
        }),
      },
      select: {
        barcode: true,
        type: true,
        source: true,
        isVerified: true,
        confidence: true,
        productPackage: {
          select: {
            productPackageId: true,
            displayName: true,
            variant: true,
            importPrice: true,
            sellingPrice: true,
            unitId: true,
            productId: true,
          },
        },
      },
    });

    return this.mapMappingRecord(mapping);
  }

  async existsByBarcode(barcode: string): Promise<boolean> {
    const total = await this.db.productPackageBarcode.count({
      where: {
        barcode,
      },
    });

    return total > 0;
  }

  async deleteByBarcodeAndProductPackageId(
    barcode: string,
    productPackageId: string,
  ): Promise<number> {
    const result = await this.db.productPackageBarcode.deleteMany({
      where: {
        barcode,
        productPackageId,
      },
    });

    return result.count;
  }
}
