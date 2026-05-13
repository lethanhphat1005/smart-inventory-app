import axios from 'axios';

import { UPCITEMDB_API, OPENFOODFACTS_API } from '../barcode.constant.js';
import {
  normalizeText,
  reduceProviderNoise,
  extractPackagingTokensFromText,
} from '../utils/index.js';

import type { BarcodeType } from '../../../generated/prisma/client.js';
import type {
  BarcodeLookupProviderResult,
  NormalizedBarcodeData,
  ExtractedBarcodeData,
} from '../barcodes.type.js';

export type BarcodeLookupInput = {
  barcode: string;
  type?: BarcodeType;
};

type NormalizedPayload = NormalizedBarcodeData;
type ExtractedPayload = ExtractedBarcodeData;

type UpcItemDbItem = {
  ean?: string;
  title?: string;
  description?: string;
  brand?: string;
  size?: string;
  offers?: {
    title?: string;
  }[];
};

type UpcItemDbResponse = {
  code?: string;
  total?: number;
  offset?: number;
  items?: UpcItemDbItem[];
};

type OpenFoodFactsItem = {
  brands?: string;
  product_name?: string;
  product_name_vi?: string;
  product_name_en?: string;
  product_quantity?: string;
  product_quantity_unit?: string;
  quantity?: string;
};

type OpenFoodFactsResponse = {
  product: OpenFoodFactsItem;
  status: number;
  status_verbose: string;
};

export interface BarcodeProviderServicePort {
  lookupBarcode(
    input: BarcodeLookupInput,
  ): Promise<BarcodeLookupProviderResult>;
}

interface BarcodeProviderStrategy {
  providerName: string;

  lookupBarcode(
    input: BarcodeLookupInput,
  ): Promise<BarcodeLookupProviderResult>;
}

// Lớp orchestration cho nhiều provider barcode.
// Service này không parse raw payload của từng API.
// Mỗi provider strategy tự chịu trách nhiệm gọi API + extract normalized field.
export class BarcodeProviderService implements BarcodeProviderServicePort {
  constructor(
    private readonly providers: BarcodeProviderStrategy[] = [
      new OpenFoodFactsBarcodeProvider(),
      new UpcItemDbBarcodeProvider(),
    ],
  ) {}

  async lookupBarcode(
    input: BarcodeLookupInput,
  ): Promise<BarcodeLookupProviderResult> {
    // duyệt qua các provider
    for (const provider of this.providers) {
      const result = await provider.lookupBarcode(input);

      if (result.status === 'valid') {
        return result;
      }
    }

    return {
      rawPayload: null,
      status: 'not_found',
      ...(input.type !== undefined && {
        type: input.type,
      }),
    };
  }
}

class UpcItemDbBarcodeProvider implements BarcodeProviderStrategy {
  providerName = 'upcitemdb';

  async lookupBarcode(
    input: BarcodeLookupInput,
  ): Promise<BarcodeLookupProviderResult> {
    const response = await axios.get<UpcItemDbResponse>(UPCITEMDB_API, {
      params: {
        upc: input.barcode,
      },
      timeout: 3000,
    });

    const responseData = response.data;
    const firstItem = responseData.items?.[0];

    // Không có item nào -> provider không tìm thấy barcode
    if (!firstItem) {
      return {
        rawPayload: responseData,
        status: 'not_found',
        provider: this.providerName,
        ...(input.type !== undefined && {
          type: input.type,
        }),
      };
    }

    const extractedPayload = this.extractAndNormalizeRawPayload(firstItem);

    return {
      rawPayload: responseData,
      status: 'valid',
      provider: this.providerName,
      ...(input.type !== undefined && {
        type: input.type,
      }),
      ...(extractedPayload.normalized.normalizedName !== undefined && {
        normalizedName: extractedPayload.normalized.normalizedName,
      }),
      ...(extractedPayload.normalized.normalizedBrand !== undefined && {
        normalizedBrand: extractedPayload.normalized.normalizedBrand,
      }),
      ...(extractedPayload.normalized.normalizedPackageText !== undefined && {
        normalizedPackageText:
          extractedPayload.normalized.normalizedPackageText,
      }),
      ...(extractedPayload.extracted.extractedName !== undefined && {
        extractedName: extractedPayload.extracted.extractedName,
      }),
      ...(extractedPayload.extracted.extractedBrand !== undefined && {
        extractedBrand: extractedPayload.extracted.extractedBrand,
      }),
      ...(extractedPayload.extracted.extractedPackageText !== undefined && {
        extractedPackageText: extractedPayload.extracted.extractedPackageText,
      }),
    };
  }

