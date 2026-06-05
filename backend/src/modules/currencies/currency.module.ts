import { CurrencyController } from './currency.controller.js';
import { CurrencyRepository } from './currency.repository.js';
import { CurrencyService } from './currency.service.js';
import { prisma } from '../../db/prismaClient.js';

const currencyRepository = new CurrencyRepository(prisma);
const currencyService = new CurrencyService(currencyRepository);
const currencyController = new CurrencyController(currencyService);

export { currencyController };
