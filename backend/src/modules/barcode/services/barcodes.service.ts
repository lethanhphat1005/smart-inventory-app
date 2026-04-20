import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import { logger } from '../../../common/utils/index.js';
import { ProductPackageRepository } from '../../product-packages/repositories/product-package.repository.js';
import {
  BARCODE_CACHE_TTL,
  SCORE_WEIGHT,
  PACKAGE_BARCODE_CONFIDENCE,
} from '../barcode.constant.js';
import { BarcodeApiCacheRepository } from '../repositories/barcode-api-cache.repository.js';
import { PackageBarcodeRepository } from '../repositories/product-package-barcode.repository.js';
import {
  normalizeText,
  normalizeApiPayload,
  tokenizeText,
} from '../utils/index.js';

import type { BarcodeProviderServicePort } from './barcode-provider.service.js';
import type {
  BarcodeApiCache,
  Prisma,
} from '../../../generated/prisma/client.js';
import type { BarcodeCandidateRecord } from '../../product-packages/index.js';
import type { ConfirmBarcodeMappingResponseDto } from '../barcodes.dto.js';
import type {
  BarcodeCandidatePackage,
  ConfirmBarcodeMappingInput,
  NormalizedBarcodeData,
  ScanBarcodeInput,
  ScanBarcodeServiceResult,
  BarcodePrefill,
  TokenMatchResult,
} from '../barcodes.type.js';

export class BarcodesService {
  constructor(
    private readonly packageBarcodeRepository: PackageBarcodeRepository,
    private readonly barcodeApiCacheRepository: BarcodeApiCacheRepository,
    private readonly productPackageRepository: ProductPackageRepository,
    private readonly barcodeProviderService: BarcodeProviderServicePort,
  ) {}

  // Build data (đã chuẩn hóa) cho UI khi không tìm thấy record match
  private buildPrefill(
    normalizedData: NormalizedBarcodeData | null,
  ): BarcodePrefill | undefined {
    if (!normalizedData) {
      return undefined;
    }

    const prefill: BarcodePrefill = {};

    if (normalizedData.normalizedName !== undefined) {
      prefill.name = normalizedData.normalizedName;
    }

    if (normalizedData.normalizedBrand !== undefined) {
      prefill.brand = normalizedData.normalizedBrand;
    }

    if (normalizedData.normalizedPackageText !== undefined) {
      prefill.packageText = normalizedData.normalizedPackageText;
    }

    if (Object.keys(prefill).length === 0) {
      return undefined;
    }

    return prefill;
  }

  // Check barcode cache record đã expire chưa
  shouldUseCache(cache: BarcodeApiCache): boolean {
    // lấy khoảng thời gian barcode cache đã tồn tại
    const cacheAge = Date.now() - cache.fetchedAt.getTime();

    // so sánh thời gian tồn tại với ttl
    return cacheAge <= BARCODE_CACHE_TTL;
  }

  // Check 2 chuỗi token có match không bằng cơ chế token-based matching
  // INFO: Cơ chế token-base matching
  // INFO: so sánh theo tập token thay vì so sánh cả chuỗi
  // INFO: Vd: API: 'coca cola original 500ml', DB: 'coca cola chai 500ml'
  // INFO: - Compare chuỗi:
  // INFO:    "coca cola original 500ml".includes("coca cola chai 500ml")
  // INFO:      => false
  // INFO: - Compare token-based:
  // INFO:    API → ['coca', 'cola', 'original', '500ml']
  // INFO:    DB → ['coca', 'cola', 'chai', '500ml']
  // INFO:     => Overlap: 'coca', 'cola', '500ml' -> Match khá tốt
  private matchTokens(input: {
    expectedText: string | undefined;
    actualText: string | undefined;
    minOverlapRatio?: number;
    minMatchedTokenCount?: number;
  }): TokenMatchResult {
    // token hóa 2 đoạn text so sánh
    const expectedTokens = tokenizeText(input.expectedText);
    const actualTokens = tokenizeText(input.actualText);

    if (expectedTokens.length === 0 || actualTokens.length === 0) {
      return {
        matchedTokenCount: 0,
        expectedTokenCount: expectedTokens.length,
        actualTokenCount: actualTokens.length,
        overlapRatio: 0,
        isMatch: false,
      };
    }

    // chuyển actualTokens thành Set() để lọc token match
    const actualTokenSet = new Set(actualTokens);

    // tính số token match bằng cách:
    // - so sánh từng token trong expectedTokens với token trong actualTokenSet
    // - số token (expectedTokens) match với actualTokenSet là số token match
    const matchedTokenCount = expectedTokens.filter((token) => {
      return actualTokenSet.has(token);
    }).length;

    // tỷ lệ token khớp (số token trùng nhau / tổng số token “kỳ vọng” (từ API))
    const overlapRatio = matchedTokenCount / expectedTokens.length;

    // ngưỡng tối thiểu để coi là match
    const minOverlapRatio = input.minOverlapRatio ?? 0.6;

    // số token trùng tối thiểu
    const minMatchedTokenCount = input.minMatchedTokenCount ?? 1;

    // => match khi thỏa mãn 2 điều kiện:
    // 1. có đủ số token trùng (>= ngưỡng tối thiểu)
    // 2. tỷ lệ match đủ cao (>= ngưỡng tối thiểu)
    const isMatch =
      matchedTokenCount >= minMatchedTokenCount &&
      overlapRatio >= minOverlapRatio;

    return {
      matchedTokenCount,
      expectedTokenCount: expectedTokens.length,
      actualTokenCount: actualTokens.length,
      overlapRatio,
      isMatch,
    };
  }

