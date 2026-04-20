import 'dart:io';

class UrlHelperUtils {
  static String? normalizeImageUrl(dynamic imageUrl) {
    if (imageUrl == null) return null;

    String url = imageUrl.toString();

    if (Platform.isAndroid) {
      url = url.replaceAll('127.0.0.1', '10.0.2.2');
      url = url.replaceAll('localhost', '10.0.2.2');
    }

    return url;
  }
}
