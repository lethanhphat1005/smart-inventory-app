import 'dotenv/config';

import { OpenAI } from 'openai';

import { GROQ_OPENAI_BASE_URL } from '../chatbot.constants.js';

import type { LLMProvider } from './llm.provider.js';

export class OpenAIProvider implements LLMProvider {
  private readonly openai: OpenAI;

  constructor() {
    this.openai = new OpenAI({
      baseURL: GROQ_OPENAI_BASE_URL,
      apiKey: process.env.GROQ_API_KEY,
      timeout: 15000,
    });
  }

  async createChatCompletion(
    params: OpenAI.Chat.ChatCompletionCreateParamsNonStreaming,
    maxRetries = 2,
  ): Promise<OpenAI.Chat.ChatCompletion> {
    let attempt = 0;

    while (attempt <= maxRetries) {
      try {
        return await this.openai.chat.completions.create(params);
      } catch (error: unknown) {
        attempt++;

        let isRetryable = false;
        let errorMessage = 'Unknown error occurred';

        // Kiểm tra an toàn xem lỗi có phải từ OpenAI API không
        if (error instanceof OpenAI.APIError) {
          errorMessage = error.message;
          // Retry nếu là 429 hoặc các lỗi 5xx
          isRetryable =
            error.status === 429 ||
            (error.status !== undefined &&
              error.status >= 500 &&
              error.status < 600);
        } else if (error instanceof Error) {
          // Các lỗi network (như timeout) cũng nên được retry
          errorMessage = error.message;
          isRetryable = true;
        }

        if (attempt > maxRetries || !isRetryable) {
          console.error(
            `[LLM Provider] Error on attempt ${attempt}:`,
            errorMessage,
          );
          throw error;
        }

        console.warn(
          `[LLM Provider] Thử lại lần ${attempt}/${maxRetries} do lỗi hệ thống/mạng...`,
        );

        const delay = Math.pow(2, attempt - 1) * 1000;

        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }

    throw new Error('LLM Provider failed after max retries');
  }

  async createChatCompletionStream(
    params: OpenAI.Chat.ChatCompletionCreateParamsStreaming,
  ): Promise<AsyncIterable<OpenAI.Chat.ChatCompletionChunk>> {
    return await this.openai.chat.completions.create(params);
  }
}
