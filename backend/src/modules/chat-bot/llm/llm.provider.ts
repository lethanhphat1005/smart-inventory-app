import type { OpenAI } from 'openai';

export interface LLMProvider {
  createChatCompletion(
    params: OpenAI.Chat.ChatCompletionCreateParamsNonStreaming,
  ): Promise<OpenAI.Chat.ChatCompletion>;

  createChatCompletionStream(
    params: OpenAI.Chat.ChatCompletionCreateParamsStreaming,
  ): Promise<AsyncIterable<OpenAI.Chat.ChatCompletionChunk>>;
}
