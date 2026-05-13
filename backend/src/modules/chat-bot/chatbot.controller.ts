import { StatusCodes } from 'http-status-codes';

import { sendResponse } from '../../common/utils/api-response.util.js';
import {
  requireReqStoreContext,
  requireReqUser,
} from '../../common/utils/require-req.js';

import type { ChatbotRequestDto, ChatbotResponseDto } from './chatbot.dto.js';
import type { ChatbotService } from './services/chatbot.service.js';
import type { ApiResponse } from '../../common/types/api-response.type.js';
import type { Request, Response } from 'express';

export class ChatbotController {
  constructor(private readonly chatbotService: ChatbotService) {}

  processChat = async (
    req: Request,
    res: Response<ApiResponse<ChatbotResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;
    const payload = req.body as ChatbotRequestDto;

    const result = await this.chatbotService.processMessage(
      storeId,
      userId,
      payload,
    );

    sendResponse.success(res, result, { status: StatusCodes.OK });
  };

  confirmAction = async (
    req: Request,
    res: Response<ApiResponse<{ message: string }>>,
  ): Promise<void> => {
    const { draftActionId, isConfirmed } = req.body;

    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;

    const resultMessage = await this.chatbotService.confirmDraftAction(
      draftActionId,
      isConfirmed,
      storeId,
      userId,
    );

    sendResponse.success(
      res,
      { message: resultMessage },
      { status: StatusCodes.OK },
    );
  };
}
