import { StoreController } from './store.controller.js';
import { StoreRepository } from './store.repository.js';
import { StoreService } from './store.service.js';
import { prisma } from '../../db/prismaClient.js';

const storeRepository = new StoreRepository(prisma);
const storeService = new StoreService(storeRepository);
const storeController = new StoreController(storeService);

export { storeController };