  // Trả về matching score theo số trường data lấy được
  private getDynamicScoreThreshold(input: {
    hasBrandSignal: boolean;
    hasPackageTextSignal: boolean;
  }): number {
    // Chỉ có name
    if (!input.hasBrandSignal && !input.hasPackageTextSignal) {
      return 40;
    }

    // Có name + 1 tín hiệu phụ
    if (!input.hasBrandSignal || !input.hasPackageTextSignal) {
      return 50;
    }

    // Có đủ name + brand + package
    return 60;
  }

  // chấm điểm matching 1 candidate package dựa trên data barcode đã normalize
  scoreCandidate(input: {
    normalizedData: NormalizedBarcodeData; // data từ API/cache đã normalize
    candidate: BarcodeCandidateRecord; // package từ DB
  }): BarcodeCandidatePackage | null {
    // chuẩn hóa lại data từ DB để so sánh cùng format với API
    const normalizedProductName = normalizeText(input.candidate.productName);
    const normalizedBrand = normalizeText(input.candidate.brand);
    const normalizedDisplayName = normalizeText(
      input.candidate.productPackage.displayName,
    );
    const normalizedVariant = normalizeText(
      input.candidate.productPackage.variant,
    );

    // ưu tiên dùng variant của candidate nếu có
    const packageComparableText = normalizedVariant ?? normalizedDisplayName;

    // Check matching theo brand, name, displayName suffix
    // brand thường ngắn và quan trọng, nên match khá chặt
    const brandMatchResult = this.matchTokens({
      expectedText: input.normalizedData.normalizedBrand,
      actualText: normalizedBrand,
      minOverlapRatio: 1, // tất cả token brand kỳ vọng phải match
      minMatchedTokenCount: 1,
    });

    // name là tín hiệu mạnh nhất, cho phép linh hoạt hơn
    const productNameMatchResult = this.matchTokens({
      expectedText: input.normalizedData.normalizedName,
      actualText: normalizedProductName,
      minOverlapRatio: 0.5,
      minMatchedTokenCount: 1,
    });

    const displayNameMatchResult = this.matchTokens({
      expectedText: input.normalizedData.normalizedName,
      actualText: normalizedDisplayName,
      minOverlapRatio: 0.5,
      minMatchedTokenCount: 1,
    });

    // packageText như 500ml, chai, lon nên match tương đối chặt
    const packageTextMatchResult = this.matchTokens({
      expectedText: input.normalizedData.normalizedPackageText,
      actualText: packageComparableText,
      minOverlapRatio: 0.6,
      minMatchedTokenCount: 1,
    });

    // xét data input có brand và package không
    const hasBrandSignal =
      input.normalizedData.normalizedBrand !== undefined &&
      normalizedBrand !== undefined;
    const hasPackageTextSignal =
      input.normalizedData.normalizedPackageText !== undefined &&
      normalizedVariant !== undefined;

    // số signal hiện có:
    // 1: chỉ có name, 2: name + brand/package, 3: name + brand + package
    const availableSignalCount =
      1 + Number(hasBrandSignal) + Number(hasPackageTextSignal);

    // Lấy score theo ratio
    const brandScore = hasBrandSignal ? brandMatchResult.overlapRatio : 0;
    const nameScore = Math.max(
      productNameMatchResult.overlapRatio,
      displayNameMatchResult.overlapRatio,
    );
    const packageTextScore = hasPackageTextSignal
      ? packageTextMatchResult.overlapRatio
      : 0;

    // tính tổng score matching theo các signal bằng weighted ratio
    // làm tròn 2 số thập phân
    const finalScore = Number(
      (
        nameScore * SCORE_WEIGHT.NAME +
        brandScore * SCORE_WEIGHT.BRAND +
        packageTextScore * SCORE_WEIGHT.PACKAGE
      ).toFixed(2),
    );

    let threshold = this.getDynamicScoreThreshold({
      hasBrandSignal,
      hasPackageTextSignal,
    });

    // strong-name escape hatch
    // nếu name match sâu thì cho qua candidate ngay cả khi brand/package fail
    if (nameScore >= 0.5 && !hasBrandSignal && !hasPackageTextSignal) {
      threshold = 35;
    }

    if (nameScore >= 0.5 && (hasBrandSignal || hasPackageTextSignal)) {
      threshold = Math.min(threshold, 50);
      console.info('Threshold edited to Math.min(threshold, 50)');
    }

    const isBrandMatch = hasBrandSignal && brandMatchResult.isMatch;
    const isNameMatch =
      productNameMatchResult.isMatch || displayNameMatchResult.isMatch;
    const isPackageTextMatch =
      hasPackageTextSignal && packageTextMatchResult.isMatch;

    logger.info(
      {
        productPackageId: input.candidate.productPackage.productPackageId,
        productName: input.candidate.productName,
        displayName: input.candidate.productPackage.displayName,
        normalizedInput: input.normalizedData,
        normalizedCandidate: {
          normalizedProductName,
          normalizedBrand,
          normalizedDisplayName,
          normalizedVariant,
          packageComparableText,
        },
        availableSignalCount,
        hasBrandSignal,
        hasPackageTextSignal,
        brandMatchResult,
        productNameMatchResult,
        displayNameMatchResult,
        packageTextMatchResult,
        scoreSummary: {
          brandScore,
          nameScore,
          packageTextScore,
          finalScore,
          threshold,
        },
      },
      'Barcode candidate scored',
    );

    if (finalScore <= threshold) {
      logger.info(
        {
          productPackageId: input.candidate.productPackage.productPackageId,
          finalScore,
          threshold,
        },
        'Barcode candidate rejected because score is below threshold',
      );

      return null;
    }

    return {
      productPackageId: input.candidate.productPackage.productPackageId,
      score: finalScore,
      scoreDetail: {
        isBrandMatch,
        isNameMatch,
        isPackageTextMatch,
        brandScore,
        nameScore,
        packageTextScore,
        finalScore,
        threshold,
        availableSignalCount,
      },
      productPackage: input.candidate.productPackage,
    };
  }

