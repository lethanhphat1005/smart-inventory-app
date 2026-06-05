import type { CurrencyDto } from './currency.dto.js';
import type { DbClient } from '../../common/types/index.js';

export class CurrencyRepository {
  constructor(private readonly db: DbClient) {}
  async findAll(): Promise<CurrencyDto[]> {
    return await this.db.currency.findMany({
      select: {
        code: true,
        symbol: true,
        name: true,
      },
    });
  }
}
