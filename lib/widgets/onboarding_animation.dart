import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';

/// Optimized animation widget for Impeller GPU rendering
/// 
/// Properly loads compressed .lottie files by:
/// - Using DotLottieLoader to decompress the .lottie zip container
/// - Rendering via Lottie.memory for GPU optimization
/// - Caching decompressed animations
/// - RepaintBoundary for efficient GPU layer management
class OnboardingAnimation extends StatefulWidget {
  final String assetPath;
  final double translateX;
  final double translateY;
  final bool repeat;

  const OnboardingAnimation({
    super.key,
    required this.assetPath,
    this.translateX = -160,
    this.translateY = -40,
    this.repeat = true,
  });

  @override
  State<OnboardingAnimation> createState() => _OnboardingAnimationState();
}

class _OnboardingAnimationState extends State<OnboardingAnimation> {
  @override
  void initState() {
    super.initState();
    print('🎬 Loading animation: ${widget.assetPath}');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.5;
    final height = 450.0;

    return Align(
      alignment: Alignment.centerLeft,
      child: Transform.translate(
        offset: Offset(widget.translateX, widget.translateY),
        child: SizedBox(
          width: width,
          height: height,
          child: RepaintBoundary(
            child: DotLottieLoader.fromAsset(
              widget.assetPath,
              frameBuilder: (context, dotLottie) {
                if (dotLottie == null) {
                  print('⏳ Decompressing: ${widget.assetPath}');
                  return const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                if (dotLottie.animations.isEmpty) {
                  print('⚠️ No animations in ${widget.assetPath}');
                  return const SizedBox.shrink();
                }

                print('✅ Loaded: ${widget.assetPath}');

                return Lottie.memory(
                  dotLottie.animations.values.first,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  repeat: widget.repeat,
                  reverse: false,
                  animate: true,
                  imageProviderFactory: (asset) {
                    if (dotLottie.images.containsKey(asset.fileName)) {
                      return MemoryImage(dotLottie.images[asset.fileName]!);
                    }
                    return null;
                  },
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('❌ Error loading ${widget.assetPath}: $error');
                return Container(
                  color: Colors.transparent,
                  child: const SizedBox.shrink(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}