  // Tạo danh sách candidate package từ dữ liệu normalized (từ cache/API)
  private async buildCandidatesFromPayload(input: {
    storeId: string;
    normalizedData: NormalizedBarcodeData | null;
  }): Promise<BarcodeCandidatePackage[]> {
    if (!input.normalizedData) {
      return [];
    }

    // tokenize input cho query candidate từ productpackage
    const nameTokens = tokenizeText(input.normalizedData.normalizedName);
    const brandTokens = tokenizeText(input.normalizedData.normalizedBrand);
    const packageTokens = tokenizeText(
      input.normalizedData.normalizedPackageText,
    );

    logger.info(
      {
        nameTokens,
        brandTokens,
        packageTokens,
      },
      'Tokenize input for package query',
    );

    const candidates =
      await this.productPackageRepository.findBarcodeCandidates({
        storeId: input.storeId,
        ...(input.normalizedData.normalizedName !== undefined && {
          nameTokens,
        }),
        ...(input.normalizedData.normalizedBrand !== undefined && {
          brandTokens,
        }),
        ...(input.normalizedData.normalizedPackageText !== undefined && {
          packageTokens,
        }),
      });

    // xử lý danh sách candidate
    return (
      candidates
        // chấm điểm từng candidate
        .map((candidate) =>
          this.scoreCandidate({
            normalizedData: input.normalizedData as NormalizedBarcodeData,
            candidate,
          }),
        )
        // loại các candidate không đủ điểm (score < threshold → null)
        .filter((candidate): candidate is BarcodeCandidatePackage => {
          return candidate !== null;
        })
        // sắp xếp theo thứ tự giảm dần
        .sort((leftCandidate, rightCandidate) => {
          return rightCandidate.score - leftCandidate.score;
        })
    );
  }

