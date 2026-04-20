import { getPaginationSkip } from '../../common/utils/index.js';
import { Prisma } from '../../generated/prisma/client.js';

import type {
  SearchByKeywordQueryDto,
  SearchByPrefixQueryDto,
  SearchProductPrefixResponseDto,
  SearchProductPackageItemDto,
  SearchProductPackageRow,
  SearchProductItemDto,
  SearchProductRow,
  SearchCountRow,
} from './search.dto.js';
import type {
  DbClient,
  ListPaginationResponseDto,
} from '../../common/types/index.js';

export class SearchRepository {
  constructor(private readonly db: DbClient) {}

  // lấy limit default = 10 và tối đa 20
  private normalizePrefixLimit(limit?: number): number {
    if (!limit || limit < 1) {
      return 10;
    }

    return Math.min(Math.floor(limit), 20);
  }

  // biến keyword thành query Full Text Search (FTS)
  // ví dụ: "coca lon 330" -> "coca:* & lon:* & 330:*"
  // `:*`: coca:* → match: coca, cocacola, cocaaa
  // `&`: coca:* & lon:* -> bắt buộc có "coca" và "lon"
  // `|`: coca:* | lon:* -> có "coca" hoặc "lon"
  private buildSearchTsQueries(keyword: string): {
    strictQuery: string;
    broadQuery: string;
  } {
    const tokens = keyword
      .trim()
      .split(/\s+/)
      .map((token) => this.escapeTsQueryToken(token).trim())
      .filter((token) => token.length > 0);

    if (tokens.length === 0) {
      return {
        strictQuery: '',
        broadQuery: '',
      };
    }

    const prefixTokens = tokens.map((token) => `${token}:*`);

    // trả về mix AND + OR
    // vd: coca lon --> (coca:* & lon:*) | (coca:*) | (lon:*)
    return {
      strictQuery: prefixTokens.join(' & '),
      broadQuery: prefixTokens.join(' | '),
    };
  }

