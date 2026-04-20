import { getPaginationSkip } from '../../../common/utils/index.js';

import type {
  DbClient,
  ListPaginationResponseDto,
} from '../../../common/types/index.js';
import type { Prisma } from '../../../generated/prisma/client.js';
import type {
  CreateProductPackageInput,
  PackageQueryDto,
  ProductPackageDetailResponseDto,
  UpdateProductPackageInput,
  ProductPackageSimpleResponseDto,
  ProductPackageResponseForTransaction,
  CreateInventoryInput,
  ProductPackageResponseDto,
  CreatePackageAndInventoryResponseDto,
  BarcodeCandidateRecord,
} from '../product-package.dto.js';

const productPackageResponseSelect = {
  productPackageId: true,
  displayName: true,
  variant: true,
  importPrice: true,
  sellingPrice: true,
  createdAt: true,
  unit: {
    select: {
      unitId: true,
      code: true,
      name: true,
    },
  },
  product: {
    select: {
      productId: true,
      imageUrl: true,
      category: {
        select: {
          categoryId: true,
          name: true,
        },
      },
    },
  },
  inventory: {
    select: {
      inventoryId: true,
      quantity: true,
      reorderThreshold: true,
    },
  },
} satisfies Prisma.ProductPackageSelect;

type ProductPackageRecord = Prisma.ProductPackageGetPayload<{
  select: typeof productPackageResponseSelect;
}>;

export class ProductPackageRepository {
  constructor(private readonly db: DbClient) {}

  // convert importPrice, sellingPrice từ Prisma Decimal sang number | null.
  private toResponseDto(
    productPackage: ProductPackageRecord,
  ): ProductPackageDetailResponseDto {
    return {
      productPackageId: productPackage.productPackageId,
      displayName: productPackage.displayName,
      variant: productPackage.variant,
      importPrice: productPackage.importPrice?.toNumber() ?? null,
      sellingPrice: productPackage.sellingPrice?.toNumber() ?? null,
      createdAt: productPackage.createdAt,
      unit: productPackage.unit,
      category: productPackage.product.category,
      product: {
        productId: productPackage.product.productId,
        imageUrl: productPackage.product.imageUrl,
      },
      inventory: productPackage.inventory,
    };
  }

  async findManyByStore(
    storeId: string,
    query: PackageQueryDto,
  ): Promise<ListPaginationResponseDto<ProductPackageDetailResponseDto>> {
    const { page, limit, categoryId, sortBy, sortOrder } = query;

    const where: Prisma.ProductPackageWhereInput = {
      activeStatus: 'active',
      product: {
        storeId,
        activeStatus: 'active',
        ...(categoryId ? { categoryId } : {}),
      },
    };

    const [productPackages, totalItems] = await this.db.$transaction([
      this.db.productPackage.findMany({
        where,
        orderBy: {
          [sortBy]: sortOrder,
        },
        skip: getPaginationSkip({ page, limit }),
        take: limit,
        select: productPackageResponseSelect,
      }),
      this.db.productPackage.count({
        where,
      }),
    ]);

    const items = productPackages.map((productPackage) =>
      this.toResponseDto(productPackage),
    );

    return {
      items,
      totalItems,
    };
  }

