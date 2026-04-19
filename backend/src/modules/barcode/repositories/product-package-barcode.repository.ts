import type { DbClient } from '../../../common/types/index.js';
import type {
  BarcodeType,
  PackageBarcodeSource,
  Prisma,
} from '../../../generated/prisma/client.js';
import type { ProductPackageResponseDto } from '../../product-packages/index.js';

type ProductPackageBarcodeMappingRecord = {
  barcode: string;
  type: BarcodeType | null;
  source: PackageBarcodeSource;
  isVerified: boolean;
  productPackage: ProductPackageResponseDto;
};

type ProductPackageInput = {
  productPackageId: string;
  displayName: string | null;
  variant: string | null;
  importPrice: Prisma.Decimal | null;
  sellingPrice: Prisma.Decimal | null;
  unitId: string;
  productId: string;
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
    productPackage: ProductPackageInput;
  }): ProductPackageBarcodeMappingRecord {
    return {
      barcode: mapping.barcode,
      type: mapping.type,
      source: mapping.source,
      isVerified: mapping.isVerified,
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

  // WARN: Không có logic tạo confidence
  async createMapping(data: {
    barcode: string;
    productPackageId: string;
    source: PackageBarcodeSource;
    isVerified: boolean;
    type?: BarcodeType;
  }): Promise<ProductPackageBarcodeMappingRecord> {
    const mapping = await this.db.productPackageBarcode.create({
      data: {
        barcode: data.barcode,
        productPackageId: data.productPackageId,
        source: data.source,
        isVerified: data.isVerified,
        ...(data.type !== undefined && {
          type: data.type,
        }),
      },
      select: {
        barcode: true,
        type: true,
        source: true,
        isVerified: true,
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
}
