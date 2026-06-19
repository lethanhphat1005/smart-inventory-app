import 'dotenv/config';
import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import {
  buildAuditDiff,
  buildPaginatedResponse,
  normalizePagination,
} from '../../../common/utils/index.js';
import { StorageService } from '../../../common/utils/index.js';
import { prisma } from '../../../db/prismaClient.js'; // gọi prisma để dùng cơ chế $transaction
import { AuditLogRepository } from '../../audit-log/index.js';
import { InventoryRepository } from '../../inventories/index.js';
import { ProductRepository } from '../../products/index.js';
import { ProductPackageRepository } from '../repositories/product-package.repository.js';
import { UnitRepository } from '../repositories/unit.repository.js';

import type { DbClient } from '../../../common/types/db.type.js';
import type { Prisma } from '../../../generated/prisma/client.js';
import type { ProductSimpleResponseDto } from '../../products/index.js';
import type {
  CreateProductPackageAndInventoryDto,
  CreateProductPackageAndInventoryInput,
  ListProductPackagesResponseDto,
  PackageQueryDto,
  ProductPackageDetailResponseDto,
  ProductPackageResponseDto,
  UpdateProductPackageDto,
  UpdateProductPackageInput,
  ProductPackageResponseForTransaction,
  CreatePackageAndInventoryResponseDto,
} from '../product-package.dto.js';

export class ProductPackageService {
  constructor(
    private readonly productPackageRepository: ProductPackageRepository,
    private readonly unitRepository: UnitRepository,
    private readonly productRepository: ProductRepository,
  ) {}

  createTxRepositories = (db: DbClient) => ({
    productPackageRepositoryTx: new ProductPackageRepository(db),
    auditLogRepositoryTx: new AuditLogRepository(db),
    inventoryRepositoryTx: new InventoryRepository(db),
  });

