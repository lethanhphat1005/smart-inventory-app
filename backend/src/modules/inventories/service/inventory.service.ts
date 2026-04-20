import crypto from 'crypto';

import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import {
  buildPaginatedResponse,
  normalizePagination,
  StorageService,
} from '../../../common/utils/index.js';
import { prisma } from '../../../db/prismaClient.js';
import { TransactionType } from '../../../generated/prisma/enums.js';
import { AuditLogRepository } from '../../audit-log/index.js';
import { InventoryRepository } from '../repository/inventory.repository.js';

import type { DbClient } from '../../../common/types/index.js';
import type { Prisma } from '../../../generated/prisma/client.js';
import type { InventoryEventPublisher } from '../../alerts/inventory-event.publisher.js';
import type {
  CreateInventoryDto,
  InventoryAdjustmentResponseDto,
  InventoryDetailResponseDto,
  ListInventoriesQueryDto,
  ListInventoriesResponseDto,
  LowStockInventoriesResponseDto,
  UpdateInventoryDto,
  InventoryForTransactionData,
  BatchInventoryAdjustmentDto,
  InventoryListItemDto,
} from '../dto/inventory.dto.js';

export class InventoryService {
  constructor(
    private readonly inventoryRepository: InventoryRepository,
    private readonly inventoryEventPublisher: InventoryEventPublisher,
  ) {}

  createTxRepositories = (db: DbClient) => ({
    inventoryRepositoryTx: new InventoryRepository(db),
    auditLogRepositoryTx: new AuditLogRepository(db),
  });

  private async getSignedUrlForItemImageUrl(
    items: InventoryListItemDto[],
  ): Promise<InventoryListItemDto[]> {
    return await Promise.all(
      items.map(async (item) => ({
        ...item,
        productPackage: {
          ...item.productPackage,
          product: {
            ...item.productPackage.product,
            imageUrl: await StorageService.getSignedUrl(
              process.env.STORAGE_BUCKET ?? 'images',
              item.productPackage.product.imageUrl,
            ),
          },
        },
      })),
    );
  }

