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
    });
  }

  async createChatCompletion(
    params: OpenAI.Chat.ChatCompletionCreateParamsNonStreaming,
  ): Promise<OpenAI.Chat.ChatCompletion> {
    return await this.openai.chat.completions.create(params);
  }

  async createChatCompletionStream(
    params: OpenAI.Chat.ChatCompletionCreateParamsStreaming,
  ): Promise<AsyncIterable<OpenAI.Chat.ChatCompletionChunk>> {
    return await this.openai.chat.completions.create(params);
  }
}
