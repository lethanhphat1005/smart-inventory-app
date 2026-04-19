import { BarcodesController } from './barcodes.controller.js';
import { BarcodeApiCacheRepository } from './repositories/barcode-api-cache.repository.js';
import { PackageBarcodeRepository } from './repositories/product-package-barcode.repository.js';
import { BarcodeProviderService } from './services/barcode-provider.service.js';
import { BarcodesService } from './services/barcodes.service.js';
import { prisma } from '../../db/prismaClient.js';
import { ProductPackageRepository } from '../product-packages/repositories/product-package.repository.js';

const packageBarcodeRepository = new PackageBarcodeRepository(prisma);
const barcodeApiCacheRepository = new BarcodeApiCacheRepository(prisma);
const productPackageRepository = new ProductPackageRepository(prisma);
const barcodeProviderService = new BarcodeProviderService();

const barcodesService = new BarcodesService(
  packageBarcodeRepository,
  barcodeApiCacheRepository,
  productPackageRepository,
  barcodeProviderService,
);
const barcodesController = new BarcodesController(barcodesService);

export { barcodesController, barcodesService };
