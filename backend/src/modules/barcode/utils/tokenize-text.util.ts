// Token hóa chuỗi cho cơ chế so sánh token-based matching,
// vd: "coca cola original 500ml" -> ['coca', 'cola', 'original', '500ml']
export const tokenizeText = (value: string | undefined): string[] => {
  if (!value) {
    return [];
  }

  // tách token từ text đã normalize, loại token rỗng
  const tokens = value
    .split(' ')
    .map((token) => {
      return token.trim();
    })
    .filter((token) => {
      return token.length > 0;
    });

  // bỏ vào Set tránh duplicate
  return [...new Set(tokens)];
};
