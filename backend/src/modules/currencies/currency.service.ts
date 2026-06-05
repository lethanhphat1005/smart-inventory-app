import { CurrencyRepository } from './currency.repository.js';

import type { CurrencyDto } from './currency.dto.js';

export class CurrencyService {
  constructor(private readonly currencyRepository: CurrencyRepository) {}

  public async getAllCurrencies(): Promise<CurrencyDto[]> {
    return this.currencyRepository.findAll();
  }
}