  // Hàm helper dùng chung để kiểm tra sự tồn tại của kho hàng,
  // ném lỗi 404 nếu không tìm thấy
  private async getExistingInventory(
    storeId: string,
    productPackageId: string,
  ): Promise<InventoryDetailResponseDto> {
    const inventory = await this.inventoryRepository.findOneByProductPackageId(
      storeId,
      productPackageId,
    );

    if (!inventory) {
      throw new CustomError({
        message: 'Inventory not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    return inventory;
  }

  async getInventoriesByStoreId(
    storeId: string,
    query: ListInventoriesQueryDto,
  ): Promise<ListInventoriesResponseDto> {
    const normalizedPagination = normalizePagination(query);

    const { items, totalItems } =
      await this.inventoryRepository.findManyByStoreId(storeId, {
        ...query,
        ...normalizedPagination,
      });

    const itemsWithSignedUrl = await this.getSignedUrlForItemImageUrl(items);

    return buildPaginatedResponse(
      itemsWithSignedUrl,
      totalItems,
      normalizedPagination,
    );
  }

  async getLowStockInventoriesByStoreId(
    storeId: string,
    query: ListInventoriesQueryDto,
  ): Promise<LowStockInventoriesResponseDto> {
    const normalizedPagination = normalizePagination(query);

    const { items, totalItems } =
      await this.inventoryRepository.findLowStockByStoreId(storeId, {
        ...query,
        ...normalizedPagination,
      });

    const itemsWithSignedUrl = await this.getSignedUrlForItemImageUrl(items);

    return buildPaginatedResponse(
      itemsWithSignedUrl,
      totalItems,
      normalizedPagination,
    );
  }

  async getInventoryByProductPackageId(
    storeId: string,
    productPackageId: string,
  ): Promise<InventoryDetailResponseDto> {
    return await this.getExistingInventory(storeId, productPackageId);
  }

  async updateInventory(
    storeId: string,
    productPackageId: string,
    data: UpdateInventoryDto,
    userId: string,
  ): Promise<InventoryDetailResponseDto> {
    const existingInventory = await this.getExistingInventory(
      storeId,
      productPackageId,
    );

    // MỞ TRANSACTION TẠI SERVICE
    return await prisma.$transaction(async (tx) => {
      const { inventoryRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      const updated = await inventoryRepositoryTx.updateOne(
        existingInventory.inventoryId,
        data,
      );

      await auditLogRepositoryTx.createLog({
        actionType: 'update',
        entityType: 'Inventory',
        entityId: existingInventory.inventoryId,
        userId,
        storeId,
        oldValue: {
          reorderThreshold: existingInventory.reorderThreshold,
        } as Prisma.InputJsonObject,
        newValue: {
          reorderThreshold: updated.reorderThreshold,
          productPackageId: updated.productPackage.productPackageId,
        } as Prisma.InputJsonObject,
      });

      return updated;
    });
  }

  async adjustInventories(
    storeId: string,
    userId: string,
    data: BatchInventoryAdjustmentDto,
  ): Promise<InventoryAdjustmentResponseDto[]> {
    const { items } = data;

    // 1. TẠO MÃ LÔ ĐỂ GOM NHÓM VÀ TÌM KIẾM
    // Đảm bảo bạn đã import crypto ở đầu file: import crypto from 'crypto';
    const batchId = crypto.randomBytes(3).toString('hex').toUpperCase();
    const searchPrefix = `[Lô-${batchId}]`;

    const productPackageIds = items.map((item) => item.productPackageId);
    const existingInventories =
      await this.inventoryRepository.findManyActiveByProductPackageIds(
        storeId,
        productPackageIds,
      );

    if (existingInventories.length !== items.length) {
      throw new CustomError({
        message:
          'Một hoặc nhiều sản phẩm không tồn tại trong kho hoặc đã bị vô hiệu hóa!',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    // Map lại để lookup O(1)
    const inventoryMap = new Map(
      existingInventories.map((inv) => [inv.productPackageId, inv]),
    );

    // 2. Validate nhanh số lượng xuất/giảm trước khi mở Transaction
    for (const item of items) {
      const existing = inventoryMap.get(item.productPackageId)!;

      if (item.type === 'decrease' && existing.quantity < item.quantity) {
        throw new CustomError({
          message: `Số lượng giảm không được lớn hơn tồn kho hiện tại (Sản phẩm: ${item.productPackageId})`,
          status: StatusCodes.BAD_REQUEST,
        });
      }
    }

    // MẢNG HỨNG CÁC SẢN PHẨM BỊ LỆCH KHO NHIỀU
    const discrepancies: Array<{
      productName: string;
      systemQuantity: number;
      actualQuantity: number;
    }> = [];

    // 3. Mở Transaction
    const results = await prisma.$transaction(async (tx) => {
      const { inventoryRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      // Thêm inventoryId vào Type trả về nội bộ để lát phục vụ eventPublisher
      const adjustments: (InventoryAdjustmentResponseDto & {
        inventoryId: string;
      })[] = [];

      for (const item of items) {
        const existingInventory = inventoryMap.get(item.productPackageId)!;

        // Cập nhật số lượng
        const updated = await inventoryRepositoryTx.adjustQuantity(
          existingInventory.inventoryId,
          item.type,
          item.quantity,
        );

        const changedQty = updated.quantity - existingInventory.quantity;

        // KIỂM TRA ĐỘ LỆCH VÀ PUSH VÀO MẢNG (KHÔNG BẮN EVENT Ở ĐÂY NỮA)
        if (Math.abs(changedQty) >= 5) {
          discrepancies.push({
            productName:
              existingInventory.productPackage.displayName ?? 'Sản phẩm',
            systemQuantity: existingInventory.quantity,
            actualQuantity: updated.quantity,
          });
        }

        // TẠO GHI CHÚ CHỨA MÃ LÔ
        const finalNote = item.note
          ? `${searchPrefix} ${item.note}`
          : searchPrefix;

        // Ghi AuditLog độc lập cho từng productPackageId
        await auditLogRepositoryTx.createLog({
          actionType: 'update',
          entityType: 'Inventory',
          entityId: existingInventory.inventoryId,
          userId,
          storeId,
          note: finalNote,
          oldValue: {
            quantity: existingInventory.quantity,
          } as Prisma.InputJsonObject,
          newValue: {
            quantity: updated.quantity,
            changedQuantity: changedQty,
            adjustmentType: item.type,
            reason: item.reason ?? null,
            productPackageId: updated.productPackage.productPackageId,
          } as Prisma.InputJsonObject,
        });

        adjustments.push({
          inventoryId: existingInventory.inventoryId,
          productPackageId: updated.productPackage.productPackageId,
          previousQuantity: existingInventory.quantity,
          currentQuantity: updated.quantity,
          changedQuantity: changedQty,
          adjustmentType: item.type,
          reason: item.reason ?? null,
          note: item.note ?? null,
          updatedAt: updated.updatedAt,
        });
      }

      return adjustments;
    });

    // 4. PHÁT TÍN HIỆU LỆCH KHO GỘP (Chỉ bắn 1 lần duy nhất ngoài Transaction)
    if (discrepancies.length > 0) {
      this.inventoryEventPublisher.emitInventoryDiscrepancy({
        storeId,
        adjustmentId: batchId, // Mã Lô sẽ làm referenceId gửi qua FE
        items: discrepancies,
      });
    }

    // 5. Phát tín hiệu hàng loạt thay vì lặp qua emitInventoryChanged
    const changedEventItems = results.map((r) => ({
      inventoryId: r.inventoryId,
      oldQuantity: r.previousQuantity,
      newQuantity: r.currentQuantity,
    }));

    this.inventoryEventPublisher.emitBatchInventoryChanged({
      storeId,
      items: changedEventItems,
    });

    // Strip bớt inventoryId trước khi trả về FE để tuân thủ DTO
    return results.map(({ inventoryId: _, ...rest }) => rest);
  }

  async createInventory(
    storeId: string,
    data: CreateInventoryDto,
    userId: string,
    db?: DbClient,
  ): Promise<InventoryDetailResponseDto> {
    const inventoryRepository = db
      ? new InventoryRepository(db)
      : this.inventoryRepository;

    const isBelongsToStore =
      await inventoryRepository.checkProductPackageBelongsToStore(
        storeId,
        data.productPackageId,
      );

    if (!isBelongsToStore) {
      throw new CustomError({
        message: 'Product Package not found or does not belong to this store',
        status: StatusCodes.NOT_FOUND,
      });
    }

    const existingInventory =
      await inventoryRepository.getInventoryStatusByProductPackageId(
        data.productPackageId,
      );

    return await prisma.$transaction(async (tx) => {
      const { inventoryRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      if (existingInventory) {
        if (existingInventory.activeStatus === 'active') {
          throw new CustomError({
            message:
              'Inventory record already exists and is active for this Product Package',
            status: StatusCodes.CONFLICT,
          });
        } else {
          const restored = await inventoryRepositoryTx.restoreInventory(
            existingInventory.inventoryId,
            data,
          );

          await auditLogRepositoryTx.createLog({
            actionType: 'create',
            entityType: 'Inventory',
            entityId: restored.inventoryId,
            userId,
            storeId,
            oldValue: { activeStatus: 'inactive' } as Prisma.InputJsonObject,
            newValue: {
              activeStatus: 'active',
              quantity: restored.quantity,
              reorderThreshold: restored.reorderThreshold,
              productPackageId: restored.productPackage.productPackageId,
            } as Prisma.InputJsonObject,
          });

          return restored;
        }
      }

      const created = await inventoryRepository.createOne(data);

      await auditLogRepositoryTx.createLog({
        actionType: 'create',
        entityType: 'Inventory',
        entityId: created.inventoryId,
        userId,
        storeId,
        oldValue: null,
        newValue: {
          quantity: created.quantity,
          reorderThreshold: created.reorderThreshold,
          productPackageId: created.productPackage.productPackageId,
        } as Prisma.InputJsonObject,
      });

      return created;
    });
  }

  async adjustInventoriesForTransaction(
    transactionId: string, // transactionId để ghi log
    transactionType: TransactionType,
    userId: string,
    storeId: string,
    items: InventoryForTransactionData[],
    db: DbClient,
  ): Promise<void> {
    // NOTE: Truyền db (TransactionClient) từ ngoài vào
    // NOTE: để đảm bảo tất cả query chạy trong cùng transaction
    const inventoryRepository = new InventoryRepository(db);

    // Lấy tất cả inventory đang active theo danh sách productPackageId
    const inventoryRecords =
      await inventoryRepository.findManyActiveByProductPackageIds(
        storeId,
        // map để lấy list productPackageId từ items
        items.map((item) => item.productPackageId),
      );

    if (inventoryRecords.length !== items.length) {
      throw new CustomError({
        message:
          'Một hoặc nhiều sản phẩm không tồn tại trong kho hoặc đã bị vô hiệu hóa!',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    // Tạo Map để lookup inventory theo productPackageId (O(1))
    const inventoryMap = new Map(
      inventoryRecords.map((inventory) => [
        inventory.productPackageId,
        inventory,
      ]),
    );

    // Transform items về data shape của hàm adjustManyForTransaction
    const inventoryItems = items.map((item) => {
      // Lấy inventory hiện tại từ Map
      const inventory = inventoryMap.get(item.productPackageId);

      // Defensive check (trên lý thuyết không xảy ra vì đã filter)
      if (!inventory) {
        throw new CustomError({
          message: 'Inventory not found for product package',
          status: StatusCodes.NOT_FOUND,
        });
      }

      // Nếu là export transaction, check `current quantity - new quantity < 0`
      if (transactionType === 'export') {
        if (inventory.quantity < item.quantity) {
          throw new CustomError({
            message: 'Insufficient inventory quantity',
            code: 'INSUFFICIENT_INVENTORY',
            status: StatusCodes.BAD_REQUEST,
          });
        }
      }

      // Trả về data shape của tham số items hàm repository
      return {
        inventoryId: inventory.inventoryId,
        productPackageId: item.productPackageId,
        quantity: inventory.quantity, // quantity hiện tại
        transactionQuantity: item.quantity, // quantity trong transaction
        unitPrice: item.unitPrice,
        transactionId: item.transactionId,
      };
    });

    // 1. CHẠY GIAO DỊCH DATABASE (TRANSACTION)
    await prisma.$transaction(async (tx) => {
      const { inventoryRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      switch (transactionType) {
        case 'import': {
          await inventoryRepositoryTx.increaseManyForTransaction(
            inventoryItems,
          );

          for (const item of inventoryItems) {
            await auditLogRepositoryTx.createLog({
              actionType: 'update',
              entityType: 'Inventory',
              entityId: item.inventoryId,
              userId,
              storeId,
              note: null,
              oldValue: {
                quantity: item.quantity,
              } as Prisma.InputJsonObject,
              newValue: {
                quantity: item.quantity + item.transactionQuantity,
                changedQuantity: item.transactionQuantity,
                adjustmentType: transactionType,
                reason: 'import transaction',
                productPackageId: item.productPackageId,
                transactionId,
              } as Prisma.InputJsonObject,
            });
          }

          return;
        }
        case 'export': {
          const failedProductPackageIds =
            await inventoryRepositoryTx.decreaseManyForTransaction(
              inventoryItems,
            );

          // nếu có inventory bị lỗi khi trừ, return lỗi + packageId tương ứng
          if (failedProductPackageIds.size > 0) {
            throw new CustomError({
              message: 'Insufficient inventory quantity',
              code: 'INSUFFICIENT_INVENTORY',
              status: StatusCodes.BAD_REQUEST,
              details: {
                productPackageIds: failedProductPackageIds,
              },
            });
          }

          for (const item of inventoryItems) {
            await auditLogRepositoryTx.createLog({
              actionType: 'update',
              entityType: 'Inventory',
              entityId: item.inventoryId,
              userId,
              storeId,
              note: 'export transaction',
              oldValue: {
                quantity: item.quantity,
              } as Prisma.InputJsonObject,
              newValue: {
                quantity: item.quantity - item.transactionQuantity,
                changedQuantity: item.transactionQuantity,
                adjustmentType: transactionType,
                reason: null,
                productPackageId: item.productPackageId,
                transactionId,
              } as Prisma.InputJsonObject,
            });
          }

          return;
        }
        default:
          throw new CustomError({
            message: `Unsupported transaction type: ${transactionType}`,
            status: StatusCodes.BAD_REQUEST,
          });
      }
    });

    // 2. PHÁT TÍN HIỆU NGAY TẠI ĐÂY
    const changedItems = inventoryItems.map((item) => {
      const newQuantity =
        transactionType === 'import'
          ? item.quantity + item.transactionQuantity
          : item.quantity - item.transactionQuantity;

      return {
        inventoryId: item.inventoryId,
        oldQuantity: item.quantity,
        newQuantity: newQuantity,
      };
    });

    this.inventoryEventPublisher.emitBatchInventoryChanged({
      storeId,
      items: changedItems,
    });
  }

  async deleteInventory(
    storeId: string,
    productPackageId: string,
    userId: string,
  ): Promise<void> {
    const existingInventory = await this.getExistingInventory(
      storeId,
      productPackageId,
    );

    await prisma.$transaction(async (tx) => {
      const { inventoryRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      await inventoryRepositoryTx.delete(existingInventory.inventoryId);

      await auditLogRepositoryTx.createLog({
        actionType: 'delete',
        entityType: 'Inventory',
        entityId: existingInventory.inventoryId,
        userId,
        storeId,
        oldValue: { activeStatus: 'active' } as Prisma.InputJsonObject,
        newValue: {
          activeStatus: 'inactive',
          productPackageId: existingInventory.productPackage.productPackageId,
        } as Prisma.InputJsonObject,
      });
    });
  }
}
