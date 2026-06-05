/*
  Warnings:

  - Made the column `currency_code` on table `Store` required. This step will fail if there are existing NULL values in that column.

*/
-- DropForeignKey
ALTER TABLE "Store" DROP CONSTRAINT "Store_currency_code_fkey";

-- AlterTable
ALTER TABLE "Store" ALTER COLUMN "currency_code" SET NOT NULL;

-- AddForeignKey
ALTER TABLE "Store" ADD CONSTRAINT "Store_currency_code_fkey" FOREIGN KEY ("currency_code") REFERENCES "Currency"("code") ON DELETE RESTRICT ON UPDATE CASCADE;
