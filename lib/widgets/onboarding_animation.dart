import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';

class OnboardingAnimation extends StatefulWidget {
  final String assetPath;

  /// Values are SCREEN PERCENTAGES:
  /// 0.0 = no movement
  /// 0.1 = 10% of screen
  /// -0.1 = move up/left
  final double translateXPercent;
  final double translateYPercent;

  final bool repeat;
  final Alignment alignment;
  final double scale;

  const OnboardingAnimation({
    super.key,
    required this.assetPath,
    this.translateXPercent = 0.0,
    this.translateYPercent = 0.0,
    this.scale = 1.0,
    this.repeat = true,
    this.alignment = Alignment.center,
  });

  @override
  State<OnboardingAnimation> createState() => _OnboardingAnimationState();
}

class _OnboardingAnimationState extends State<OnboardingAnimation> {
  @override
  void initState() {
    super.initState();
    debugPrint('🎬 Loading animation: ${widget.assetPath}');
  }

  @override
Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size;

  final screenWidth = size.width;
  final screenHeight = size.height;

  final baseW = screenWidth * 0.5;
  final baseH = screenHeight * 0.6;

  return RepaintBoundary(
    child: Transform.translate(
      offset: Offset(
        screenWidth * widget.translateXPercent,
        screenHeight * widget.translateYPercent,
      ),
      child: Transform.scale(
        scale: widget.scale,
        child: Align(
          alignment: widget.alignment,
          child: SizedBox(
            width: baseW,
            height: baseH,
            child: DotLottieLoader.fromAsset(
              widget.assetPath,
              frameBuilder: (context, dotLottie) {
                if (dotLottie == null) {
                  return const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                if (dotLottie.animations.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Lottie.memory(
                  dotLottie.animations.values.first,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  repeat: widget.repeat,
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
                debugPrint('❌ Lottie error: $error');
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    ),
  );
}
}