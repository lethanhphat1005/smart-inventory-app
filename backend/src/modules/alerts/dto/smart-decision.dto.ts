export type ReorderSuggestionItemDto = {
  productId: string;
  productName: string;
  currentStock: number;
  suggestedQuantity: number;
  suggestedThreshold: number;
  reason: string;
};

export type ListReorderSuggestionResponseDto = ReorderSuggestionItemDto[];
