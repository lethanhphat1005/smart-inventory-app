import type { NormalizedBarcodeData } from '../barcodes.type.js';

// Normalize string trước để chuẩn bị cho normalize data
export const normalizeText = (
  value: string | null | undefined,
): string | undefined => {
  if (!value) {
    return undefined;
  }

  const normalizedValue = value
    .normalize('NFD') // convert thành ký tự dạng chuẩn hóa
    .replace(/\p{Diacritic}/gu, '') // bỏ dấu ("cà phê" -> "ca phe")
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, ' ') // bỏ ký tự đặc biệt
    .replace(/\s+/g, ' ') // xóa space thừa
    .trim(); // xóa space đầu/cuối

  if (normalizedValue.length === 0) {
    return undefined;
  }

  return normalizedValue;
};

// Chuẩn hóa response data từ 3rd-party API barcode
export const normalizeApiPayload = (payload: {
  normalizedName?: string | null;
  normalizedBrand?: string | null;
  normalizedPackageText?: string | null;
}): NormalizedBarcodeData | null => {
  const normalizedData: NormalizedBarcodeData = {};
  const normalizedName = normalizeText(payload.normalizedName);
  const normalizedBrand = normalizeText(payload.normalizedBrand);
  const normalizedPackageText = normalizeText(payload.normalizedPackageText);

  if (normalizedName !== undefined) {
    normalizedData.normalizedName = normalizedName;
  }

  if (normalizedBrand !== undefined) {
    normalizedData.normalizedBrand = normalizedBrand;
  }

  if (normalizedPackageText !== undefined) {
    normalizedData.normalizedPackageText = normalizedPackageText;
  }

  if (Object.keys(normalizedData).length === 0) {
    return null;
  }

  return normalizedData;
};
