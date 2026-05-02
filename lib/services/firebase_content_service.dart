import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'remote_asset_service.dart';

/// Service to fetch dynamic content from Firebase Firestore
/// Handles onboarding flow and dashboard configuration
class FirebaseContentService {
  static final FirebaseContentService _instance =
      FirebaseContentService._internal();

  factory FirebaseContentService() {
    return _instance;
  }

  FirebaseContentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>>? _cachedOnboardingPages;
  DateTime? _lastOnboardingFetch;
  static const Duration _onboardingCacheTtl = Duration(minutes: 5);

  // Collections constants
  static const String _onboardingCollection = 'content';
  static const String _dashboardCollection = 'content';
  static const String _onboardingDocId = 'onboarding_flow';
  static const String _dashboardDocId = 'dashboard_config';

  /// Fetch onboarding flow configuration from Firebase
Future<List<Map<String, dynamic>>> fetchOnboardingFlow({bool forceRefresh = false}) async {
  try {
    final now = DateTime.now();
    final hasFreshMemoryCache = !forceRefresh &&
        _cachedOnboardingPages != null &&
        _lastOnboardingFetch != null &&
        now.difference(_lastOnboardingFetch!) < _onboardingCacheTtl;

    if (hasFreshMemoryCache) {
      debugPrint('⚡ FirebaseContentService: serving onboarding pages from memory cache');
      _warmOnboardingAssetsInBackground(_cachedOnboardingPages!);
      return _cachedOnboardingPages!;
    }

    final snapshot = await _firestore
        .collection('onboarding_pages')
        .orderBy('order')
        .get();
    
    debugPrint("✅ FETCHED ${snapshot.docs.length} PAGES FROM FIRESTORE");

    for (var i = 0; i < snapshot.docs.length; i++) {
      final doc = snapshot.docs[i];
      debugPrint("  Page $i: order=${doc['order']}, textKey=${doc['textKey']}");
    }

    final pages = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // include document id so callers can find pages by document name
      data['id'] = doc.id;
      return data;
    }).toList();

    _cachedOnboardingPages = List<Map<String, dynamic>>.unmodifiable(
      pages.map((e) => Map<String, dynamic>.from(e)),
    );
    _lastOnboardingFetch = DateTime.now();

    _warmOnboardingAssetsInBackground(pages);

    return pages;
  } catch (e) {
    debugPrint("❌ Error fetching from server, falling back to cache: $e");
    // Fallback to cache if server fetch fails (offline support)
    try {
      final snapshot = await _firestore
          .collection('onboarding_pages')
          .orderBy('order')
          .get(GetOptions(source: Source.cache));
      debugPrint("⚠️ FETCHED ${snapshot.docs.length} PAGES FROM CACHE (offline)");
      final pages = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      _cachedOnboardingPages = List<Map<String, dynamic>>.unmodifiable(
        pages.map((e) => Map<String, dynamic>.from(e)),
      );
      _lastOnboardingFetch = DateTime.now();
      _warmOnboardingAssetsInBackground(pages);

      return pages;
    } catch (cacheError) {
      debugPrint("❌ Cache also failed: $cacheError");
      return [];
    }
  }
}

void _warmOnboardingAssetsInBackground(List<Map<String, dynamic>> pages) {
  Future<void>(() async {
    try {
      final urls = <String>{};
      for (final p in pages) {
        final anim = (p['animationPath'] as String?) ?? '';
        if (anim.isNotEmpty) urls.add(anim);
        final eng = (p['englishAudio'] as String?) ?? '';
        if (eng.isNotEmpty) urls.add(eng);
        final urdu = (p['urduAudio'] as String?) ?? '';
        if (urdu.isNotEmpty) urls.add(urdu);
        final logo = (p['logoUrl'] as String?) ?? '';
        if (logo.isNotEmpty) urls.add(logo);
        final background = (p['backgroundImage'] as String?) ??
            (p['backgroundImageUrl'] as String?) ??
            '';
        if (background.isNotEmpty) urls.add(background);
      }

      if (urls.isEmpty) return;

      debugPrint('🔁 Background warm-up for ${urls.length} onboarding assets');
      final resolved = await Future.wait(
        urls.map((u) => RemoteAssetService.resolveDownloadUrl(u)),
      );
      await RemoteAssetService().preloadAssets(resolved);
      debugPrint('✅ Background onboarding asset warm-up complete');
    } catch (prefetchError) {
      debugPrint('⚠️ Background onboarding warm-up failed: $prefetchError');
    }
  });
}

  /// Fetch dashboard configuration from Firebase
  Future<Map<String, dynamic>?> fetchDashboardConfig() async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_dashboardCollection)
          .doc(_dashboardDocId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('✅ Fetched dashboard config from Firebase');
        return data;
      } else {
        debugPrint('❌ Dashboard config document not found in Firebase');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching dashboard config: $e');
      return null;
    }
  }

  /// Stream for real-time onboarding flow updates
  Stream<Map<String, dynamic>?> onboardingFlowStream() {
    return _firestore
        .collection(_onboardingCollection)
        .doc(_onboardingDocId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            debugPrint('📡 Onboarding flow updated');
            return doc.data() as Map<String, dynamic>;
          }
          return null;
        });
  }

  /// Stream for real-time dashboard configuration updates
  Stream<Map<String, dynamic>?> dashboardConfigStream() {
    return _firestore
        .collection(_dashboardCollection)
        .doc(_dashboardDocId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            debugPrint('📡 Dashboard config updated');
            return doc.data() as Map<String, dynamic>;
          }
          return null;
        });
  }

  /// Fetch all content documents (for admin/debugging)
  Future<List<Map<String, dynamic>>> fetchAllContent() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection(_onboardingCollection).get();
      final List<Map<String, dynamic>> content = [];
      for (var doc in snapshot.docs) {
        content.add(doc.data() as Map<String, dynamic>);
      }
      return content;
    } catch (e) {
      debugPrint('❌ Error fetching all content: $e');
      return [];
    }
  }
}