  // Extract raw payload của UPCItemDB thành normalized fields
  // để BarcodesService có thể dùng cho candidate matching
  // Và extract raw payload nhưng không normalize cho auto-fill
  private extractAndNormalizeRawPayload(payload: UpcItemDbItem): {
    normalized: NormalizedPayload;
    extracted: ExtractedPayload;
  } {
    // lọc các ký tự gây nhiễu
    const reducedName = reduceProviderNoise(
      `${payload.title} ${payload.offers?.[0]?.title}`,
    );
    const reducedBrand = reduceProviderNoise(payload.brand, {
      removeParenthesesContent: true,
      removeBracketContent: true,
      removePackagingPhrases: false,
      removeGenericWords: false,
      keepNumbers: true,
    });

    // chuẩn hóa payload từ API trước
    const normalizedName = normalizeText(reducedName);
    const normalizedBrand = normalizeText(reducedBrand);
    const normalizedPackageText = this.buildNormalizedPackageText({
      ...(payload.size !== undefined && {
        size: payload.size,
      }),
      ...(payload.title !== undefined && {
        title: payload.title,
      }),
    });

    // trích xuất payload (không chuẩn hóa) cho auto-fill
    const extractedName = reducedName;
    const extractedBrand = reducedBrand;
    const extractedPackageText = normalizedPackageText;

    return {
      normalized: {
        ...(normalizedName !== undefined && {
          normalizedName,
        }),
        ...(normalizedBrand !== undefined && {
          normalizedBrand,
        }),
        ...(normalizedPackageText !== undefined && {
          normalizedPackageText,
        }),
      },
      extracted: {
        ...(extractedName !== undefined && {
          extractedName,
        }),
        ...(extractedBrand !== undefined && {
          extractedBrand,
        }),
        ...(extractedPackageText !== undefined && {
          extractedPackageText,
        }),
      },
    };
  }

  // Trích xuất package text cơ bản như 500ml, 330ml, 1kg...
  // Đây là heuristic đơn giản cho phase hiện tại.
  private buildNormalizedPackageText(input: {
    size?: string | null;
    title?: string | null;
  }): string | undefined {
    const tokens: string[] = [];

    // ưu tiên structured field trước
    if (input.size) {
      tokens.push(input.size);
    }

    // extract từ title
    const extractedFromTitle = extractPackagingTokensFromText(input.title);

    tokens.push(...extractedFromTitle);

    if (tokens.length === 0) {
      return undefined;
    }

    const combined = tokens.join(' ');

    return combined.replace(/\s+/g, ' ').trim().toLowerCase();
  }
}

// TODO: Tách riêng file khi tích hợp thật
// Giữ skeleton để chuẩn bị mở rộng.
class OpenFoodFactsBarcodeProvider implements BarcodeProviderStrategy {
  providerName = 'openfoodfacts';

