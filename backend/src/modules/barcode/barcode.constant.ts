export const BARCODE_CACHE_TTL = 1000 * 60 * 60 * 24 * 7; // 7 ngày

export const SCORE_WEIGHT = {
  NAME: 70,
  PACKAGE: 20,
  BRAND: 10,
} as const;

export const PACKAGE_BARCODE_CONFIDENCE = {
  USER_CONFIRMED: 100,
  BARCODE_FLOW_CREATE: 100,
  ADMIN: 100,
  SEED: 90,
  API_IMPORT: 60,
} as const;
