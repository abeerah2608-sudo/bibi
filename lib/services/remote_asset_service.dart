import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Utility service for handling remote assets (images, audio, animations)
/// from Firebase Storage
class RemoteAssetService {
  static final RemoteAssetService _instance =
      RemoteAssetService._internal();

  factory RemoteAssetService() {
    return _instance;
  }

  RemoteAssetService._internal();

  final CacheManager _cacheManager = DefaultCacheManager();
  static final Map<String, String> _resolvedUrlCache = <String, String>{};

  /// Check if URL is a remote Firebase Storage URL
  static bool isRemoteUrl(String url) {
    return url.startsWith('gs://') ||
        (url.startsWith('https://') && url.contains('firebasestorage'));
  }

  /// Get local path for cached remote asset
  Future<String?> getCachedAssetPath(String url) async {
    if (!isRemoteUrl(url)) {
      return url; // Return as-is if local asset
    }

    try {
      // IMPORTANT: do not trigger a network download when only checking cache.
      final cached = await _cacheManager.getFileFromCache(url);
      return cached?.file.path;
    } catch (e) {
      debugPrint('❌ Error caching remote asset: $e');
      return null;
    }
  }

  /// Convert Firebase Storage gs:// URL to https URL
  static String convertGsUrlToHttps(String gsUrl) {
    if (gsUrl.startsWith('gs://')) {
      // gs://bibi-app-d41a0.firebasestorage.app/path
      // → https://firebasestorage.googleapis.com/v0/b/bibi-app-d41a0.firebasestorage.app/o/path
      final parts = gsUrl.replaceFirst('gs://', '').split('/');
      final bucket = parts[0];
      final path = parts.sublist(1).join('/');
      final encodedPath = Uri.encodeComponent(path);
      return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
    }
    return gsUrl;
  }

  /// Resolve a Firebase Storage URL to a downloadable HTTPS URL.
  /// This is safer than constructing the media endpoint by hand.
  static Future<String> resolveDownloadUrl(String url) async {
    if (url.isEmpty) {
      return url;
    }

    final cached = _resolvedUrlCache[url];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    debugPrint('🔎 resolveDownloadUrl input: $url');

    if (url.startsWith('gs://')) {
      try {
        final resolved = await FirebaseStorage.instance.refFromURL(url).getDownloadURL();
        debugPrint('✅ Resolved gs:// -> $resolved');
        _resolvedUrlCache[url] = resolved;
        return resolved;
      } catch (e, st) {
        debugPrint('❌ Failed to resolve Firebase download URL for $url: $e');
        debugPrint('   stack: $st');
        final fallback = convertGsUrlToHttps(url);
        debugPrint('➡️ Falling back to constructed https URL: $fallback');
        _resolvedUrlCache[url] = fallback;
        return fallback;
      }
    }

    // Non-gs URL: return as-is but log for visibility
    debugPrint('ℹ️ resolveDownloadUrl returning non-gs URL: $url');
    _resolvedUrlCache[url] = url;
    return url;
  }

  /// Preload multiple remote assets
  Future<void> preloadAssets(List<String> urls) async {
    final remote = urls.where(isRemoteUrl).toList();
    if (remote.isEmpty) {
      debugPrint('ℹ️ preloadAssets: no remote assets to preload');
      return;
    }

    final results = await Future.wait(
      remote.map((url) async {
        try {
          debugPrint('⬇️ Preloading asset: $url');
          final file = await _cacheManager.downloadFile(url);
          final length = await file.file.length();
          debugPrint('   ✅ Preloaded: ${file.file.path} (size=$length bytes)');
          return true;
        } catch (e, st) {
          debugPrint('   ⚠️ Failed to preload $url: $e');
          debugPrint('      stack: $st');
          return false;
        }
      }),
    );

    final success = results.where((ok) => ok).length;
    debugPrint('✅ Preloaded $success/${remote.length} remote assets');
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
    debugPrint('✅ Remote asset cache cleared');
  }

  /// Get cache size in MB
  Future<double> getCacheSizeInMB() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final cacheSubDir = Directory('${cacheDir.path}/libCachedImageData');

      if (!await cacheSubDir.exists()) return 0.0;

      int totalBytes = 0;
      await for (final entity in cacheSubDir.list(recursive: true)) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }

      return totalBytes / (1024 * 1024); // Convert bytes → MB
    } catch (e) {
      debugPrint('⚠️ Error calculating cache size: $e');
      return 0.0;
    }
  }
}