import { StatusCodes } from 'http-status-codes';

import { CategoryRepository } from './repositories/category.repository.js';
import { HiddenDefaultRepository } from './repositories/hidden-default.repository.js';
import { CustomError } from '../../common/errors/index.js';
import { buildAuditDiff } from '../../common/utils/index.js';
import { prisma } from '../../db/prismaClient.js'; // gọi prisma để dùng cơ chế $transaction
import { AuditLogRepository } from '../audit-log/index.js';
import { ProductRepository, productService } from '../products/index.js';

import type {
  CategoryResponseDto,
  CreateCategoryDto,
  UpdateCategoryDto,
} from './category.dto.js';
import type { DbClient } from '../../common/types/index.js';
import type { Prisma } from '../../generated/prisma/client.js';

export class CategoriesService {
  constructor(
    private readonly categoryRepository: CategoryRepository,
    private readonly hiddenDefaultRepository: HiddenDefaultRepository,
  ) {}

  createTxRepositories = (db: DbClient) => ({
    productRepositoryTx: new ProductRepository(db),
    categoryRepositoryTx: new CategoryRepository(db),
    auditLogRepositoryTx: new AuditLogRepository(db),
  });

  public async findAll(storeId: string): Promise<CategoryResponseDto[]> {
    return await this.categoryRepository.findAll(storeId);
  }

