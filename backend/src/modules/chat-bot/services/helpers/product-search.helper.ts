import type { ListInventoriesQueryDto } from '../../../inventories/dto/inventory.dto.js';
import type { InventoryService } from '../../../inventories/index.js';
import type { InventoryItemData } from '../../chatbot.type.js';

export class ProductSearchHelper {
  private static readonly ALIAS_MAP: Record<string, string> = {
    'bò húc': 'redbull',
    'bò cụng': 'redbull',
    'sting dâu': 'sting đỏ',
    'cô ca': 'coca',
    pexi: 'pepsi',
    'nước lọc': 'aquafina',
    'trà xanh': 'không độ',
    'ô long': 'tea plus',
    'mì tôm': 'hảo hảo',
    'bim bim': 'oishi',
    'xúc xích': 'cp',
    'sữa đặc': 'ông thọ',
    bvs: 'băng vệ sinh',
    bcs: 'bao cao su',
    'áo mưa': 'bao cao su',
    kđr: 'kem đánh răng',
    'sữa tắm': 'lifebuoy',
    'dầu gội': 'clear',
    'bột ngọt': 'ajinomoto',
    'mì chính': 'ajinomoto',
    'nước mắm': 'nam ngư',
  };

  public static async searchInventory(
    inventoryService: InventoryService,
    storeId: string,
    keyword: string,
  ): Promise<InventoryItemData[]> {
    let cleanKeyword = keyword
      .toLowerCase()
      .replace(
        /\b(lốc|thùng|chai|lon|gói|hộp|pack|case|bottle|can|bag|box)\b/gi,
        '',
      )
      .trim();

    for (const [slang, realName] of Object.entries(this.ALIAS_MAP)) {
      if (cleanKeyword.includes(slang)) {
        cleanKeyword = cleanKeyword.replace(slang, realName);
      }
    }

    const query = {
      keyword: cleanKeyword || keyword.trim(),
      limit: 5,
      page: 1,
    } as unknown as ListInventoriesQueryDto;

    let res = await inventoryService.getInventoriesByStoreId(storeId, query);

    // Fallback 1: Loại bỏ ngoặc tròn
    if (res.items.length === 0) {
      const fallbackName = keyword.includes('(')
        ? keyword.split('(')[0]?.trim()
        : keyword
            .replace(/^(can|carton|bottle|box|package|bag|crate)\s+/i, '')
            .trim();

      if (fallbackName && fallbackName !== keyword) {
        query.keyword = fallbackName;
        res = await inventoryService.getInventoriesByStoreId(storeId, query);
      }
    }

    // Fallback 2: Normalize mạnh xóa khoảng trắng ký tự đặc biệt
    if (res.items.length === 0) {
      const normalizedKeyword = keyword
        .toLowerCase()
        .replace(/[\s()-]/g, '')
        .trim();

      if (normalizedKeyword && normalizedKeyword !== keyword) {
        query.keyword = normalizedKeyword;
        res = await inventoryService.getInventoriesByStoreId(storeId, query);
      }
    }

    return res.items as InventoryItemData[];
  }
}
