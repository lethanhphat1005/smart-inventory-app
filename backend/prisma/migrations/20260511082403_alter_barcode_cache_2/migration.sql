/*
  Warnings:

  - You are about to drop the column `extracted_variant` on the `BarcodeApiCache` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "BarcodeApiCache" DROP COLUMN "extracted_variant",
ADD COLUMN     "extracted_package_text" TEXT;