  public async createOne(
    storeId: string,
    userId: string,
    payload: CreateCategoryDto,
  ): Promise<CategoryResponseDto> {
    const isDuplicate = await this.categoryRepository.checkDuplicateName(
      storeId,
      payload.name,
    );

    if (isDuplicate) {
      throw new CustomError({
        message: 'Category name already exists',
        status: StatusCodes.CONFLICT,
      });
    }

    return await prisma.$transaction(async (tx) => {
      const { categoryRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      const category = await categoryRepositoryTx.createOne(storeId, payload);

      await auditLogRepositoryTx.createLog({
        actionType: 'create',
        entityType: 'Category',
        entityId: category.categoryId,
        userId,
        storeId,
        oldValue: null,
        newValue: {
          name: category.name,
          description: category.description,
          storeId: category.storeId,
        } as Prisma.InputJsonObject,
      });

      return category;
    });
  }

  public async updateOne(
    storeId: string,
    userId: string,
    categoryId: string,
    data: UpdateCategoryDto,
  ): Promise<CategoryResponseDto> {
    const foundCategory = await this.categoryRepository.findById(categoryId);

    if (!foundCategory) {
      throw new CustomError({
        message: 'Category not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    if (foundCategory.isDefault) {
      throw new CustomError({
        message: 'Default category cannot be edited',
        status: StatusCodes.FORBIDDEN,
      });
    }

    if (foundCategory.storeId !== storeId) {
      throw new CustomError({
        message: 'You do not have permission to update this category',
        status: StatusCodes.FORBIDDEN,
      });
    }

    if (data.name !== undefined && data.name !== foundCategory.name) {
      const isDuplicate = await this.categoryRepository.checkDuplicateName(
        storeId,
        data.name,
      );

      if (isDuplicate) {
        throw new CustomError({
          message: 'Category name already exists',
          status: StatusCodes.CONFLICT,
        });
      }
    }

    const { oldValue, newValue } = buildAuditDiff(
      {
        name: foundCategory.name,
        description: foundCategory.description,
      },
      data,
    );

    return await prisma.$transaction(async (tx) => {
      const { categoryRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      const updatedCategory = await categoryRepositoryTx.updateOne(
        categoryId,
        data,
      );

      // chỉ log khi có thay đổi thực sự
      if (Object.keys(newValue).length > 0) {
        await auditLogRepositoryTx.createLog({
          actionType: 'update',
          entityType: 'Category',
          entityId: updatedCategory.categoryId,
          userId,
          storeId,
          oldValue: oldValue as Prisma.InputJsonObject,
          newValue: newValue as Prisma.InputJsonObject,
        });
      }

      return updatedCategory;
    });
  }

  async getProductsInCategory(categoryId: string): Promise<void> {
    await productService.getProductsByCategory(categoryId);
  }

  public async softDeleteDefault(
    storeId: string,
    categoryId: string,
  ): Promise<void> {
    const foundCategory = await this.categoryRepository.findById(categoryId);

    if (!foundCategory) {
      throw new CustomError({
        message: 'Category not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    if (!foundCategory.isDefault) {
      throw new CustomError({
        message: 'Cannot hide the custom category',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    const isVisible = await this.hiddenDefaultRepository.isDefaultOneVisible(
      storeId,
      categoryId,
    );

    if (!isVisible) {
      throw new CustomError({
        message: 'Default category has already been hidden',
        status: StatusCodes.CONFLICT,
      });
    }

    await this.hiddenDefaultRepository.hideOne(storeId, categoryId);
  }

  public async restoreDefault(
    storeId: string,
    categoryId: string,
  ): Promise<void> {
    const foundCategory = await this.categoryRepository.findById(categoryId);

    if (!foundCategory) {
      throw new CustomError({
        message: 'Category not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    if (!foundCategory.isDefault) {
      throw new CustomError({
        message: 'Cannot hide the custom category',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    const isVisible = await this.hiddenDefaultRepository.isDefaultOneVisible(
      storeId,
      categoryId,
    );

    if (isVisible) {
      throw new CustomError({
        message: 'The default category is already visible',
        status: StatusCodes.CONFLICT,
      });
    }

    await this.hiddenDefaultRepository.unhideOne(storeId, categoryId);
  }

  public async deleteCustomCategory(
    storeId: string,
    userId: string,
    categoryId: string,
    canReassignToUncategorized: boolean,
  ): Promise<void> {
    const foundCategory = await this.categoryRepository.findById(categoryId);

    if (!foundCategory) {
      throw new CustomError({
        message: 'Category not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    if (foundCategory.isDefault) {
      throw new CustomError({
        message: 'Default category cannot be hard deleted',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    if (foundCategory.storeId !== storeId) {
      throw new CustomError({
        message: 'You do not have permission to delete this category',
        status: StatusCodes.FORBIDDEN,
      });
    }

    // Lấy danh sách product đang gắn với category cần xóa để quyết định
    // có thể xóa ngay hay phải yêu cầu FE xác nhận chuyển sang Uncategorized.
    const productsInCategory =
      await productService.getProductsByCategory(categoryId);

    // Nếu category vẫn đang được product sử dụng và FE chưa xác nhận
    // chuyển product sang Uncategorized, backend trả lỗi 409 để FE
    // hiển thị popup xác nhận cho người dùng.
    if (productsInCategory.count > 0 && !canReassignToUncategorized) {
      throw new CustomError({
        message: 'Category is being used by products',
        status: StatusCodes.CONFLICT,
        code: 'CATEGORY_IN_USE',
        details: {
          productCount: productsInCategory.count,
          products: productsInCategory.products,
        },
      });
    }

    // Nếu category không còn product nào sử dụng thì xóa ngay,
    // không cần qua bước chuyển sang Uncategorized.
    if (productsInCategory.count === 0) {
      await prisma.$transaction(async (tx) => {
        const { auditLogRepositoryTx, categoryRepositoryTx } =
          this.createTxRepositories(tx);

        await categoryRepositoryTx.deleteCustomCategory(categoryId);

        await auditLogRepositoryTx.createLog({
          actionType: 'delete',
          entityType: 'Category',
          entityId: categoryId,
          userId,
          storeId,
          oldValue: {
            activeStatus: 'active',
          } as Prisma.InputJsonObject,
          newValue: {
            activeStatus: 'inactive',
          } as Prisma.InputJsonObject,
        });
      });

      return;
    }

    const uncategorizedId = await this.categoryRepository.getUncategorizedId();

    await prisma.$transaction(async (tx) => {
      const {
        productRepositoryTx,
        auditLogRepositoryTx,
        categoryRepositoryTx,
      } = this.createTxRepositories(tx);

      // Phải cập nhật các product sang Uncategorized trước khi xóa category cũ
      // để tránh lỗi ràng buộc khóa ngoại.
      await productRepositoryTx.uncategorizeMany(
        storeId,
        categoryId,
        uncategorizedId,
      );

      // NOTE: Phải chạy sau khi uncategorize products
      // NOTE: vì cần category tham chiếu đến cho product trước
      await categoryRepositoryTx.deleteCustomCategory(categoryId);

      await auditLogRepositoryTx.createLog({
        actionType: 'delete',
        entityType: 'Category',
        entityId: categoryId,
        userId,
        storeId,
        oldValue: {
          activeStatus: 'active',
        } as Prisma.InputJsonObject,
        newValue: {
          activeStatus: 'inactive',
          reassignedProductCount: productsInCategory.count,
        } as Prisma.InputJsonObject,
      });
    });
  }
}
