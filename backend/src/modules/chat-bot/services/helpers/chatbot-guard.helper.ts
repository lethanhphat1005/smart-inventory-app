import type { LLMToolParams } from '../../chatbot.type.js';

export class ChatbotGuardHelper {
  public static isToolCallEligible(
    intent: string,
    params: LLMToolParams,
    userMessage: string,
    locale: string,
  ): { isValid: boolean; reason?: string } {
    const normalizedMessage = userMessage.toLowerCase();
    const isVi = locale === 'vi';

    const metaKeywords = isVi
      ? ['làm sao', 'hướng dẫn', 'giúp', 'hỗ trợ']
      : ['how to', 'guide', 'can you', 'support', 'help'];

    const isAskingForHelp = metaKeywords.some((kw) =>
      normalizedMessage.includes(kw),
    );
    const hasActionKeyword = [
      'import',
      'export',
      'xuất',
      'nhập',
      'tồn kho',
      'stock',
    ].some((kw) => normalizedMessage.includes(kw));

    if (isAskingForHelp && !hasActionKeyword) {
      return {
        isValid: false,
        reason: isVi
          ? '[SYSTEM INSTRUCTION]: Thông báo rằng câu hỏi lịch sử quá chung chung. Yêu cầu họ chỉ định rõ loại thao tác, tên sản phẩm hoặc thời gian.'
          : '[SYSTEM INSTRUCTION]: Inform the user that their history query is too general. Ask them to specify the action type, product name, or a specific time period.',
      };
    }

    switch (intent) {
      case 'get_product_info':
        if (!params.product_name || params.product_name.trim() === '') {
          return {
            isValid: false,
            reason: isVi
              ? 'Bạn đang muốn tìm sản phẩm nào thế? Cho Tori xin tên cụ thể nhé.'
              : 'What product are you looking for? Please let Tori know the name of the product.',
          };
        }
        break;

      case 'create_import':
      case 'create_export': {
        const items = params.products || [];
        const isImport = intent === 'create_import';

        if (items.length === 0 && !(params.product_name && params.quantity)) {
          return {
            isValid: false,
            reason: isVi
              ? `Bạn muốn ${isImport ? 'nhập' : 'xuất'} sản phẩm nào và số lượng bao nhiêu? Nhắn đủ thông tin để Tori lên đơn nha.`
              : `What product and quantity do you want to process using ${isImport ? 'import' : 'export'}? Please provide enough information so Tori can create the order.`,
          };
        }

        const numberWordRegex =
          /một|hai|ba|bốn|năm|sáu|bảy|tám|chín|mười|chục|trăm|ngàn|one|two|three|four|five|ten/i;

        const hasNumberInMessage =
          /\d/.test(normalizedMessage) ||
          numberWordRegex.test(normalizedMessage);

        if (!hasNumberInMessage) {
          return {
            isValid: false,
            reason: isVi
              ? `Tori đã thấy tên sản phẩm nhưng chưa có số lượng cụ thể. Vui lòng cho biết bạn muốn ${isImport ? 'nhập' : 'xuất'} bao nhiêu cái?`
              : `The user specified the product but did NOT provide the exact quantity. Ask the user clearly: "How many [Product Name] do you want to ${isImport ? 'import' : 'export'}?"`,
          };
        }

        const hasMissingQuantity = items.some(
          (item) =>
            item.quantity === undefined ||
            item.quantity === null ||
            Number.isNaN(Number(item.quantity)),
        );

        if (hasMissingQuantity) {
          return {
            isValid: false,
            reason: isVi
              ? `Vui lòng chỉ định rõ số lượng bạn muốn ${isImport ? 'nhập' : 'xuất'} cho từng sản phẩm.`
              : `Ask the user clearly: "How many [Product Name] do you want to ${isImport ? 'import' : 'export'}?"`,
          };
        }

        if (items.some((item) => Number(item.quantity) <= 0)) {
          return {
            isValid: false,
            reason:
              '[SYSTEM INSTRUCTION]: Inform the user that the quantity must be greater than 0.',
          };
        }
        break;
      }

      case 'query_audit_logs':
        if (
          !params.keyword &&
          !params.time_period &&
          params.action_type?.toLowerCase() === 'all'
        ) {
          return {
            isValid: false,
            reason: isVi
              ? 'Lịch sử thao tác bạn cần tìm kiếm hơi chung chung. Bạn có thể nói rõ hơn là ai làm, xóa/sửa gì, hoặc lúc nào không?'
              : 'The query is too general. Please request them to specify the action type, product name, or a specific time period.',
          };
        }
        break;
      default:
        break;
    }

    return { isValid: true };
  }
}
