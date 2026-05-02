import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/remote_asset_service.dart';

/// Optimized cached image widget that loads logo once and reuses it
class CachedLogoImage extends StatelessWidget {
  final double height;
  final double width;
  final String? imageUrl;

  const CachedLogoImage({
    super.key,
    this.height = 100,
    this.width = 100,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: imageUrl == null || imageUrl!.isEmpty
          ? Future.value('')
          : RemoteAssetService.resolveDownloadUrl(imageUrl!),
      builder: (context, snapshot) {
        final resolvedUrl = snapshot.data ?? '';

        if (resolvedUrl.isNotEmpty) {
          return CachedNetworkImage(
            imageUrl: resolvedUrl,
            height: height,
            width: width,
            fit: BoxFit.contain,
            memCacheHeight:
                (height * MediaQuery.of(context).devicePixelRatio).toInt(),
            memCacheWidth:
                (width * MediaQuery.of(context).devicePixelRatio).toInt(),
            placeholder: (context, url) => SizedBox(
              height: height,
              width: width,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Image.asset(
              'assets/images/Bibi_Logo_Vector 1.png',
              height: height,
              width: width,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: height,
            width: width,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return Image.asset(
          'assets/images/Bibi_Logo_Vector 1.png',
          height: height,
          width: width,
          cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
          cacheHeight: (height * MediaQuery.of(context).devicePixelRatio).toInt(),
        );
      },
    );
  }
}
