import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'languageSelection.dart';
import 'dashboard.dart';
import '../services/remote_asset_service.dart';

class SplashScreen extends StatefulWidget {
  final bool hasCompletedOnboarding;
  
  const SplashScreen({super.key, required this.hasCompletedOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Map<String, dynamic>? _splashConfig;
  String? _resolvedAnimationUrl;
  bool _loggedFirebaseRender = false;

  @override
  void initState() {
    super.initState();
    _loadSplashConfig();
    _navigateToLanguageSelection();
  }

  Future<void> _loadSplashConfig() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('splash_screen')
          .get();

      if (!doc.exists) {
        debugPrint('⚠️ Splash config not found in app_config/splash_screen');
        return;
      }

      final data = doc.data();
      if (data == null) {
        debugPrint('⚠️ Splash config document is empty');
        return;
      }

      final animationPath = data['animationPath']?.toString() ?? '';
      final resolvedAnimationUrl = animationPath.isNotEmpty
          ? await RemoteAssetService.resolveDownloadUrl(animationPath)
          : '';

      if (!mounted) return;

      setState(() {
        _splashConfig = Map<String, dynamic>.from(data);
        _resolvedAnimationUrl = resolvedAnimationUrl.isNotEmpty
            ? resolvedAnimationUrl
            : null;
        _loggedFirebaseRender = false;
      });

      debugPrint('✅ Splash config loaded from Firebase: app_config/splash_screen');
      debugPrint('📦 Splash config keys: ${data.keys.toList()}');
      debugPrint('🎞️ Splash animationPath: $animationPath');
      debugPrint('🔗 Splash resolved animation URL: ${_resolvedAnimationUrl ?? animationPath}');
    } catch (e, st) {
      debugPrint('❌ Failed to load splash config from Firebase: $e');
      debugPrint('   stack: $st');
    }
  }

  Color _parseColor(String? value, Color fallback) {
    if (value == null || value.isEmpty) return fallback;
    try {
      return Color(int.parse(value.replaceFirst('#', '0xff')));
    } catch (_) {
      return fallback;
    }
  }

  _navigateToLanguageSelection() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => widget.hasCompletedOnboarding
              ? const DashboardScreen()
              : const LanguageSelectionPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final animationPath =
        _splashConfig?['animationPath']?.toString().trim().isNotEmpty == true
            ? _splashConfig!['animationPath'].toString()
            : 'assets/images/splash.lottie';
    final isFirebaseSplash =
        _splashConfig != null && animationPath != 'assets/images/splash.lottie';
    final backgroundColor = _parseColor(
      _splashConfig?['backgroundColor']?.toString(),
      Colors.white,
    );
    final fit = (_splashConfig?['fit']?.toString() ?? 'cover') == 'contain'
        ? BoxFit.contain
        : BoxFit.cover;
    final repeat = _splashConfig?['repeat'] is bool
        ? _splashConfig!['repeat'] as bool
        : true;
    final animate = _splashConfig?['animate'] is bool
        ? _splashConfig!['animate'] as bool
        : true;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RepaintBoundary(
        child: isFirebaseSplash && _resolvedAnimationUrl != null
            ? DotLottieLoader.fromNetwork(
                _resolvedAnimationUrl!,
                frameBuilder: (context, dotLottie) {
                  if (dotLottie == null) {
                    return const SizedBox.shrink();
                  }

                  if (dotLottie.animations.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  if (!_loggedFirebaseRender) {
                    _loggedFirebaseRender = true;
                    debugPrint('✅ Splash rendered from Firebase config: app_config/splash_screen');
                  }

                  return Lottie.memory(
                    dotLottie.animations.values.first,
                    width: double.infinity,
                    height: double.infinity,
                    fit: fit,
                    alignment: Alignment.center,
                    repeat: repeat,
                    animate: animate,
                    imageProviderFactory: (asset) {
                      if (dotLottie.images.containsKey(asset.fileName)) {
                        return MemoryImage(dotLottie.images[asset.fileName]!);
                      }
                      return null;
                    },
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('❌ Splash Firebase animation error: $error');
                  return const SizedBox.shrink();
                },
              )
            : DotLottieLoader.fromAsset(
                animationPath,
                frameBuilder: (context, dotLottie) {
                  if (dotLottie == null) {
                    return const SizedBox.shrink(); // silent wait, no spinner on splash
                  }

                  if (dotLottie.animations.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Lottie.memory(
                    dotLottie.animations.values.first,
                    width: double.infinity,
                    height: double.infinity,
                    fit: fit,
                    alignment: Alignment.center,
                    repeat: repeat,
                    animate: animate,
                    imageProviderFactory: (asset) {
                      if (dotLottie.images.containsKey(asset.fileName)) {
                        return MemoryImage(dotLottie.images[asset.fileName]!);
                      }
                      return null;
                    },
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('❌ Splash local animation error: $error');
                  return const SizedBox.shrink();
                },
              ),
      ),
    );
  }
}