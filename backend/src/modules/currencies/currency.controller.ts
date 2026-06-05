import { StatusCodes } from 'http-status-codes';

import { CurrencyService } from './currency.service.js';
import { sendResponse } from '../../common/utils/index.js';

import type { CurrencyDto } from './currency.dto.js';
import type { ApiResponse } from '../../common/types/index.js';
import type { Request, Response } from 'express';

export class CurrencyController {
  constructor(private readonly currencyService: CurrencyService) {}

  getCurrencies = async (
    _req: Request,
    res: Response<ApiResponse<CurrencyDto[]>>,
  ): Promise<void> => {
    const units = await this.currencyService.getAllCurrencies();

    sendResponse.success(res, units, { status: StatusCodes.OK });
  };
}
