import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> enChatbot = {
  TTexts.chatbotName: 'AI Storix',
  TTexts.chatbotOnline: 'Online',
  TTexts.chatbotInputHint: 'Type a message...',
  TTexts.chatbotWelcomeMsg:
      'Hello! I am your AI assistant. How can I help you manage your inventory today?',
  TTexts.chatbotErrorTitle: 'Chat Error',
  TTexts.chatbotErrorMsg:
      'Failed to send message. Please check your connection and try again.',
  TTexts.chatbotTyping: 'AI is typing...',
  TTexts.chatbotEmptyInputWarning: 'Please enter a message.',
  TTexts.chatbotMockResponse: 'API integration is in progress. You said:',
  TTexts.chatbotFallbackReply: "Sorry, I don't understand this request.",
  TTexts.chatbotConnectionError: "Oops! Connection to AI lost 😢",
  TTexts.chatbotResetTitle: "Reset Conversation",
  TTexts.chatbotResetMessage:
      "Are you sure you want to clear all messages? This action cannot be undone.",
  TTexts.chatbotResetBtn: "Reset",
  TTexts.chatbotTransactionSuccess:
      "Transaction successful! Inventory data has been updated.",
  TTexts.chatbotTransactionFailed:
      "Transaction failed. The request may have expired.",
  TTexts.chatbotSuggestionTitle: 'How can I help you?',
  TTexts.chatbotSuggestionSub:
      'Choose a suggestion or type your request below.',
  TTexts.chatbotPromptLowStock: 'What items are running low?',
  TTexts.chatbotPromptCheckInfo: 'Check info: ',
  TTexts.chatbotPromptImport: 'Create import: ',
  TTexts.chatbotPromptExport: 'Create export: ',
  TTexts.chatbotConfirmImport: 'Confirm Import',
  TTexts.chatbotConfirmExport: 'Confirm Export',
  TTexts.chatbotResolved: '(Resolved)',
  TTexts.chatbotActionCancelled: 'Action cancelled.',
  TTexts.chatbotOutOfStock: 'Out of stock',
  TTexts.chatbotLowStockPrefix: 'Low:',
  TTexts.chatbotLeftPrefix: 'Left:',
  TTexts.chatbotInStockPrefix: 'In stock:',
  TTexts.chatbotLowStockAlert: 'Low stock:',
  TTexts.chatbotLowStockFoundPrefix: 'I found',
  TTexts.chatbotLowStockFoundSuffix:
      'items that are running low on stock. Please swipe to check the cards below:',
  TTexts.chatbotViewFullList: 'View full list ->',
  TTexts.chatbotNoImageTitle: 'No Image',
  TTexts.chatbotNoImageDesc: 'Product image is unavailable',
  TTexts.chatbotMenuLowStock: 'Low stock items',
  TTexts.chatbotMenuCreateImport: 'Create Import',
  TTexts.chatbotMenuCreateExport: 'Create Export',
  TTexts.chatbotQuickActionLowStock: 'Low stock',
  TTexts.chatbotQuickActionImport: 'Import',
  TTexts.chatbotQuickActionExport: 'Export',
};
