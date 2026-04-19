/*
  Warnings:

  - The primary key for the `BarcodeApiCache` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `last_count` on the `Inventory` table. All the data in the column will be lost.
  - You are about to drop the column `barcode_type` on the `ProductPackage` table. All the data in the column will be lost.
  - You are about to drop the column `barcode_value` on the `ProductPackage` table. All the data in the column will be lost.
  - The required column `barcode_cache_id` was added to the `BarcodeApiCache` table with a prisma-level default value. This is not possible if the table is not empty. Please add this column as optional, then populate it before making it required.

*/
-- CreateEnum
CREATE TYPE "PackageBarcodeSource" AS ENUM ('user_confirmed', 'barcode_flow_create', 'admin', 'seed', 'api_import');

-- DropIndex
DROP INDEX "BarcodeApiCache_barcode_key";

-- AlterTable
ALTER TABLE "BarcodeApiCache" DROP CONSTRAINT "BarcodeApiCache_pkey",
ADD COLUMN     "barcode_cache_id" TEXT NOT NULL,
ADD COLUMN     "hit_count" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "last_used_at" TIMESTAMPTZ(3),
ADD COLUMN     "normalized_brand" TEXT,
ADD COLUMN     "normalized_name" TEXT,
ADD COLUMN     "normalized_package_text" TEXT,
ADD CONSTRAINT "BarcodeApiCache_pkey" PRIMARY KEY ("barcode_cache_id");

-- AlterTable
ALTER TABLE "Inventory" DROP COLUMN "last_count";

-- AlterTable
ALTER TABLE "ProductPackage" DROP COLUMN "barcode_type",
DROP COLUMN "barcode_value";

-- CreateTable
CREATE TABLE "ProductPackageBarcode" (
    "product_package_barcode_id" TEXT NOT NULL,
    "barcode" TEXT NOT NULL,
    "barcode_type" "BarcodeType",
    "is_verified" BOOLEAN NOT NULL DEFAULT true,
    "source" "PackageBarcodeSource" NOT NULL,
    "confidence" DECIMAL(5,2),
    "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(3) NOT NULL,
    "product_package_id" TEXT NOT NULL,

    CONSTRAINT "ProductPackageBarcode_pkey" PRIMARY KEY ("product_package_barcode_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ProductPackageBarcode_barcode_key" ON "ProductPackageBarcode"("barcode");

-- AddForeignKey
ALTER TABLE "ProductPackageBarcode" ADD CONSTRAINT "ProductPackageBarcode_product_package_id_fkey" FOREIGN KEY ("product_package_id") REFERENCES "ProductPackage"("product_package_id") ON DELETE RESTRICT ON UPDATE CASCADE;
