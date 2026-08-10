import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Tên bucket đã cấu hình trên backend
  static const String _bucketName = 'images';

  /// Upload ảnh và trả về path (vd: 'products/17123456_image.jpg')
  Future<String?> uploadImage({
    required File imageFile,
    required String folderPath,
  }) async {
    try {
      final String fileExtension = p.extension(imageFile.path);
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.hashCode}$fileExtension';
      final String fullStoragePath = '$folderPath/$fileName';

      await _supabase.storage.from(_bucketName).upload(
            fullStoragePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      return fullStoragePath; // Trả về chuỗi tĩnh để truyền xuống API Backend
    } on StorageException catch (e) {
      debugPrint('Supabase Storage Error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Upload Error: $e');
      return null;
    }
  }
}
