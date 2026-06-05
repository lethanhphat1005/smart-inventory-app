-- AlterTable
ALTER TABLE "Store" ADD COLUMN     "currency_code" TEXT;

-- CreateTable
CREATE TABLE "Currency" (
    "code" TEXT NOT NULL,
    "symbol" TEXT,
    "name" TEXT,

    CONSTRAINT "Currency_pkey" PRIMARY KEY ("code")
);

-- AddForeignKey
ALTER TABLE "Store" ADD CONSTRAINT "Store_currency_code_fkey" FOREIGN KEY ("currency_code") REFERENCES "Currency"("code") ON DELETE SET NULL ON UPDATE CASCADE;
