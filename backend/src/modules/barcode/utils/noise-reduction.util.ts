export type ReduceNoiseOptions = {
  // Có loại bỏ nội dung trong ngoặc tròn "(...)"
  removeParenthesesContent?: boolean;

  // Có loại bỏ nội dung trong ngoặc vuông "[...]"
  removeBracketContent?: boolean;

  // Có loại bỏ cụm packaging / count / size phổ biến hay không
  removePackagingPhrases?: boolean;

  // Có loại bỏ một số generic marketing words hay không
  removeGenericWords?: boolean;

  // Có giữ lại số hay không
  keepNumbers?: boolean;
};

const DEFAULT_REDUCE_NOISE_OPTIONS: Required<ReduceNoiseOptions> = {
  removeParenthesesContent: true,
  removeBracketContent: true,
  removePackagingPhrases: true,
  removeGenericWords: false,
  keepNumbers: true,
};

// Các cụm nhiễu thường gặp trong title từ provider
// chỉ nên để các cụm tương đối generic và ít rủi ro làm mất product name thật
const PACKAGING_PHRASE_PATTERNS: RegExp[] = [
  /\bpack\s+of\s+\d+\b/gi,
  /\bcase\s+of\s+\d+\b/gi,
  /\bbox\s+of\s+\d+\b/gi,
  /\bset\s+of\s+\d+\b/gi,
  /\bbundle\s+of\s+\d+\b/gi,
  /\b\d+\s*pack\b/gi,
  /\b\d+\s*packs\b/gi,
  /\b\d+\s*count\b/gi,
  /\b\d+\s*ct\b/gi,
  /\b\d+\s*x\s*\d+(?:[.,]\d+)?\s*(?:ml|l|g|kg|oz|lb)\b/gi,
  /\b\d+(?:[.,]\d+)?\s*(?:ml|l|g|kg|oz|lb|fl\s*oz)\b/gi,
  /\b(?:can|cans|bottle|bottles|jar|jars|bag|bags|box|boxes|tray|trays)\b/gi,
];

// Generic words, mặc định không bật vì dễ xóa nhầm
const GENERIC_WORD_PATTERNS: RegExp[] = [
  /\bflavor\b/gi,
  /\bflavoured\b/gi,
  /\bsoda\b/gi,
  /\bpop\b/gi,
  /\bdrink\b/gi,
  /\bfood\b/gi,
];

// Pattern để lọc ra các text liên quan đến packageText
const PACKAGING_TOKEN_REGEX = [
  /\b\d+(?:[.,]\d+)?\s*(?:ml|l|g|kg|oz|lb|fl\s*oz)\b/gi, // 330ml, 2.7oz
  /\b\d+\b/g, // 12, 24
  /\b(pack|packs|box|boxes|can|cans|bottle|bottles|bag|bags|tray|trays)\b/gi,
  /\bx\b/gi, // "24 x 330ml"
];

// Chuẩn hóa khoảng trắng sau mỗi bước replace
const normalizeWhitespace = (value: string): string => {
  return value.replace(/\s+/g, ' ').trim();
};

// Giảm nhiễu ở mức string chung cho dữ liệu provider
// bằng cách cleanup theo pattern phổ biến
export const reduceProviderNoise = (
  value: string | null | undefined,
  options?: ReduceNoiseOptions,
): string | undefined => {
  if (!value) {
    return undefined;
  }

  const mergedOptions: Required<ReduceNoiseOptions> = {
    ...DEFAULT_REDUCE_NOISE_OPTIONS,
    ...options,
  };

  let nextValue = value;

  // loại nội dung trong ngoặc tròn
  if (mergedOptions.removeParenthesesContent) {
    nextValue = nextValue.replace(/\([^)]*\)/g, ' ');
  }

  // loại nội dung trong ngoặc vuông
  if (mergedOptions.removeBracketContent) {
    nextValue = nextValue.replace(/\[[^\]]*\]/g, ' ');
  }

  // đồng nhất một số dấu phân tách thường gặp thành khoảng trắng
  nextValue = nextValue.replace(/[-_/|]+/g, ' ');

  if (mergedOptions.removePackagingPhrases) {
    for (const pattern of PACKAGING_PHRASE_PATTERNS) {
      nextValue = nextValue.replace(pattern, ' ');
    }
  }

  if (mergedOptions.removeGenericWords) {
    for (const pattern of GENERIC_WORD_PATTERNS) {
      nextValue = nextValue.replace(pattern, ' ');
    }
  }

  // nếu không muốn giữ số thì loại luôn token số
  if (!mergedOptions.keepNumbers) {
    nextValue = nextValue.replace(/\b\d+(?:[.,]\d+)?\b/g, ' ');
  }

  // loại bớt ký tự đặc biệt nhưng vẫn giữ chữ, số và khoảng trắng
  nextValue = nextValue.replace(/[^\p{L}\p{N}\s]/gu, ' ');

  nextValue = normalizeWhitespace(nextValue);

  if (nextValue.length === 0) {
    return undefined;
  }

  return nextValue;
};

// trích xuất các từ liên quan đến package để lấy packageText
export const extractPackagingTokensFromText = (
  value: string | null | undefined,
): string[] => {
  if (!value) {
    return [];
  }

  const matches: string[] = [];

  for (const pattern of PACKAGING_TOKEN_REGEX) {
    const found = value.match(pattern);

    if (found) {
      matches.push(...found);
    }
  }

  return matches
    .map((token) => token.toLowerCase().trim())
    .filter((token) => token.length > 0);
};
