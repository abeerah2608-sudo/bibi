import 'package:flutter/material.dart';

import '../pages/audio_player_page.dart';

class VideoCardData {
  final String title;
  final String? videoUrl;
  final String subtitle;
  final String duration;
  final String imagePlaceholder;
  final String? remoteImageUrl;
  final Color? accentColor;
  final String? titleKey;
  final String? subtitleKey;
  final AudioContent? audioContent;
  final String? favoriteId;

  const VideoCardData({
    required this.title,
    required this.subtitle,
    this.videoUrl,
    required this.duration,
    required this.imagePlaceholder,
    this.remoteImageUrl,
    this.audioContent,
    this.accentColor,
    this.titleKey,
    this.subtitleKey,
    this.favoriteId,
  });
}