  // Convert raw payload từ 3rd-party API
  // thành format có thể lưu vào DB (Prisma Json)
  private toCachePayload(rawPayload: unknown): Prisma.InputJsonObject {
    return {
      rawPayload: (rawPayload ?? null) as Prisma.InputJsonValue,
    };
  }

  // Lấy normalized data từ cache hoặc từ 3rd-party API
  private async getNormalizedDataFromLookup(input: {
    barcode: string;
    type?: ScanBarcodeInput['type'];
  }): Promise<NormalizedBarcodeData | null> {
    const cache = await this.barcodeApiCacheRepository.findOneByBarcode(
      input.barcode,
    );

    // 1. Nếu có cache và cache còn usable -> dùng luôn
    if (cache && this.shouldUseCache(cache)) {
      logger.info(
        {
          barcode: input.barcode,
          cacheId: cache.barcodeCacheId,
        },
        'Barcode scan cache hit',
      );

      // update số lần/thời điểm dùng cache
      await this.barcodeApiCacheRepository.markAsUsed(cache.barcodeCacheId);

      return normalizeApiPayload(cache);
    }

    // 2. Nếu cache tồn tại nhưng hết ttl
    if (cache) {
      logger.warn(
        {
          barcode: input.barcode,
          cacheId: cache.barcodeCacheId,
        },
        'Barcode cache is stale and will be refreshed',
      );
    }

    logger.info(
      {
        barcode: input.barcode,
        type: input.type ?? null,
      },
      'Barcode scan provider lookup started',
    );

    // 2.1. Operation nếu cache barcode này chưa tồn tại/tồn tại nhưng hết ttl
    try {
      // lấy data từ 3rd-party API
      const providerResult = await this.barcodeProviderService.lookupBarcode({
        barcode: input.barcode,
        ...(input.type !== undefined && {
          type: input.type,
        }),
      });

      // 3. Lưu cache
      // create nếu cache chưa tồn tại
      // hoặc update nếu cache đã tồn tại nhưng hết ttl
      if (!cache) {
        await this.barcodeApiCacheRepository.createOne({
          barcode: input.barcode,
          payload: this.toCachePayload(providerResult.rawPayload),
          status: providerResult.status,
          ...(providerResult.provider !== undefined && {
            provider: providerResult.provider,
          }),
          ...(providerResult.type !== undefined && {
            type: providerResult.type,
          }),
          ...(providerResult.normalizedName !== undefined && {
            normalizedName: providerResult.normalizedName,
          }),
          ...(providerResult.normalizedBrand !== undefined && {
            normalizedBrand: providerResult.normalizedBrand,
          }),
          ...(providerResult.normalizedPackageText !== undefined && {
            normalizedPackageText: providerResult.normalizedPackageText,
          }),
        });
      } else {
        await this.barcodeApiCacheRepository.updateOne(cache.barcodeCacheId, {
          barcode: input.barcode,
          payload: this.toCachePayload(providerResult.rawPayload),
          status: providerResult.status,
          ...(providerResult.provider !== undefined && {
            provider: providerResult.provider,
          }),
          ...(providerResult.type !== undefined && {
            type: providerResult.type,
          }),
          ...(providerResult.normalizedName !== undefined && {
            normalizedName: providerResult.normalizedName,
          }),
          ...(providerResult.normalizedBrand !== undefined && {
            normalizedBrand: providerResult.normalizedBrand,
          }),
          ...(providerResult.normalizedPackageText !== undefined && {
            normalizedPackageText: providerResult.normalizedPackageText,
          }),
        });
      }

      logger.info(
        {
          barcode: input.barcode,
          status: providerResult.status,
          provider: providerResult.provider ?? null,
        },
        'Barcode scan provider lookup completed',
      );

      return normalizeApiPayload(providerResult);
    } catch (error) {
      if (cache) {
        logger.warn(
          {
            barcode: input.barcode,
            cacheId: cache.barcodeCacheId,
          },
          'Barcode scan falls back to stale cache',
        );

        return normalizeApiPayload(cache);
      }

      throw new CustomError({
        message: 'Failed to lookup barcode from provider',
        status: StatusCodes.BAD_GATEWAY,
        details: {
          err: error,
          barcode: input.barcode,
        },
      });
    }
  }

