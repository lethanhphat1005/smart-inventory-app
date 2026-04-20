import { prisma } from '../../../db/prismaClient.js';
import { ProductRepository } from '../../products/index.js';
import { ProductPackageController } from '../controllers/product-package.controller.js';
import { ProductPackageRepository } from '../repositories/product-package.repository.js';
import { UnitRepository } from '../repositories/unit.repository.js';
import { ProductPackageService } from '../services/product-package.service.js';

// tạo new instance tránh circular dependency
// do productService đã import productPackageRepository rồi
const productRepository = new ProductRepository(prisma);

const productPackageRepository = new ProductPackageRepository(prisma);
const unitRepository = new UnitRepository();
const productPackageService = new ProductPackageService(
  productPackageRepository,
  unitRepository,
  productRepository,
);
const productPackageController = new ProductPackageController(
  productPackageService,
);

export {
  productPackageRepository,
  productPackageService,
  productPackageController,
};
