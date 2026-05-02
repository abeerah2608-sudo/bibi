import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/remote_asset_service.dart';
import '../models/dynamic_page_models.dart';
import 'package:flutter/foundation.dart';
class DynamicContentService {
  static final DynamicContentService _instance =
      DynamicContentService._internal();

  factory DynamicContentService() => _instance;

  DynamicContentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late SharedPreferences _prefs;

  final Map<String, DynamicPageConfig> _configCache = {};

  static const int CACHE_VALIDITY_MINUTES = 60;

  // ========================================================================
  // INIT
  // ========================================================================
  AssetRegistry buildAssetRegistry(List<PageModel> pages) {
    debugPrint("🚀 BUILDING ASSET REGISTRY...");

    final animations = <String, String>{};
    final images = <String, String>{};
    final audio = <String, String>{};

    for (final page in pages) {
      debugPrint("📄 Processing page: ${page.id}");

      for (final component in page.components) {
        debugPrint("🧩 COMPONENT FOUND: ${component.type}");
        debugPrint("🔍 content: ${component.content}");
        debugPrint("🔑 assetKey (root): ${component.assetKey}");

        // FIX: read from BOTH places safely
        final assetKey =
            component.assetKey ?? component.content['assetKey'];

        if (assetKey != null) {
          debugPrint("✅ USING assetKey: $assetKey");

          animations[assetKey] =
              RemoteAssetService.convertGsUrlToHttps(
            'gs://bibi-app-d41a0.firebasestorage.app/animations/$assetKey',
          );

          debugPrint("🎞 ADDED TO REGISTRY: $assetKey");
        } else {
          debugPrint("⚠️ NO assetKey FOUND for component ${component.id}");
        }
      }

      final audioMap = page.audio;
      if (audioMap != null) {
        debugPrint("🔊 AUDIO FOUND: $audioMap");
        audio.addAll(audioMap);
      }
    }

    debugPrint("🧠 FINAL ANIMATIONS MAP:");
    debugPrint(animations.toString());

    return AssetRegistry(
      animations: animations,
      images: images,
      audio: audio,
    );
  }

  // ========================================================================
  // MAIN LOADER
  // ========================================================================
  Future<DynamicPageConfig> loadPageConfiguration({
    required String collectionName,
    bool forceRefresh = false,
  }) async {

    if (!forceRefresh && _configCache.containsKey(collectionName)) {
      debugPrint("⚡ USING CACHE for $collectionName");
      return _configCache[collectionName]!;
    }

    try {
      debugPrint("🔥 FETCHING FIRESTORE: $collectionName");

      final snapshot =
          await _firestore.collection(collectionName).get();

      debugPrint("📦 DOC COUNT: ${snapshot.docs.length}");

      if (snapshot.docs.isEmpty) {
        throw Exception("No pages found in collection: $collectionName");
      }

      final pages = snapshot.docs.map((doc) {
        final data = doc.data();

        debugPrint("📄 RAW PAGE: ${doc.id}");
        debugPrint("📦 DATA: $data");

        data['id'] = doc.id;

        return PageModel.fromJson(data);
      }).toList();

      pages.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

      debugPrint("📊 TOTAL PAGES LOADED: ${pages.length}");

      final assets = buildAssetRegistry(pages);

      final config = DynamicPageConfig(
        schemaVersion: '2.0.0',
        metadata: ConfigMetadata(version: '2.0.0'),
        assets: assets,
        styleTokens: StyleTokens(textStyles: {}),
        pages: pages,
      );

      debugPrint("💾 CACHING CONFIG for $collectionName");

      _configCache[collectionName] = config;

      return config;
    } catch (e, stack) {
      debugPrint("❌ FIREBASE ERROR: $e");
      debugPrint(stack.toString());

      throw Exception(
        "Firebase load failed for '$collectionName': $e\n$stack",
      );
    }
  }

  // ========================================================================
  // SINGLE PAGE
  // ========================================================================
  Future<PageModel?> loadPage({
    required String collectionName,
    required String pageId,
  }) async {
    try {
      debugPrint("📄 LOADING SINGLE PAGE: $pageId");

      final doc =
          await _firestore.collection(collectionName).doc(pageId).get();

      if (!doc.exists) {
        debugPrint("❌ PAGE NOT FOUND: $pageId");
        return null;
      }

      final data = doc.data() ?? {};

      debugPrint("📦 PAGE DATA: $data");

      data['id'] = doc.id;

      return PageModel.fromJson(data);
    } catch (e) {
      debugPrint("❌ FAILED PAGE LOAD: $e");
      return null;
    }
  }

  // ========================================================================
  // MULTI PAGE
  // ========================================================================
  Future<List<PageModel>> loadPages({
    required String collectionName,
    required List<String> pageIds,
  }) async {
    final pages = <PageModel>[];

    for (final id in pageIds) {
      final page = await loadPage(
        collectionName: collectionName,
        pageId: id,
      );

      if (page != null) {
        pages.add(page);
      }
    }

    return pages;
  }

  // ========================================================================
  // CACHE
  // ========================================================================
  void clearMemoryCache() {
    debugPrint("🧹 CACHE CLEARED");
    _configCache.clear();
  }

  Map<String, dynamic> getCacheStats() {
    return {
      "configCacheSize": _configCache.length,
      "cachedKeys": _configCache.keys.toList(),
    };
  }
}