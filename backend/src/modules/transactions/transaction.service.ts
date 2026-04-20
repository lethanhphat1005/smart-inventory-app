import 'dotenv/config';
import { StatusCodes } from 'http-status-codes';

import { TransactionDetailRepository } from './repositories/transaction-detail.repository.js';
import { TransactionRepository } from './repositories/transaction.repository.js';
import { CustomError } from '../../common/errors/index.js';
import { appEvents, eventBus } from '../../common/events/event-bus.js';
import { StorageService } from '../../common/utils/index.js';
import {
  normalizePagination,
  buildPaginatedResponse,
} from '../../common/utils/index.js';
import { prisma } from '../../db/prismaClient.js';
import { Prisma } from '../../generated/prisma/client.js';
import { AuditLogRepository } from '../audit-log/index.js';
import { InventoryService } from '../inventories/index.js';
import { ProductPackageService } from '../product-packages/index.js';

import type {
  CreateTransactionDto,
  CreateImportTransactionResponseDto,
  PriceUpdateSuggestionDto,
  CreateExportTransactionResponseDto,
  CreateTransactionItemDto,
  ProductPackageData,
  ListTransactionsQueryDto,
  ListTransactionsResponseDto,
  DetailTransactionResponseDto,
} from './transaction.dto.js';
import type { DbClient } from '../../common/types/db.type.js';

export class TransactionService {
  constructor(
    private readonly transactionRepository: TransactionRepository,
    private readonly productPackageService: ProductPackageService,
    private readonly inventoryService: InventoryService,
  ) {}

  createTxRepository = (db: DbClient) => ({
    transactionRepositoryTx: new TransactionRepository(db),
    transactionDetailRepositoryTx: new TransactionDetailRepository(db),
    auditLogRepositoryTx: new AuditLogRepository(db),
  });

  private ensureNoDuplicateProductPackageIds(data: CreateTransactionDto): void {
    // INFO: Sử dụng Set giúp kiểm tra và loại bỏ phần tử trùng
    const productPackageIds = new Set<string>();

    // Kiểm tra productPackageId trong data đã có trong productPackageIds chưa,
    // nếu true thì báo lỗi trùng package
    for (const item of data.items) {
      if (productPackageIds.has(item.productPackageId)) {
        throw new CustomError({
          message: 'Duplicate productPackageId in transaction items',
          code: 'DUPLICATE_PRODUCT_PACKAGE',
          status: StatusCodes.BAD_REQUEST,
        });
      }

      // ngược lại thì thêm vào productPackageIds
      productPackageIds.add(item.productPackageId);
    }
  }

  private calculateTotalPrice(data: CreateTransactionDto): Prisma.Decimal {
    return data.items.reduce(
      (totalPrice, item) =>
        totalPrice.plus(new Prisma.Decimal(item.unitPrice).mul(item.quantity)),
      new Prisma.Decimal(0),
    );
  }

  private buildPriceUpdateSuggestions(
    data: CreateTransactionDto,
    productPackageMap: Map<string, ProductPackageData>,
  ): PriceUpdateSuggestionDto[] {
    const priceUpdateSuggestions: PriceUpdateSuggestionDto[] = [];

    for (const item of data.items) {
      // gán phần tử trong productPackageMap cho productPackage
      const productPackage = productPackageMap.get(item.productPackageId);

      // skip loop nếu không tìm thấy
      if (!productPackage) {
        continue;
      }

      // skip loop nếu có importPrice và importPrice = unitPrice
      // convert về Decimal để tăng độ chính xác (khi cần)
      if (
        productPackage.importPrice !== null &&
        new Prisma.Decimal(new Prisma.Decimal(productPackage.importPrice)).cmp(
          new Prisma.Decimal(item.unitPrice),
        ) === 0
      ) {
        continue;
      }

      // thêm phần tử Package vào nếu phát hiện unitPrice !== importPrice
      priceUpdateSuggestions.push({
        productPackageId: item.productPackageId,
        currentImportPrice: productPackage.importPrice,
        latestImportUnitPrice: item.unitPrice,
      });
    }

    return priceUpdateSuggestions;
  }

