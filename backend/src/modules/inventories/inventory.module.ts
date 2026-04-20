import { prisma } from '../../db/prismaClient.js';
import { InventoryEventPublisher } from '../alerts/inventory-event.publisher.js';
import { InventoryController } from '../inventories/controller/inventory.controller.js';
import { InventoryRepository } from '../inventories/repository/inventory.repository.js';
import { InventoryService } from '../inventories/service/inventory.service.js';

const inventoryRepository = new InventoryRepository(prisma);
const inventoryEventPublisher = new InventoryEventPublisher();
const inventoryService = new InventoryService(
  inventoryRepository,
  inventoryEventPublisher,
);
const inventoryController = new InventoryController(inventoryService);

export {
  inventoryRepository,
  inventoryEventPublisher,
  inventoryService,
  inventoryController,
};
