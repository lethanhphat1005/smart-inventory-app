-- DropForeignKey
ALTER TABLE "AuditLog" DROP CONSTRAINT "AuditLog_store_id_fkey";

-- DropForeignKey
ALTER TABLE "Category" DROP CONSTRAINT "Category_store_id_fkey";

-- DropForeignKey
ALTER TABLE "HidedDefault" DROP CONSTRAINT "HidedDefault_category_id_fkey";

-- DropForeignKey
ALTER TABLE "HidedDefault" DROP CONSTRAINT "HidedDefault_store_id_fkey";

-- DropForeignKey
ALTER TABLE "Inventory" DROP CONSTRAINT "Inventory_product_package_id_fkey";

-- DropForeignKey
ALTER TABLE "Product" DROP CONSTRAINT "Product_store_id_fkey";

-- DropForeignKey
ALTER TABLE "ProductPackage" DROP CONSTRAINT "ProductPackage_product_id_fkey";

-- DropForeignKey
ALTER TABLE "ProductPackageBarcode" DROP CONSTRAINT "ProductPackageBarcode_product_package_id_fkey";

-- DropForeignKey
ALTER TABLE "StoreMember" DROP CONSTRAINT "StoreMember_store_id_fkey";

-- DropForeignKey
ALTER TABLE "Transaction" DROP CONSTRAINT "Transaction_store_id_fkey";

-- DropForeignKey
ALTER TABLE "TransactionDetail" DROP CONSTRAINT "TransactionDetail_product_package_id_fkey";

-- DropForeignKey
ALTER TABLE "TransactionDetail" DROP CONSTRAINT "TransactionDetail_transaction_id_fkey";

-- AddForeignKey
ALTER TABLE "StoreMember" ADD CONSTRAINT "StoreMember_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "Store"("store_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Category" ADD CONSTRAINT "Category_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "Store"("store_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HidedDefault" ADD CONSTRAINT "HidedDefault_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "Store"("store_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HidedDefault" ADD CONSTRAINT "HidedDefault_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "Category"("category_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Product" ADD CONSTRAINT "Product_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "Store"("store_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProductPackage" ADD CONSTRAINT "ProductPackage_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "Product"("product_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProductPackageBarcode" ADD CONSTRAINT "ProductPackageBarcode_product_package_id_fkey" FOREIGN KEY ("product_package_id") REFERENCES "ProductPackage"("product_package_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Inventory" ADD CONSTRAINT "Inventory_product_package_id_fkey" FOREIGN KEY ("product_package_id") REFERENCES "ProductPackage"("product_package_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "Store"("store_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TransactionDetail" ADD CONSTRAINT "TransactionDetail_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "Transaction"("transaction_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TransactionDetail" ADD CONSTRAINT "TransactionDetail_product_package_id_fkey" FOREIGN KEY ("product_package_id") REFERENCES "ProductPackage"("product_package_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "Store"("store_id") ON DELETE CASCADE ON UPDATE CASCADE;
