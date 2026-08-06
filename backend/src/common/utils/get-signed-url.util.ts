import { StatusCodes } from 'http-status-codes';

import { SupabaseProvider } from '../../db/supabaseClient.js';
import { CustomError } from '../errors/index.js';

const STORAGE_BUCKET = process.env.STORAGE_BUCKET ?? 'images';

export class StorageService {
  /**
   * Tạo Signed URL cho ảnh có thời hạn truy cập (vd: 1 giờ)
   */
  static async getSignedUrl(
    bucket: string,
    path: string | null,
  ): Promise<string | null> {
    if (!path || path === undefined) {
      return null;
    }

    try {
      // 1. Gọi Singleton Client từ Provider
      const supabase = SupabaseProvider.getClient();

      // 2. Sử dụng client để tạo Signed URL
      const { data, error } = await supabase.storage
        .from(bucket)
        .createSignedUrl(path, 60 * 60); // 3600 giây = 1 giờ

      if (error) {
        throw new CustomError({
          message: `Error occured while creating signed URL Supabase: ${error}`,
          status: StatusCodes.INTERNAL_SERVER_ERROR,
          isOperational: false,
        });
      }

      return data.signedUrl;
    } catch (error) {
      throw new CustomError({
        message: `Exception occured while creating signed URL Supabase: ${error}`,
        status: StatusCodes.INTERNAL_SERVER_ERROR,
        isOperational: false,
      });
    }
  }

  // Xóa images khi hard delete store
  static async deleteProductImages(imagePaths: string[]): Promise<void> {
    const normalizedPaths = [
      ...new Set(
        imagePaths.map((imagePath) => imagePath.trim()).filter(Boolean),
      ),
    ];

    if (normalizedPaths.length === 0) {
      return;
    }

    const supabase = SupabaseProvider.getClient();

    const { error } = await supabase.storage
      .from(STORAGE_BUCKET)
      .remove(normalizedPaths);

    if (error) {
      throw new CustomError({
        message: `Failed to delete product images: ${error.message}`,
        status: 500,
      });
    }
  }
}
