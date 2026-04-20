import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import { ProductPackageRepository } from '../../product-packages/repositories/product-package.repository.js';
import { PACKAGE_BARCODE_CONFIDENCE } from '../barcode.constant.js';
import { PackageBarcodeRepository } from '../repositories/product-package-barcode.repository.js';

import type { ConfirmBarcodeMappingResponseDto } from '../barcodes.dto.js';
import type {
  CreateBarcodeMappingForNewPackageInput,
  RemoveProductPackageBarcodeMappingInput,
} from '../barcodes.type.js';

export class ProductPackageBarcodeService {
  constructor(
    private readonly packageBarcodeRepository: PackageBarcodeRepository,
    private readonly productPackageRepository: ProductPackageRepository,
  ) {}

  private async ensureActiveProductPackage(
    storeId: string,
    productPackageId: string,
  ) {
    const productPackage = await this.productPackageRepository.findOne(
      storeId,
      productPackageId,
    );

    if (!productPackage) {
      throw new CustomError({
        message: 'Product package not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    return productPackage;
  }

  async createPackageBarcodeMapping(
    input: CreateBarcodeMappingForNewPackageInput,
  ): Promise<ConfirmBarcodeMappingResponseDto> {
    const normalizedBarcode = input.barcode.trim();

    const productPackage = await this.ensureActiveProductPackage(
      input.storeId,
      input.productPackageId,
    );

    const existingMapping =
      await this.packageBarcodeRepository.findOneByBarcode(normalizedBarcode);

    // 1 barcode không được map sang 2 package khác nhau
    if (
      existingMapping &&
      existingMapping.productPackage.productPackageId !== input.productPackageId
    ) {
      throw new CustomError({
        message: 'Barcode mapping already exists',
        status: StatusCodes.CONFLICT,
      });
    }

    // return data nếu mapping đã tồn tại và đúng package (idempotent)
    if (existingMapping) {
      return {
        barcode: existingMapping.barcode,
        type: existingMapping.type,
        source: existingMapping.source,
        confidence: existingMapping.confidence,
        isVerified: existingMapping.isVerified,
        productPackage,
      };
    }

    const createdMapping = await this.packageBarcodeRepository.createMapping({
      barcode: normalizedBarcode,
      productPackageId: input.productPackageId,
      source: 'barcode_flow_create',
      confidence: PACKAGE_BARCODE_CONFIDENCE.BARCODE_FLOW_CREATE,
      isVerified: true,
      ...(input.type !== undefined && {
        type: input.type,
      }),
    });

    return {
      barcode: createdMapping.barcode,
      type: createdMapping.type,
      source: createdMapping.source,
      confidence: createdMapping.confidence,
      isVerified: createdMapping.isVerified,
      productPackage,
    };
  }

  async removePackageBarcodeMapping(
    input: RemoveProductPackageBarcodeMappingInput,
  ): Promise<void> {
    await this.ensureActiveProductPackage(
      input.storeId,
      input.productPackageId,
    );

    const normalizedBarcode = input.barcode.trim();

    const existingMapping =
      await this.packageBarcodeRepository.findOneByBarcode(normalizedBarcode);

    if (!existingMapping) {
      throw new CustomError({
        message: 'Barcode mapping not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    if (
      existingMapping.productPackage.productPackageId !== input.productPackageId
    ) {
      throw new CustomError({
        message: 'Barcode does not belong to this product package',
        status: StatusCodes.CONFLICT,
      });
    }

    await this.packageBarcodeRepository.deleteByBarcodeAndProductPackageId(
      normalizedBarcode,
      input.productPackageId,
    );
  }
}