  private async findExistedProductPackage(
    storeId: string,
    productPackageId: string,
  ): Promise<ProductPackageResponseDto> {
    const existingProductPackage = await this.productPackageRepository.findOne(
      storeId,
      productPackageId,
    );

    if (!existingProductPackage) {
      throw new CustomError({
        message: 'Product package not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    return existingProductPackage;
  }

  private async findExistedProduct(
    storeId: string,
    productId: string,
  ): Promise<ProductSimpleResponseDto> {
    const existingProduct = await this.productRepository.findOne(
      storeId,
      productId,
    );

    if (!existingProduct) {
      throw new CustomError({
        message: 'Product not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    return existingProduct;
  }

  private async getSignedUrlForItemImageUrl<
    T extends { product: { imageUrl: string | null } },
  >(items: T[]): Promise<T[]> {
    return await Promise.all(
      items.map(async (item) => ({
        ...item,
        product: {
          ...item.product,
          imageUrl: await StorageService.getSignedUrl(
            process.env.STORAGE_BUCKET ?? 'images',
            item.product.imageUrl,
          ),
        },
      })),
    );
  }

  async getProductPackagesByStore(
    storeId: string,
    query: PackageQueryDto,
  ): Promise<ListProductPackagesResponseDto> {
    const normalizedPagination = normalizePagination(query);

    const { items, totalItems } =
      await this.productPackageRepository.findManyByStore(storeId, {
        ...query,
        ...normalizedPagination,
      });

    const itemsWithSignedUrls = await this.getSignedUrlForItemImageUrl(items);

    return buildPaginatedResponse(
      itemsWithSignedUrls,
      totalItems,
      normalizedPagination,
    );
  }

  async getProductPackagesByProductId(
    storeId: string,
    productId: string,
  ): Promise<ProductPackageDetailResponseDto[]> {
    // check product tồn tại
    await this.findExistedProduct(storeId, productId);

    const packages = await this.productPackageRepository.findManyByProductId(
      storeId,
      productId,
    );

    return await this.getSignedUrlForItemImageUrl(packages);
  }

  async getProductPackageById(
    storeId: string,
    productPackageId: string,
  ): Promise<ProductPackageDetailResponseDto> {
    const productPackage = await this.productPackageRepository.findDetailOne(
      storeId,
      productPackageId,
    );

    if (!productPackage) {
      throw new CustomError({
        message: 'Product package not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    const packageWithSignedUrl = {
      ...productPackage,
      product: {
        ...productPackage.product,
        imageUrl: await StorageService.getSignedUrl(
          process.env.STORAGE_BUCKET ?? 'images',
          productPackage.product.imageUrl,
        ),
      },
    };

    return packageWithSignedUrl;
  }

  // dùng cho transaction để tạo TransactionDetail, xử lý duplicate
  async getProductPackagesByIds(
    storeId: string,
    productPackageIds: string[],
  ): Promise<ProductPackageResponseForTransaction[]> {
    return await this.productPackageRepository.findManyActiveByIds(
      storeId,
      productPackageIds,
    );
  }

  async getProductIdsHavingPackages(
    storeId: string,
    productIds: string[],
  ): Promise<string[]> {
    const ids =
      await this.productPackageRepository.findProductIdsHavingActivePackages(
        storeId,
        productIds,
      );

    return ids;
  }

  private buildDisplayName(productName: string, unitName: string): string {
    return [productName, unitName].join(' ');
  }

  async createProductPackageAndInventory(
    storeId: string,
    userId: string,
    productId: string,
    data: CreateProductPackageAndInventoryDto[],
  ): Promise<CreatePackageAndInventoryResponseDto[]> {
    const product = await this.findExistedProduct(storeId, productId);

    const unitIds = data.map((item) => item.package.unitId);
    const unitIdSet = [...new Set(unitIds)]; // tạo Set và convert thành string[]
    const units = await this.unitRepository.findManyByIds(unitIdSet);

    if (!units) {
      throw new CustomError({
        message: 'Unit not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    // check không được tạo 2 package có unit & variant trùng nhau
    const seenPackage = new Set<string>();

    for (const item of data) {
      const key = `${item.package.unitId}|${item.package.variant ?? ''}`;

      if (seenPackage.has(key)) {
        throw new CustomError({
          message: `Duplicate package: unitId=${item.package.unitId}, variant=${item.package.variant ?? 'null'}`,
          status: StatusCodes.BAD_REQUEST,
        });
      }

      seenPackage.add(key);
    }

    // check undefined value để dùng non-null assertion ở nơi call
    if (units.length !== new Set(unitIds).size) {
      throw new CustomError({
        message: 'One or more units not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    // check product đã có package với (unit, variant) này chưa
    const packageKeys = data.map((item) => ({
      unitId: item.package.unitId,
      variant: item.package.variant ?? null,
    }));

    const existingPackage =
      await this.productPackageRepository.findOneExistedVariant(
        productId,
        packageKeys,
      );

    if (existingPackage) {
      throw new CustomError({
        message: 'Product package variant already exists',
        status: StatusCodes.CONFLICT,
      });
    }

    const displayNameMap = new Map(
      units.map((unit) => [
        unit.unitId,
        this.buildDisplayName(product.name, unit.name),
      ]),
    );

    const createData: CreateProductPackageAndInventoryInput[] = data.map(
      (item) => ({
        package: {
          ...item.package,
          productId,
          displayName: displayNameMap.get(item.package.unitId)!, // non-null assertion
        },
        inventory: item.inventory,
      }),
    );

    return await prisma.$transaction(async (tx) => {
      const { productPackageRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      const createdPackageInventory =
        await productPackageRepositoryTx.createManyAndInventory(createData);

      await Promise.all(
        createdPackageInventory.map(async (item) => {
          await auditLogRepositoryTx.createLog({
            actionType: 'create',
            entityType: 'ProductPackage',
            entityId: item.productPackageId,
            userId,
            storeId,
            oldValue: null,
            newValue: {
              productId: item.productId,
              displayName: item.displayName,
              variant: item.variant,
              unitId: item.unitId,
              importPrice: item.importPrice,
              sellingPrice: item.sellingPrice,
            } as Prisma.InputJsonObject,
          });

          await auditLogRepositoryTx.createLog({
            actionType: 'create',
            entityType: 'Inventory',
            entityId: item.inventory?.inventoryId ?? null,
            userId,
            storeId,
            oldValue: null,
            newValue: {
              quantity: item.inventory?.quantity,
              reorderThreshold: item.inventory?.reorderThreshold,
              productPackageId: item.productPackageId,
            } as Prisma.InputJsonObject,
          });
        }),
      );

      return createdPackageInventory;
    });
  }

  async updateProductPackage(
    storeId: string,
    userId: string,
    productPackageId: string,
    data: UpdateProductPackageDto,
  ): Promise<ProductPackageResponseDto> {
    const existingProductPackage = await this.findExistedProductPackage(
      storeId,
      productPackageId,
    );

    const updateData: UpdateProductPackageInput = {};

    if (data.unitId !== undefined) {
      const product = await this.findExistedProduct(
        storeId,
        existingProductPackage.productId,
      );
      const unit = await this.unitRepository.findOneById(data.unitId);

      if (!unit) {
        throw new CustomError({
          message: 'Unit not found',
          status: StatusCodes.NOT_FOUND,
        });
      }

      updateData.unitId = data.unitId;

      const newDisplayName = this.buildDisplayName(product.name, unit.name);

      updateData.displayName = newDisplayName;
    }

    if (data.variant !== undefined) {
      updateData.variant = data.variant;
    }

    if (data.importPrice !== undefined) {
      updateData.importPrice = data.importPrice;
    }

    if (data.sellingPrice !== undefined) {
      updateData.sellingPrice = data.sellingPrice;
    }

    // detect các trường được update trước khi ghi vào log
    // tránh ghi log data không cần thiết
    const { oldValue, newValue } = buildAuditDiff(
      {
        displayName: existingProductPackage.displayName,
        variant: existingProductPackage.variant,
        importPrice: existingProductPackage.importPrice,
        sellingPrice: existingProductPackage.sellingPrice,
        unitId: existingProductPackage.unitId,
      },
      updateData,
    );

    return await prisma.$transaction(async (tx) => {
      const { productPackageRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      const updatedPackage = await productPackageRepositoryTx.updateOne(
        productPackageId,
        updateData,
      );

      // chỉ log khi có thay đổi thực sự
      if (Object.keys(newValue).length > 0) {
        await auditLogRepositoryTx.createLog({
          actionType: 'update',
          entityType: 'ProductPackage',
          entityId: updatedPackage.productPackageId,
          userId,
          storeId,
          note: null,
          oldValue: oldValue as Prisma.InputJsonObject,
          newValue: newValue as Prisma.InputJsonObject,
        });
      }

      return updatedPackage;
    });
  }

  async softDeleteProductPackage(
    storeId: string,
    userId: string,
    productPackageId: string,
  ): Promise<void> {
    await this.findExistedProductPackage(storeId, productPackageId);

    // xóa inventory tương ứng khi xóa product package
    await prisma.$transaction(async (tx) => {
      const {
        productPackageRepositoryTx,
        inventoryRepositoryTx,
        auditLogRepositoryTx,
      } = this.createTxRepositories(tx);

      const softDeletedPackage =
        await productPackageRepositoryTx.softDeleteOne(productPackageId);

      const softDeletedInventory =
        await inventoryRepositoryTx.softDeleteOneByPackageId(productPackageId);

      await auditLogRepositoryTx.createLog({
        actionType: 'delete',
        entityType: 'ProductPackage',
        entityId: softDeletedPackage.productPackageId,
        userId,
        storeId,
        note: null,
        oldValue: {
          activeStatus: 'active',
        } as Prisma.InputJsonObject,
        newValue: {
          activeStatus: 'inactive',
          affectedInventory: {
            inventoryId: softDeletedInventory.inventoryId,
            activeStatus: 'inactive',
          },
        } as Prisma.InputJsonObject,
      });
    });
  }
}
