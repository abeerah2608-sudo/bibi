import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/bloc_exports.dart';
import '../models/video_card_data.dart';
import '../services/language_strings.dart';
import '../services/remote_asset_service.dart';
import '../services/quiz_service.dart';
import 'quiz_page_1.dart';
import 'favourites.dart';
import 'dashboard.dart';
import 'quiz_completion_page.dart';
import 'audio_player_page.dart' show AudioPlayerPage,  allAudioContent, AudioContent, audioContent1, audioContent2, audioContent3, audioContent4, audioContent5, audioContent6, audioContent7;


class VideoCard extends StatefulWidget {
  final VideoCardData data;
  final String language;
  const VideoCard({required this.data, required this.language});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  String? _resolvedThumbnailUrl;
  bool _isResolvingThumbnail = false;
  String? _lastRemoteThumbnailUrl;

  @override
  void initState() {
    super.initState();
    _resolveThumbnailUrl();
  }

  @override
  void didUpdateWidget(covariant VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.remoteImageUrl != widget.data.remoteImageUrl) {
      _resolveThumbnailUrl();
    }
  }
  
  Future<void> _launchVideo() async {
    if (widget.data.videoUrl != null) {
      final uri = Uri.parse(widget.data.videoUrl!);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _resolveThumbnailUrl() async {
    final remoteUrl = widget.data.remoteImageUrl;
    _lastRemoteThumbnailUrl = remoteUrl;

    if (remoteUrl == null || remoteUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _resolvedThumbnailUrl = null;
          _isResolvingThumbnail = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isResolvingThumbnail = true;
      });
    }

    final resolved = await RemoteAssetService.resolveDownloadUrl(remoteUrl);

    if (!mounted || _lastRemoteThumbnailUrl != remoteUrl) {
      return;
    }

    setState(() {
      _resolvedThumbnailUrl = resolved;
      _isResolvingThumbnail = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteIds = context.watch<FavoritesBloc>().state.favoriteIds;
    final favoriteKey =
        widget.data.favoriteId ?? widget.data.titleKey ?? widget.data.title;
    final isFavorite = favoriteIds.contains(favoriteKey);
    
    debugPrint('📺 VideoCard build: title=${widget.data.title} | favoriteKey=$favoriteKey | favoriteIds=$favoriteIds | isFavorite=$isFavorite');
    
    final title = widget.data.title
    .replaceAll('[b]', '')
    .replaceAll('[/b]', '');

final subtitle = widget.data.subtitle;
    final watchNow =
        LanguageStrings.getTranslation(widget.language, 'watch_now');

    final isUrdu = widget.language == 'اردو';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                _buildThumbnail(context),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle_fill,
                            color: Colors.white, size: 12),
                        const SizedBox(width: 3),
                        Text(widget.data.duration,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF8B5E3C)),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF8B5E3C)),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          // Check if it's a YouTube video (has videoUrl)
                          if (widget.data.videoUrl != null) {
                            _launchVideo();
                          } 
                          // Check if it has audio content
                          else if (widget.data.audioContent != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AudioPlayerPage(
                                  audioContent: widget.data.audioContent!,
                                  allContent: allAudioContent,
                                ),
                              ),
                            );
                          } 
                          // Neither video URL nor audio content
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isUrdu 
                                    ? 'کوئی مواد دستیاب نہیں'
                                    : 'No content available',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4A7B9).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFFFB2C7), width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(watchNow,
                                  style: const TextStyle(
                                      color: Color(0xFFE86A8D),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12)),
                              const SizedBox(width: 2),
                              const Icon(Icons.chevron_right,
                                  size: 14, color: Color(0xFFE86A8D)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    context.read<FavoritesBloc>().add(
                      ToggleFavoriteEvent(widget.data),
                    );
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 22,
                      color: isFavorite
                          ? const Color(0xFFF68AA8)
                          : const Color(0xFF8B5E3C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    if (_resolvedThumbnailUrl != null && _resolvedThumbnailUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _resolvedThumbnailUrl!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 180,
          width: double.infinity,
          color: const Color(0xFFF6DDE4),
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/images/${widget.data.imagePlaceholder}',
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    if (_isResolvingThumbnail) {
      return Container(
        height: 180,
        width: double.infinity,
        color: const Color(0xFFF6DDE4),
      );
    }

    return Image.asset(
      'assets/images/${widget.data.imagePlaceholder}',
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}