  async lookupBarcode(
    input: BarcodeLookupInput,
  ): Promise<BarcodeLookupProviderResult> {
    const url = `${OPENFOODFACTS_API}/${input.barcode}.json`;

    const response = await axios.get<OpenFoodFactsResponse>(url, {
      timeout: 5000,
    });

    const responseData = response.data;

    if (
      responseData.status === 0 ||
      responseData.status_verbose === 'product not found'
    ) {
      return {
        rawPayload: responseData,
        status: 'not_found',
        provider: this.providerName,
        ...(input.type !== undefined && {
          type: input.type,
        }),
      };
    }

    const normalizedPayload = this.normalizeRawPayload(
      responseData.product,
    );

    const extractedPayload = this.extractRawPayload(responseData.product);

    // filter các trường cần thiết để lưu cache vì response data size quá lớn
    const filteredResponse: OpenFoodFactsResponse = {
      product: {
        ...(responseData.product?.product_name !== undefined && {
          productName: responseData.product.product_name,
        }),
        ...(responseData.product?.product_name_vi !== undefined && {
          productName: responseData.product.product_name,
        }),
        ...(responseData.product?.product_name_en !== undefined && {
          productName: responseData.product.product_name,
        }),
        ...(responseData.product?.brands !== undefined && {
          brand: responseData.product.brands,
        }),
        ...(responseData.product?.quantity !== undefined && {
          quantity: responseData.product.quantity,
        }),
        ...(responseData.product?.product_quantity !== undefined && {
          productQuantity: responseData.product.product_quantity,
        }),
        ...(responseData.product?.product_quantity_unit !== undefined && {
          productQuantityUnit: responseData.product.product_quantity_unit,
        }),
      },
      status: responseData.status,
      status_verbose: responseData.status_verbose,
    };

    return {
      rawPayload: filteredResponse,
      status: 'valid',
      provider: this.providerName,
      ...(input.type !== undefined && {
        type: input.type,
      }),
      ...(normalizedPayload.normalizedName !== undefined && {
        normalizedName: normalizedPayload.normalizedName,
      }),
      ...(normalizedPayload.normalizedBrand !== undefined && {
        normalizedBrand: normalizedPayload.normalizedBrand,
      }),
      ...(normalizedPayload.normalizedPackageText !== undefined && {
        normalizedPackageText: normalizedPayload.normalizedPackageText,
      }),
      ...(extractedPayload.extractedName !== undefined && {
        extractedName: extractedPayload.extractedName,
      }),
      ...(extractedPayload.extractedBrand !== undefined && {
        extractedBrand: extractedPayload.extractedBrand,
      }),
      ...(extractedPayload.extractedPackageText !== undefined && {
        extractedPackageText: extractedPayload.extractedPackageText,
      }),
    };
  }

  private normalizeRawPayload(
    payload: OpenFoodFactsItem,
  ): NormalizedPayload {
    const normalizedName = normalizeText(
      payload.product_name ??
        payload.product_name_vi ??
        payload.product_name_en,
    );
    const normalizedBrand = normalizeText(payload.brands);
    const normalizedPackageText = normalizeText(
      payload?.quantity ??
        (payload?.product_quantity !== undefined &&
        payload?.product_quantity_unit !== undefined
          ? `${payload.product_quantity} ${payload.product_quantity_unit}`
          : undefined),
    );

    return {
      ...(normalizedName !== undefined && {
        normalizedName,
      }),
      ...(normalizedBrand !== undefined && {
        normalizedBrand,
      }),
      ...(normalizedPackageText !== undefined && {
        normalizedPackageText,
      }),
    };
  }

  private extractRawPayload(payload: OpenFoodFactsItem): ExtractedPayload {
    const extractedName =
      payload.product_name_vi ??
      payload.product_name ??
      payload.product_name_en;

    const extractedBrand = payload.brands;
    const extractedPackageText =
      payload?.quantity ??
      (payload?.product_quantity !== undefined &&
      payload?.product_quantity_unit !== undefined
        ? `${payload.product_quantity} ${payload.product_quantity_unit}`
        : undefined);

    return {
      ...(extractedName !== undefined && {
        extractedName,
      }),
      ...(extractedBrand !== undefined && {
        extractedBrand,
      }),
      ...(extractedPackageText !== undefined && {
        extractedPackageText,
      }),
    };
  }
}