  // loại bỏ các ký tự đặc biệt trong ts_query
  private escapeTsQueryToken(token: string): string {
    return token.replace(/[&|!():*']/g, ' ');
  }

  private mapSearchProductPackageRow(
    row: SearchProductPackageRow,
  ): SearchProductPackageItemDto {
    return {
      productId: row.productId,
      productName: row.productName,
      imageUrl: row.imageUrl,
      brand: row.brand,
      categoryId: row.categoryId,
      categoryName: row.categoryName,
      productPackageId: row.productPackageId,
      displayName: row.displayName,
      importPrice: row.importPrice?.toNumber() ?? null,
      sellingPrice: row.sellingPrice?.toNumber() ?? null,
      quantity: row.quantity,
      reorderThreshold: row.reorderThreshold,
      unitId: row.unitId,
      unitCode: row.unitCode,
      unitName: row.unitName,
    };
  }

  private mapSearchProduct(row: SearchProductRow): SearchProductItemDto {
    return {
      productId: row.productId,
      productName: row.productName,
      imageUrl: row.imageUrl,
      brand: row.brand,
      categoryId: row.categoryId,
      categoryName: row.categoryName,
    };
  }

  async searchProductPackagesByKeyword(
    storeId: string,
    query: SearchByKeywordQueryDto,
  ): Promise<ListPaginationResponseDto<SearchProductPackageItemDto>> {
    const { keyword, page, limit } = query;
    const offset = getPaginationSkip({ page, limit });

    if (!keyword) {
      return { items: [], totalItems: 0 };
    }

    const { strictQuery, broadQuery } = this.buildSearchTsQueries(keyword);

    if (!broadQuery) {
      return { items: [], totalItems: 0 };
    }

    // đếm tổng số match product record
    const countRows = await this.db.$queryRaw<SearchCountRow[]>(
      Prisma.sql`
        SELECT COUNT(*)::bigint AS total
        FROM (
          SELECT pp.product_package_id
          FROM "Product" p
          INNER JOIN "Category" c
            ON c.category_id = p.category_id
          LEFT JOIN "ProductPackage" pp
            ON pp.product_id = p.product_id
          AND pp.active_status = 'active'
          LEFT JOIN (
            SELECT
              ppb.product_package_id,
              string_agg(ppb.barcode, ' ') AS barcodes
            FROM "ProductPackageBarcode" ppb
            GROUP BY ppb.product_package_id
          ) pb
            ON pb.product_package_id = pp.product_package_id
          LEFT JOIN "Unit" u
            ON u.unit_id = pp.unit_id
          LEFT JOIN "Inventory" i
            ON i.product_package_id = pp.product_package_id
          WHERE p.store_id = ${storeId}
            AND p.active_status = 'active'
            AND (
              setweight(to_tsvector('simple', coalesce(p.name, '')), 'A') ||
              setweight(to_tsvector('simple', coalesce(pp.display_name, '')), 'A') ||
              setweight(to_tsvector('simple', coalesce(pb.barcodes, '')), 'A') ||
              setweight(to_tsvector('simple', coalesce(p.brand, '')), 'B') ||
              setweight(to_tsvector('simple', coalesce(c.name, '')), 'C') ||
              setweight(to_tsvector('simple', coalesce(u.name, '')), 'C')
            ) @@ to_tsquery('simple', ${broadQuery})
        ) matched_packages;
      `,
    );

    // search result trả về cho user
    const rows = await this.db.$queryRaw<SearchProductPackageRow[]>(
      Prisma.sql`
        WITH search_data AS (
          SELECT
            p.product_id AS "productId",
            p.name AS "productName",
            p.image_url AS "imageUrl",
            p.brand AS "brand",
            c.category_id AS "categoryId",
            c.name AS "categoryName",
            pp.product_package_id AS "productPackageId",
            pp.display_name AS "displayName",
            pp.import_price AS "importPrice",
            pp.selling_price AS "sellingPrice",
            i.quantity AS "quantity",
            i.reorder_threshold AS "reorderThreshold",
            u.unit_id AS "unitId",
            u.code AS "unitCode",
            u.name AS "unitName",
            (
              setweight(to_tsvector('simple', coalesce(p.name, '')), 'A') ||
              setweight(to_tsvector('simple', coalesce(pp.display_name, '')), 'A') ||
              setweight(to_tsvector('simple', coalesce(pb.barcodes, '')), 'A') ||
              setweight(to_tsvector('simple', coalesce(p.brand, '')), 'B') ||
              setweight(to_tsvector('simple', coalesce(c.name, '')), 'C') ||
              setweight(to_tsvector('simple', coalesce(u.name, '')), 'C')
            ) AS document
          FROM "Product" p
          INNER JOIN "Category" c
            ON c.category_id = p.category_id
          LEFT JOIN "ProductPackage" pp
            ON pp.product_id = p.product_id
          AND pp.active_status = 'active'
          LEFT JOIN (
            SELECT
              ppb.product_package_id,
              string_agg(ppb.barcode, ' ') AS barcodes
            FROM "ProductPackageBarcode" ppb
            GROUP BY ppb.product_package_id
          ) pb
            ON pb.product_package_id = pp.product_package_id
          LEFT JOIN "Unit" u
            ON u.unit_id = pp.unit_id
          LEFT JOIN "Inventory" i
            ON i.product_package_id = pp.product_package_id
          WHERE p.store_id = ${storeId}
            AND p.active_status = 'active'
        )
        SELECT
          "productId",
          "productName",
          "imageUrl",
          "brand",
          "categoryId",
          "categoryName",
          "productPackageId",
          "displayName",
          "importPrice",
          "sellingPrice",
          "quantity",
          "reorderThreshold",
          "unitId",
          "unitCode",
          "unitName",
          CASE
            WHEN document @@ to_tsquery('simple', ${strictQuery}) THEN
              ts_rank(document, to_tsquery('simple', ${strictQuery})) + 1
            ELSE
              ts_rank(document, to_tsquery('simple', ${broadQuery}))
          END AS rank
        FROM search_data
        WHERE document @@ to_tsquery('simple', ${broadQuery})
        ORDER BY
          rank DESC,
          "productName" ASC
        LIMIT ${limit}
        OFFSET ${offset};
      `,
    );

    const total = Number(countRows[0]?.total ?? 0n);
    const items = rows.map((row) => this.mapSearchProductPackageRow(row));

    return {
      items: items,
      totalItems: total,
    };
  }

  async searchProductsByKeyword(
    storeId: string,
    query: SearchByKeywordQueryDto,
  ): Promise<ListPaginationResponseDto<SearchProductItemDto>> {
    const { keyword, page, limit } = query;
    const offset = getPaginationSkip({ page, limit });

    if (!keyword) {
      return {
        items: [],
        totalItems: 0,
      };
    }

    const { strictQuery, broadQuery } = this.buildSearchTsQueries(keyword);

    if (!broadQuery) {
      return {
        items: [],
        totalItems: 0,
      };
    }

    const countRows = await this.db.$queryRaw<SearchCountRow[]>(
      Prisma.sql`
      WITH search_data AS (
        SELECT
          p.product_id,
          (
            setweight(to_tsvector('simple', coalesce(p.name, '')), 'A') ||
            setweight(to_tsvector('simple', coalesce(p.brand, '')), 'B') ||
            setweight(to_tsvector('simple', coalesce(c.name, '')), 'C') ||
            setweight(to_tsvector('simple', coalesce(c.description, '')), 'D')
          ) AS document
        FROM "Product" p
        INNER JOIN "Category" c
          ON c.category_id = p.category_id
        WHERE p.store_id = ${storeId}
          AND p.active_status = 'active'
      )
      SELECT COUNT(*)::bigint AS total
      FROM search_data
      WHERE document @@ to_tsquery('simple', ${broadQuery});
    `,
    );

    const rows = await this.db.$queryRaw<SearchProductRow[]>(
      Prisma.sql`
      WITH search_data AS (
        SELECT
          p.product_id AS "productId",
          p.name AS "productName",
          p.image_url AS "imageUrl",
          p.brand AS "brand",
          c.category_id AS "categoryId",
          c.name AS "categoryName",
          (
            setweight(to_tsvector('simple', coalesce(p.name, '')), 'A') ||
            setweight(to_tsvector('simple', coalesce(p.brand, '')), 'B') ||
            setweight(to_tsvector('simple', coalesce(c.name, '')), 'C') ||
            setweight(to_tsvector('simple', coalesce(c.description, '')), 'D')
          ) AS document
        FROM "Product" p
        INNER JOIN "Category" c
          ON c.category_id = p.category_id
        WHERE p.store_id = ${storeId}
          AND p.active_status = 'active'
      )
      SELECT
        "productId",
        "productName",
        "imageUrl",
        "brand",
        "categoryId",
        "categoryName",
        CASE
          WHEN document @@ to_tsquery('simple', ${strictQuery}) THEN
            ts_rank(document, to_tsquery('simple', ${strictQuery})) + 1
          ELSE
            ts_rank(document, to_tsquery('simple', ${broadQuery}))
        END AS rank
      FROM search_data
      WHERE document @@ to_tsquery('simple', ${broadQuery})
      ORDER BY
        rank DESC,
        "productName" ASC
      LIMIT ${limit}
      OFFSET ${offset};
    `,
    );

    const totalItems = Number(countRows[0]?.total ?? 0n);

    return {
      items: rows.map((row) => this.mapSearchProduct(row)),
      totalItems,
    };
  }

  /*
    TODO: Search barcode có cách nào để trả về nguyên Product chi tiết
    TODO: thay vì ProductPackage không
    TODO: Có thể lấy productId từ ProductPackage rồi gọi hàm Product.findOne
    TODO: để lấy chi tiết Product + Packages + Inventory
  */

  // Hàm cho các ô nhập tên product
  // và dropdown danh sách tên product theo prefix
  async searchProductsByPrefix(
    storeId: string,
    query: SearchByPrefixQueryDto,
  ): Promise<SearchProductPrefixResponseDto[]> {
    const prefix = query.prefix.trim();
    const limit = this.normalizePrefixLimit(query.limit);

    if (!prefix) {
      return [];
    }

    return await this.db.product.findMany({
      where: {
        storeId,
        activeStatus: 'active',
        name: {
          startsWith: prefix,
          mode: 'insensitive',
        },
      },
      select: {
        productId: true,
        name: true,
        brand: true,
        imageUrl: true,
      },
      orderBy: [
        {
          name: 'asc',
        },
      ],
      take: limit,
    });
  }
}
