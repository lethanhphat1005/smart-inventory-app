-- DropForeignKey
ALTER TABLE "TransactionDetail" DROP CONSTRAINT "TransactionDetail_product_package_id_fkey";

-- AddForeignKey
ALTER TABLE "TransactionDetail" ADD CONSTRAINT "TransactionDetail_product_package_id_fkey" FOREIGN KEY ("product_package_id") REFERENCES "ProductPackage"("product_package_id") ON DELETE RESTRICT ON UPDATE CASCADE;