  async findManyByProductId(
    storeId: string,
    productId: string,
  ): Promise<ProductPackageDetailResponseDto[]> {
    const productPackages = await this.db.productPackage.findMany({
      where: {
        productId,
        activeStatus: 'active',
        product: {
          storeId,
          activeStatus: 'active',
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
      select: productPackageResponseSelect,
    });

    return productPackages.map((productPackage) =>
      this.toResponseDto(productPackage),
    );
  }

  async findManyByProductIdForNameSync(
    storeId: string,
    productId: string,
  ): Promise<ProductPackageSimpleResponseDto[]> {
    return await this.db.productPackage.findMany({
      where: {
        productId,
        activeStatus: 'active',
        product: {
          storeId,
          activeStatus: 'active',
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
      select: {
        productPackageId: true,
        displayName: true,
        variant: true,
      },
    });
  }

  async findOne(
    storeId: string,
    productPackageId: string,
  ): Promise<ProductPackageResponseDto | null> {
    const productPackage = await this.db.productPackage.findFirst({
      where: {
        productPackageId,
        activeStatus: 'active',
        product: {
          storeId,
          activeStatus: 'active',
        },
      },
      select: {
        productPackageId: true,
        displayName: true,
        variant: true,
        importPrice: true,
        sellingPrice: true,
        unitId: true,
        productId: true,
      },
    });

    return productPackage
      ? {
          ...productPackage,
          importPrice: productPackage.importPrice?.toNumber() ?? null,
          sellingPrice: productPackage.sellingPrice?.toNumber() ?? null,
        }
      : null;
  }

  async findDetailOne(
    storeId: string,
    productPackageId: string,
  ): Promise<ProductPackageDetailResponseDto | null> {
    const productPackage = await this.db.productPackage.findFirst({
      where: {
        productPackageId,
        activeStatus: 'active',
        product: {
          storeId,
          activeStatus: 'active',
        },
      },
      select: productPackageResponseSelect,
    });

    return productPackage ? this.toResponseDto(productPackage) : null;
  }

  async findManyActiveByIds(
    storeId: string,
    productPackageIds: string[],
  ): Promise<ProductPackageResponseForTransaction[]> {
    if (productPackageIds.length === 0) {
      return [];
    }

    const productPackages = await this.db.productPackage.findMany({
      where: {
        productPackageId: {
          in: productPackageIds,
        },
        activeStatus: 'active',
        product: {
          storeId,
          activeStatus: 'active',
        },
      },
      select: {
        productPackageId: true,
        displayName: true,
        variant: true,
        importPrice: true,
        sellingPrice: true,
      },
    });

    return productPackages.map((productPackage) => ({
      productPackageId: productPackage.productPackageId,
      displayName: productPackage.displayName,
      variant: productPackage.variant,
      importPrice: productPackage.importPrice?.toNumber() ?? null,
      sellingPrice: productPackage.sellingPrice?.toNumber() ?? null,
    }));
  }

  async findProductIdsHavingActivePackages(
    storeId: string,
    productIds: string[],
  ): Promise<string[]> {
    if (productIds.length === 0) {
      return [];
    }

    const productPackages = await this.db.productPackage.findMany({
      where: {
        productId: {
          in: productIds,
        },
        activeStatus: 'active',
        product: {
          storeId,
          activeStatus: 'active',
        },
      },
      distinct: ['productId'],
      select: {
        productId: true,
      },
    });

    return productPackages.map((productPackage) => productPackage.productId);
  }

  async findActiveByProductIdAndUnitId(
    productId: string,
    unitId: string,
  ): Promise<{ productPackageId: string } | null> {
    return await this.db.productPackage.findFirst({
      where: {
        productId,
        unitId,
        activeStatus: 'active',
      },
      select: {
        productPackageId: true,
      },
    });
  }

  async findBarcodeCandidates(input: {
    storeId: string;
    nameTokens?: string[];
    brandTokens?: string[];
    packageTokens?: string[];
  }): Promise<BarcodeCandidateRecord[]> {
    const orConditions: Prisma.ProductPackageWhereInput[] = [];

    for (const token of input.nameTokens ?? []) {
      orConditions.push({
        product: {
          name: {
            contains: token,
            mode: 'insensitive',
          },
        },
      });

      orConditions.push({
        displayName: {
          contains: token,
          mode: 'insensitive',
        },
      });
    }

    for (const token of input.brandTokens ?? []) {
      orConditions.push({
        product: {
          brand: {
            contains: token,
            mode: 'insensitive',
          },
        },
      });
    }

    for (const token of input.packageTokens ?? []) {
      orConditions.push({
        variant: {
          contains: token,
          mode: 'insensitive',
        },
      });

      orConditions.push({
        displayName: {
          contains: token,
          mode: 'insensitive',
        },
      });
    }

    if (orConditions.length === 0) {
      return [];
    }

    const productPackages = await this.db.productPackage.findMany({
      where: {
        activeStatus: 'active',
        product: {
          storeId: input.storeId,
          activeStatus: 'active',
        },
        OR: orConditions,
      },
      orderBy: [
        {
          displayName: 'asc',
        },
      ],
      take: 30,
      select: {
        productPackageId: true,
        displayName: true,
        variant: true,
        importPrice: true,
        sellingPrice: true,
        unitId: true,
        productId: true,
        product: {
          select: {
            name: true,
            brand: true,
          },
        },
      },
    });

    return productPackages.map((productPackage) => ({
      productName: productPackage.product.name,
      brand: productPackage.product.brand,
      productPackage: {
        productPackageId: productPackage.productPackageId,
        displayName: productPackage.displayName,
        variant: productPackage.variant,
        importPrice: productPackage.importPrice?.toNumber() ?? null,
        sellingPrice: productPackage.sellingPrice?.toNumber() ?? null,
        unitId: productPackage.unitId,
        productId: productPackage.productId,
      },
    }));
  }

  async createOneAndInventory(
    packageData: CreateProductPackageInput,
    inventoryData: CreateInventoryInput,
  ): Promise<CreatePackageAndInventoryResponseDto> {
    const productPackage = await this.db.productPackage.create({
      data: {
        ...packageData,
        inventory: {
          create: inventoryData,
        },
      },
      select: {
        productPackageId: true,
        displayName: true,
        variant: true,
        importPrice: true,
        sellingPrice: true,
        createdAt: true,
        productId: true,
        unitId: true,
        inventory: {
          select: {
            inventoryId: true,
            quantity: true,
            reorderThreshold: true,
          },
        },
      },
    });

    return {
      ...productPackage,
      importPrice: productPackage.importPrice?.toNumber() ?? null,
      sellingPrice: productPackage.sellingPrice?.toNumber() ?? null,
    };
  }

  async updateOne(
    productPackageId: string,
    data: UpdateProductPackageInput,
  ): Promise<ProductPackageResponseDto> {
    const productPackage = await this.db.productPackage.update({
      where: { productPackageId },
      data: {
        ...(data.displayName !== undefined && {
          displayName: data.displayName,
        }),
        ...(data.variant !== undefined && {
          variant: data.variant,
        }),
        ...(data.importPrice !== undefined && {
          importPrice: data.importPrice,
        }),
        ...(data.sellingPrice !== undefined && {
          sellingPrice: data.sellingPrice,
        }),
        ...(data.unitId !== undefined && {
          unitId: data.unitId,
        }),
      },
      select: {
        productPackageId: true,
        displayName: true,
        variant: true,
        importPrice: true,
        sellingPrice: true,
        unitId: true,
        productId: true,
      },
    });

    return {
      ...productPackage,
      importPrice: productPackage.importPrice?.toNumber() ?? null,
      sellingPrice: productPackage.sellingPrice?.toNumber() ?? null,
    };
  }

  async updateDisplayNameWithProduct(
    productPackageId: string,
    newDisplayName: string,
  ): Promise<ProductPackageSimpleResponseDto> {
    return await this.db.productPackage.update({
      where: { productPackageId },
      data: {
        displayName: newDisplayName,
      },
      select: {
        productPackageId: true,
        displayName: true,
        variant: true,
      },
    });
  }

  async softDeleteOne(
    productPackageId: string,
  ): Promise<{ productPackageId: string }> {
    return await this.db.productPackage.update({
      where: { productPackageId },
      data: {
        activeStatus: 'inactive',
      },
      select: {
        productPackageId: true,
      },
    });
  }

  async softDeleteManyByProductId(productId: string): Promise<number> {
    const deleted = await this.db.productPackage.updateMany({
      where: { productId },
      data: {
        activeStatus: 'inactive',
      },
    });

    return deleted.count;
  }
}
