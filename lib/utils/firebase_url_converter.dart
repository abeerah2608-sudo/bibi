import 'package:flutter/foundation.dart';

/// Converts Google Storage (gs://) URLs to HTTPS URLs that can be used by HTTP clients
class FirebaseUrlConverter {
  /// Convert gs:// URL to HTTPS URL
  /// Examples:
  /// - gs://bucket-name/path/file.mp3 → https://firebasestorage.googleapis.com/v0/b/bucket-name/o/path%2Ffile.mp3?alt=media
  /// - gs://bibi-app-d41a0.firebasestorage.app/audio/file.mp3 → https://firebasestorage.googleapis.com/v0/b/bibi-app-d41a0/o/audio%2Ffile.mp3?alt=media
  static String convertGsToHttps(String gsUrl) {
    if (!gsUrl.startsWith('gs://')) {
      debugPrint('⚠️ URL is not a gs:// URL: $gsUrl');
      return gsUrl; // Already an HTTPS URL or local asset
    }

    try {
      // Remove gs:// prefix
      final withoutProtocol = gsUrl.substring(5); // Remove 'gs://'

      // Split by first slash to get bucket and path
      final slashIndex = withoutProtocol.indexOf('/');
      if (slashIndex == -1) {
        debugPrint('❌ Invalid gs:// URL format: $gsUrl');
        return gsUrl;
      }

      final bucket = withoutProtocol.substring(0, slashIndex);
      final path = withoutProtocol.substring(slashIndex + 1);

      // URL encode the path (replace / with %2F)
      final encodedPath = path.replaceAll('/', '%2F');

      // Build Firebase Storage HTTPS URL
      final httpsUrl =
          'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';

      debugPrint('🔄 Converted: $gsUrl → $httpsUrl');
      return httpsUrl;
    } catch (e) {
      debugPrint('❌ Error converting URL: $e');
      return gsUrl;
    }
  }

  /// Check if a URL is a gs:// URL
  static bool isGsUrl(String url) {
    return url.startsWith('gs://');
  }
}