  async scanBarcode(
    input: ScanBarcodeInput,
  ): Promise<ScanBarcodeServiceResult> {
    const barcode = input.barcode.trim();

    logger.info(
      {
        barcode,
        storeId: input.storeId,
      },
      'Barcode scan started',
    );

    // tìm product package đã có record map với barcode này chưa
    const exactMapping = await this.packageBarcodeRepository.findByBarcode(
      input.storeId,
      barcode,
    );

    // nếu có và đã verify -> trả về ngay
    if (exactMapping?.isVerified) {
      logger.info(
        {
          barcode,
          storeId: input.storeId,
          productPackageId: exactMapping.productPackage.productPackageId,
        },
        'Barcode scan resolved by verified local mapping',
      );

      return {
        resolutionType: 'exact_match',
        productPackage: exactMapping.productPackage,
      };
    }

    // Operation nếu barcode chưa map với product package nào
    // lấy normalized data từ cache/API
    const normalizedData = await this.getNormalizedDataFromLookup({
      barcode,
      ...(input.type !== undefined && {
        type: input.type,
      }),
    });
    // lọc ra các matching package candidates
    const candidates = await this.buildCandidatesFromPayload({
      storeId: input.storeId,
      normalizedData,
    });
    // tạo prefill trả về
    const prefill = this.buildPrefill(normalizedData);

    // nếu có candidate thì trả về các candidate này
    if (candidates.length > 0) {
      logger.info(
        {
          barcode,
          storeId: input.storeId,
          candidateCount: candidates.length,
        },
        'Barcode scan resolved with candidate packages',
      );

      return {
        resolutionType: 'candidate_match',
        candidates,
        ...(prefill !== undefined && {
          prefill,
        }),
      };
    }

    logger.info(
      {
        barcode,
        storeId: input.storeId,
      },
      'Barcode scan resolved as not found',
    );

    // nếu không có candidate thì trả về prefill (normalized data từ cache/API)
    return {
      resolutionType: 'not_found',
      ...(prefill !== undefined && {
        prefill,
      }),
    };
  }

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

  private async createVerifiedMapping(input: {
    storeId: string;
    barcode: string;
    productPackageId: string;
    source: 'user_confirmed' | 'barcode_flow_create';
    type?: ConfirmBarcodeMappingInput['type'];
  }): Promise<ConfirmBarcodeMappingResponseDto> {
    const existingMapping =
      await this.packageBarcodeRepository.findOneByBarcode(input.barcode);

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

    const productPackage = await this.ensureActiveProductPackage(
      input.storeId,
      input.productPackageId,
    );

    // chỉ return data nếu mapping đã tồn tại và đúng package (idempotent)
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

    // độ uy tín của barcode được mapping
    // user_confirmed và barcode_flow_create đều khá uy tín -> 100
    const confidence =
      input.source === 'user_confirmed'
        ? PACKAGE_BARCODE_CONFIDENCE.USER_CONFIRMED
        : PACKAGE_BARCODE_CONFIDENCE.BARCODE_FLOW_CREATE;

    // tạo mapping barcode - package mới
    const createdMapping = await this.packageBarcodeRepository.createMapping({
      barcode: input.barcode,
      productPackageId: input.productPackageId,
      source: input.source,
      confidence,
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

  // tạo barcode khi user xác nhận barcode thuộc package
  async confirmBarcodeMapping(
    input: ConfirmBarcodeMappingInput,
  ): Promise<ConfirmBarcodeMappingResponseDto> {
    return await this.createVerifiedMapping({
      storeId: input.storeId,
      barcode: input.barcode.trim(),
      productPackageId: input.productPackageId,
      source: 'user_confirmed',
      ...(input.type !== undefined && {
        type: input.type,
      }),
    });
  }
}
