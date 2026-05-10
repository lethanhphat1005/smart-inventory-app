export const GROQ_OPENAI_BASE_URL = 'https://api.groq.com/openai/v1';

export const COORDINATOR_MODEL = 'llama-3.1-8b-instant';
export const FRIENDLY_REPLY_MODEL = 'llama-3.1-8b-instant';

export const COORDINATOR_TEMPERATURE = 0.1;
export const FRIENDLY_REPLY_TEMPERATURE = 0.3;

export const MAX_HISTORY_LENGTH = 10;
export const HISTORY_SUMMARY_THRESHOLD = 8;
export const DRAFT_TTL_SECONDS = 300;
export const HISTORY_TTL_SECONDS = 3600;
export const LOCK_TTL_SECONDS = 20;

export const CHAT_HISTORY_KEY_PREFIX = 'chatbot:history:';
export const CHAT_LOCK_KEY_PREFIX = 'chatbot:lock:';
export const CHAT_DRAFT_KEY_PREFIX = 'chatbot:draft:';

export const STATIC_REJECTION_REPLY =
  "Sorry, Tori is just a warehouse manager — I can't help with that 😅. " +
  'Need me to check stock levels or create an import/export draft? 📦';
