export const GROQ_OPENAI_BASE_URL = 'https://api.groq.com/openai/v1';

export const COORDINATOR_MODEL = 'llama-3.1-8b-instant';
export const FRIENDLY_REPLY_MODEL = 'llama-3.1-8b-instant';

export const COORDINATOR_TEMPERATURE = 0.1;
export const FRIENDLY_REPLY_TEMPERATURE = 0.3;

export const MAX_HISTORY_LENGTH = 6;
export const DRAFT_TTL_SECONDS = 300;
export const HISTORY_TTL_SECONDS = 3600;
export const LOCK_TTL_SECONDS = 15;

export const CHAT_HISTORY_KEY_PREFIX = 'chatbot:history:';
export const CHAT_LOCK_KEY_PREFIX = 'chatbot:lock:';
export const CHAT_DRAFT_KEY_PREFIX = 'chatbot:draft:';
