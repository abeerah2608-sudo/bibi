import 'package:flutter/material.dart';

/// Optimized cached image widget that loads logo once and reuses it
class CachedLogoImage extends StatelessWidget {
  final double height;
  final double width;

  const CachedLogoImage({
    super.key,
    this.height = 100,
    this.width = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Bibi_Logo_Vector 1.png',
      height: height,
      width: width,
      cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
      cacheHeight: (height * MediaQuery.of(context).devicePixelRatio).toInt(),
    );
  }
}