  private async getProductPackageMap(
    storeId: string,
    data: CreateTransactionDto,
  ): Promise<Map<string, ProductPackageData>> {
    // Lấy danh sách productPackageId unique
    const productPackageIds = Array.from(
      new Set(data.items.map((item) => item.productPackageId)),
    );

    // Lấy danh sách ProductPackage
    const productPackages =
      await this.productPackageService.getProductPackagesByIds(
        storeId,
        productPackageIds,
      );

    // INFO: Sử dụng Map để lookup O(1) thay vì find O(n)
    // Map để lookup ProductPackage theo id
    const productPackageMap = new Map(
      productPackages.map((productPackage) => [
        productPackage.productPackageId,
        productPackage,
      ]),
    );

    return productPackageMap;
  }

  private ensureProductPackageExists(
    productPackageId: string,
    productPackageMap: Map<string, ProductPackageData>,
  ): void {
    if (!productPackageMap.has(productPackageId)) {
      throw new CustomError({
        message: 'Product package not found',
        status: StatusCodes.NOT_FOUND,
      });
    }
  }

  private validateItemValues(item: CreateTransactionItemDto): void {
    // quantity phải > 0, số hữu hạn, số nguyên
    if (
      item.quantity < 0 ||
      !Number.isFinite(item.quantity) ||
      !Number.isInteger(item.quantity)
    ) {
      throw new CustomError({
        message: 'Invalid quantity',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    // quantity phải > 0, số hữu hạn
    if (item.unitPrice <= 0 || !Number.isFinite(item.unitPrice)) {
      throw new CustomError({
        message: 'Invalid unitPrice',
        status: StatusCodes.BAD_REQUEST,
      });
    }
  }

  async getTransactionsByStoreId(
    storeId: string,
    query: ListTransactionsQueryDto,
  ): Promise<ListTransactionsResponseDto> {
    const normalizedPagination = normalizePagination(query);

    const { items, totalItems } =
      await this.transactionRepository.findManyByStoreId(storeId, {
        ...query,
        ...normalizedPagination,
      });

    return buildPaginatedResponse(items, totalItems, normalizedPagination);
  }

  async getTransactionById(
    storeId: string,
    transactionId: string,
  ): Promise<DetailTransactionResponseDto> {
    const transaction = await this.transactionRepository.findOne(
      storeId,
      transactionId,
    );

    if (!transaction) {
      throw new CustomError({
        message: 'Transaction not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    // Tạo Signed URL cho imageUrl
    const itemsWithSignedUrls = await Promise.all(
      transaction.items.map(async (item) => ({
        ...item,
        imageUrl: await StorageService.getSignedUrl(
          process.env.STORAGE_BUCKET ?? 'images',
          item.imageUrl,
        ),
      })),
    );

    return {
      ...transaction,
      items: itemsWithSignedUrls,
    };
  }

  async createImportTransaction(
    storeId: string,
    userId: string,
    data: CreateTransactionDto,
  ): Promise<CreateImportTransactionResponseDto> {
    if (data.items.length === 0) {
      throw new CustomError({
        message: 'Items cannot be empty',
        code: 'PACKAGE_ITEM_IS_EMPTY',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    this.ensureNoDuplicateProductPackageIds(data);

    // Lấy productPackage dạng Map để tối ưu lookup
    const productPackageMap = await this.getProductPackageMap(storeId, data);

    // Validate items
    // phòng khi service được gọi bởi service khác mà không qua API
    for (const item of data.items) {
      this.ensureProductPackageExists(item.productPackageId, productPackageMap);
      this.validateItemValues(item);
    }

    const totalPrice = this.calculateTotalPrice(data).toNumber();

    // Xây dựng danh sách package có giá thay đổi
    // frontend sẽ dùng để hỏi user có update importPrice không
    const priceUpdateSuggestions = this.buildPriceUpdateSuggestions(
      data,
      productPackageMap,
    );

    return await prisma.$transaction(async (tx) => {
      const {
        transactionRepositoryTx,
        transactionDetailRepositoryTx,
        auditLogRepositoryTx,
      } = this.createTxRepository(tx);

      const transaction = await transactionRepositoryTx.createOne({
        type: 'import',
        note: data.note ?? null,
        totalPrice,
        userId,
        storeId,
      });

      await transactionDetailRepositoryTx.createMany({
        transactionId: transaction.transactionId,
        items: data.items.map((item) => ({
          productPackageId: item.productPackageId,
          quantity: item.quantity,
          unitPrice: new Prisma.Decimal(item.unitPrice),
        })),
      });

      // Cập nhật tồn kho
      await this.inventoryService.adjustInventoriesForTransaction(
        transaction.transactionId,
        'import',
        userId,
        storeId,
        data.items.map((item) => ({
          productPackageId: item.productPackageId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          transactionId: transaction.transactionId,
        })),
        tx,
      );

      await auditLogRepositoryTx.createLog({
        actionType: 'create',
        entityType: 'Transaction',
        entityId: transaction.transactionId,
        userId,
        storeId,
        note: null,
        oldValue: null,
        newValue: {
          type: transaction.type,
          status: transaction.status,
          note: transaction.note,
          totalPrice: transaction.totalPrice,
          createdAt: transaction.createdAt.toISOString(),
          itemCount: data.items.length,
          items: data.items.map((item) => ({
            productPackageId: item.productPackageId,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
          })),
        } as Prisma.InputJsonObject,
      });

      eventBus.emit(appEvents.LARGE_ORDER_CREATED, {
        storeId: storeId,
        transactionId: transaction.transactionId,
        type: transaction.type,
        totalPrice: transaction.totalPrice,
        itemCount: data.items.length,
      });

      return {
        ...transaction,
        items: data.items,
        priceUpdateSuggestions,
      };
    });
  }

  async createExportTransaction(
    storeId: string,
    userId: string,
    data: CreateTransactionDto,
  ): Promise<CreateExportTransactionResponseDto> {
    if (data.items.length === 0) {
      throw new CustomError({
        message: 'Items cannot be empty',
        code: 'PACKAGE_ITEM_IS_EMPTY',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    this.ensureNoDuplicateProductPackageIds(data);

    // Lấy productPackage dạng Map để tối ưu lookup
    const productPackageMap = await this.getProductPackageMap(storeId, data);

    // Validate items
    // phòng khi service được gọi bởi service khác mà không qua API
    for (const item of data.items) {
      this.ensureProductPackageExists(item.productPackageId, productPackageMap);
      this.validateItemValues(item);
    }

    const totalPrice = this.calculateTotalPrice(data).toNumber();

    return await prisma.$transaction(async (tx) => {
      const {
        transactionRepositoryTx,
        transactionDetailRepositoryTx,
        auditLogRepositoryTx,
      } = this.createTxRepository(tx);

      const transaction = await transactionRepositoryTx.createOne({
        type: 'export',
        note: data.note ?? null,
        totalPrice,
        userId,
        storeId,
      });

      await transactionDetailRepositoryTx.createMany({
        transactionId: transaction.transactionId,
        items: data.items.map((item) => ({
          productPackageId: item.productPackageId,
          quantity: item.quantity,
          unitPrice: new Prisma.Decimal(item.unitPrice),
        })),
      });

      // Cập nhật tồn kho
      // Gọi service vì còn các business rule cần InventoryService xử lý
      await this.inventoryService.adjustInventoriesForTransaction(
        transaction.transactionId,
        'export',
        userId,
        storeId,
        data.items.map((item) => ({
          productPackageId: item.productPackageId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          transactionId: transaction.transactionId,
        })),
        tx,
      );

      await auditLogRepositoryTx.createLog({
        actionType: 'create',
        entityType: 'Transaction',
        entityId: transaction.transactionId,
        userId,
        storeId,
        note: null,
        oldValue: null,
        newValue: {
          type: transaction.type,
          status: transaction.status,
          note: transaction.note,
          totalPrice: transaction.totalPrice,
          createdAt: transaction.createdAt.toISOString(),
          itemCount: data.items.length,
          items: data.items.map((item) => ({
            productPackageId: item.productPackageId,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
          })),
        } as Prisma.InputJsonObject,
      });

      eventBus.emit(appEvents.LARGE_ORDER_CREATED, {
        storeId: storeId,
        transactionId: transaction.transactionId,
        type: transaction.type,
        totalPrice: transaction.totalPrice,
        itemCount: data.items.length,
      });

      return {
        ...transaction,
        items: data.items,
      };
    });
  }
}
