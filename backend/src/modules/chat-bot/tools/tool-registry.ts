import { CREATE_EXPORT_TRANSACTION } from './create-export-transaction.js';
import { CREATE_IMPORT_TRANSACTION } from './create-import-transaction.tool.js';
import { GET_LOW_STOCK } from './get-low-stock.tool.js';
import { GET_PRODUCT_INFO } from './get-product-info.tool.js';

import type { ChatToolDefinition } from './tool.type.js';

export const CHAT_TOOLS: ChatToolDefinition[] = [
  GET_LOW_STOCK,
  GET_PRODUCT_INFO,
  CREATE_EXPORT_TRANSACTION,
  CREATE_IMPORT_TRANSACTION,
];
