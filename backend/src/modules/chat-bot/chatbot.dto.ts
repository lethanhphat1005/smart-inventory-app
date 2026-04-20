export type ChatbotRequestDto = {
  message: string;
};

export type ChatbotResponseDto = {
  aiIntent: string;
  botReply: string;
  data?: unknown;
};
