-- AlterTable
ALTER TABLE "BarcodeApiCache" ADD COLUMN     "extracted_brand" TEXT,
ADD COLUMN     "extracted_name" TEXT,
ADD COLUMN     "extracted_variant" TEXT;
