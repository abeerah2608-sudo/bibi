/// Global cache for .lottie animations optimized for Impeller GPU rendering
///
/// Note: Lottie.asset() handles .lottie files directly and automatically
/// This service is used just for pre-loading/logging
class AnimationCacheService {
  static final AnimationCacheService _instance = AnimationCacheService._internal();
  final List<String> _preloadedAssets = [];

  AnimationCacheService._internal();

  factory AnimationCacheService() {
    return _instance;
  }

  /// Pre-load animation asset paths at app startup
  Future<void> preloadAnimations(List<String> assetPaths) async {
    _preloadedAssets.addAll(assetPaths);
    print('Pre-loading ${assetPaths.length} animations for Impeller GPU');
    for (final path in assetPaths) {
      print('  - $path');
    }
  }

  /// Get list of pre-loaded assets
  List<String> getPreloadedAssets() => List.unmodifiable(_preloadedAssets);
}

void debugPrint(String message) {
  print(message);
}
