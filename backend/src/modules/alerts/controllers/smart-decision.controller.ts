import { StatusCodes } from 'http-status-codes';

import {
  requireReqStoreContext,
  sendResponse,
} from '../../../common/utils/index.js';
import { SmartDecisionService } from '../services/smart-decision.service.js'; // Nhớ trỏ đúng đường dẫn

import type { ApiResponse } from '../../../common/types/index.js';
import type { ListReorderSuggestionResponseDto } from '../dto/smart-decision.dto.js';
import type { Request, Response } from 'express';

export class SmartDecisionController {
  // Inject Service qua constructor (Chuẩn DI của dự án)
  constructor(private readonly smartDecisionService: SmartDecisionService) {}

  getReorderSuggestions = async (
    req: Request,
    res: Response<ApiResponse<ListReorderSuggestionResponseDto>>,
  ): Promise<void> => {
    // Lấy context an toàn bằng hàm util của dự án
    const storeContext = requireReqStoreContext(req);

    // Gọi service xử lý logic
    const suggestions =
      await this.smartDecisionService.getStoreReorderSuggestions(
        storeContext.storeId,
      );

    // Trả response theo format chuẩn
    sendResponse.success(res, suggestions, { status: StatusCodes.OK });
  };
}
