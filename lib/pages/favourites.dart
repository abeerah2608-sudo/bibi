import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../bloc/favourites_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../models/dashboard_models.dart';
import '../models/video_card_data.dart';
import '../services/language_strings.dart';
import 'audio_player_page.dart'
    show
        AudioContent,
        audioContent1,
        audioContent2,
        audioContent3,
        audioContent4,
        audioContent5,
        audioContent6,
        audioContent7;
import 'dashboard.dart' as dashboard;
import 'video_card.dart';

class FavoritesPage extends StatefulWidget {
  final String language;

  const FavoritesPage({super.key, required this.language});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _config = const {};
  List<VideoCardData> _allVideos = const [];

  @override
  void initState() {
    super.initState();
    debugPrint("🚀 FavoritesPage initState START - language=${widget.language}");
    _loadFavoritesConfig();
  }

  Future<void> _loadFavoritesConfig() async {
    try {
      debugPrint("📂 FavoritesPage: Starting config load");
      setState(() {
        _isLoading = true;
        _error = null;
      });

      debugPrint('⚠️ FavoritesPage: Loading videos from Firestore');
      final root = await _fetchFavoritesRoot();
      debugPrint('📊 FavoritesPage root keys: ${root.keys.toList()}');
      
      final videosRaw =
          ((root['videoSources'] as Map<String, dynamic>?)?['allVideos']
                  as List<dynamic>?) ??
              const [];

      debugPrint('📊 FavoritesPage videosRaw length: ${videosRaw.length}');
      if (videosRaw.isNotEmpty) {
        debugPrint('📊 FavoritesPage First video raw: ${videosRaw.first}');
      }

      final videos = videosRaw
          .whereType<Map<String, dynamic>>()
          .map(_toVideoCardDataFromJson)
          .where((video) => (video.favoriteId ?? '').isNotEmpty)
          .toList();

      if (!mounted) {
        debugPrint("⚠️ FavoritesPage: Widget unmounted, skipping state update");
        return;
      }
      
      setState(() {
        _config = root;
        _allVideos = videos;
        _isLoading = false;
      });
      debugPrint('✅ FavoritesPage: Successfully loaded ${videos.length} videos');
    } catch (e, st) {
      debugPrint('❌ FavoritesPage error in _loadFavoritesConfig: $e');
      debugPrint('   Stack trace: $st');
      if (!mounted) {
        debugPrint("⚠️ FavoritesPage: Widget unmounted in error handler");
        return;
      }
      setState(() {
        _isLoading = false;
        _error = 'Failed to load favorites: $e';
      });
    }
  }

  VideoCardData _toVideoCardData(VideoCardFirebaseData fbData) {
    final titleTranslations = fbData.titleTranslations;
    final subtitleTranslations = fbData.subtitleTranslations;
    
    final key = _languageKey(widget.language);
    
    final title = titleTranslations[key] ??
        titleTranslations['English'] ??
        fbData.titleKey;
        
    final subtitle = subtitleTranslations[key] ??
        subtitleTranslations['English'] ??
        fbData.subtitleKey;
        
    return VideoCardData(
      title: title,
      titleKey: fbData.titleKey,
      subtitle: subtitle,
      subtitleKey: fbData.subtitleKey,
      favoriteId: fbData.favoriteId,
      duration: fbData.duration,
      imagePlaceholder: 'miss_bibi.png',
      remoteImageUrl: fbData.thumbnail.isNotEmpty ? fbData.thumbnail : null,
      videoUrl: fbData.videoUrl.isNotEmpty ? fbData.videoUrl : null,
      audioContent: _mapAudioContent(fbData.audioContentId),
      accentColor: _parseHexColor(fbData.accentColor),
    );
  }

  VideoCardData _toVideoCardDataFromJson(Map<String, dynamic> json) {
    final titleTranslations =
        ((json['translations'] as Map<String, dynamic>?)?['title']
            as Map<String, dynamic>?) ??
        const {};
    final subtitleTranslations =
        ((json['translations'] as Map<String, dynamic>?)?['subtitle']
            as Map<String, dynamic>?) ??
        const {};

    debugPrint('📋 _toVideoCardDataFromJson: id=${json['id']}');
    debugPrint('  - titleTranslations=$titleTranslations');
    debugPrint('  - subtitleTranslations=$subtitleTranslations');

    final titleKey = (json['titleKey'] as String?) ?? '';
    final subtitleKey = (json['subtitleKey'] as String?) ?? '';
    final favoriteId = (json['favoriteId'] as String?) ?? titleKey;

    final title = _resolveVideoText(
      translations: titleTranslations,
      fallbackKey: titleKey,
      fallbackText: json['id']?.toString() ?? '',
    );

    final subtitle = _resolveVideoText(
      translations: subtitleTranslations,
      fallbackKey: subtitleKey,
      fallbackText: '',
    );

    debugPrint('  ✅ Resolved: title=$title, subtitle=$subtitle');

    final audioContentId = (json['audioContentId'] as String?) ?? '';
    final thumbnail = (json['thumbnail'] as String?) ?? '';
    final videoUrl = json['videoUrl'] as String?;

    return VideoCardData(
      title: title,
      // Keep null so VideoCard uses Firebase-provided text instead of local key lookup.
      titleKey: null,
      subtitle: subtitle,
      subtitleKey: null,
      favoriteId: favoriteId.isNotEmpty ? favoriteId : null,
      duration: (json['duration'] as String?) ?? '0:00',
      imagePlaceholder: 'miss_bibi.png',
      remoteImageUrl: thumbnail.isNotEmpty ? thumbnail : null,
      videoUrl: (videoUrl != null && videoUrl.isNotEmpty) ? videoUrl : null,
      audioContent: _mapAudioContent(audioContentId),
    );
  }

  Future<Map<String, dynamic>> _fetchFavoritesRoot() async {
    final firestore = FirebaseFirestore.instance;
    const candidateDocIds = ['favourites', 'favorites', 'favorites_page'];
    debugPrint('⭐ FavoritesPage config load: checking json_documents $candidateDocIds');

    for (final docId in candidateDocIds) {
      final snap = await firestore
          .collection('json_documents')
          .doc(docId)
          .get(const GetOptions(source: Source.server));
      if (!snap.exists) continue;

      final data = snap.data();
      if (data == null) continue;

      final nested = data['favorites'];
      if (nested is Map<String, dynamic>) {
        debugPrint('✅ FavoritesPage config source=Firestore json_documents/$docId (nested favorites map)');
        return nested;
      }
      debugPrint('✅ FavoritesPage config source=Firestore json_documents/$docId (root map)');
      return data;
    }

    debugPrint('❌ FavoritesPage config not found in Firestore for any candidate doc id');
    throw Exception(
      'No favorites document found in json_documents (tried: ${candidateDocIds.join(', ')})',
    );
  }

  String _resolveVideoText({
    required Map<String, dynamic> translations,
    required String fallbackKey,
    required String fallbackText,
  }) {
    debugPrint('🔍 _resolveVideoText called: translations=$translations, fallbackKey=$fallbackKey, fallbackText=$fallbackText');
    final lang = _languageKey(widget.language);
    debugPrint('  - language=${widget.language} -> lang=$lang');
    
    final translated = translations[lang]?.toString();
    debugPrint('  - translations[$lang] = $translated');
    
    if (translated != null && translated.isNotEmpty) {
      debugPrint('  ✅ Found translation: $translated');
      return translated;
    }

    // Avoid local string fallback here so UI reflects Firebase changes directly.
    debugPrint('  ⚠️ Translation not found, returning fallbackText: $fallbackText');
    return fallbackText;
  }

  AudioContent? _mapAudioContent(String contentId) {
    switch (contentId) {
      case 'audio_content_1':
        return audioContent1;
      case 'audio_content_2':
        return audioContent2;
      case 'audio_content_3':
        return audioContent3;
      case 'audio_content_4':
        return audioContent4;
      case 'audio_content_5':
        return audioContent5;
      case 'audio_content_6':
        return audioContent6;
      case 'audio_content_7':
        return audioContent7;
      default:
        return null;
    }
  }

 String _languageKey(String language) {
  switch (language) {
    case 'Urdu':
    case 'اردو':
      return 'اردو';
    case 'Roman Urdu':
      return 'Roman Urdu';
    case 'English':
    default:
      return 'English';
  }
}

  String _getSectionTranslation({
    required String section,
    required String key,
    required String language,
    required String fallback,
  }) {
    final sectionMap = _config[section] as Map<String, dynamic>?;
    final translations = sectionMap?['translations'] as Map<String, dynamic>?;
    final byKey = translations?[key] as Map<String, dynamic>?;
    final lang = _languageKey(language);

    return byKey?[lang]?.toString() ??
        byKey?['English']?.toString() ??
        fallback;
  }

  Color _parseHexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return const Color(0xFFE91E8C);
    }
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'favorite_border':
        return Icons.favorite_border;
      case 'favorite':
        return Icons.favorite;
      case 'favorite_outline':
        return Icons.favorite_border;
      default:
        return Icons.favorite_border;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🌐 FavoritesPage build: language="${widget.language}"');
    
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        String currentLanguage = 'English';
        if (languageState is LanguageSelected) {
          currentLanguage = languageState.language;
        }
        debugPrint('🌐 FavoritesPage: currentLanguage="$currentLanguage"');

        try {
          final favoritesTitle = _getSectionTranslation(
            section: 'appBar',
            key: 'favorites',
            language: currentLanguage,
            fallback: LanguageStrings.getTranslation(currentLanguage, 'favorites'),
          );

          final noFavoritesText = _getSectionTranslation(
            section: 'emptyState',
            key: 'no_favorites',
            language: currentLanguage,
            fallback: LanguageStrings.getTranslation(currentLanguage, 'no_favorites'),
          );

          final backgroundColor = _config['backgroundColor']?.toString() ?? '#FFF4F4';
          final appBarConfig = _config['appBar'] as Map<String, dynamic>?;
          final appBarColor = appBarConfig?['backgroundColor']?.toString() ?? backgroundColor;
          final appBarIconTheme = appBarConfig?['iconTheme'] as Map<String, dynamic>?;
          final emptyStateConfig = _config['emptyState'] as Map<String, dynamic>?;
          final emptyStateIcon = emptyStateConfig?['icon']?.toString() ?? 'favorite_border';
          final emptyStateIconSize = (emptyStateConfig?['iconSize'] as num?)?.toDouble() ?? 64;
          final emptyStateIconColor = _parseHexColor(emptyStateConfig?['iconColor']?.toString() ?? '#CCCCCC');

          return Scaffold(
            backgroundColor: _parseHexColor(backgroundColor),
            appBar: AppBar(
              backgroundColor: _parseHexColor(appBarColor),
              elevation: (appBarConfig?['elevation'] as num?)?.toDouble() ?? 0,
              title: Text(
                favoritesTitle,
                style: TextStyle(
                  color: _parseHexColor(appBarConfig?['textStyle']?['color']?.toString() ?? '#333333'),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              iconTheme: IconThemeData(
                color: _parseHexColor(appBarIconTheme?['color']?.toString() ?? '#333333'),
                size: (appBarIconTheme?['size'] as num?)?.toDouble() ?? 24.sp,
              ),
            ),
            body: BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                debugPrint('🎯 FavoritesPage BlocBuilder: FavoritesState=${state.runtimeType}, favoriteIds count=${state.favoriteIds.length}');
                
                if (_isLoading) {
                  debugPrint('⏳ FavoritesPage: Loading state');
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE91E8C)),
                  );
                }

                if (_error != null) {
                  debugPrint('❌ FavoritesPage: Error state - $_error');
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF888888),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }

                try {
                  final favoriteVideos = _allVideos
                      .where((video) => state.favoriteIds.contains(
                          video.favoriteId ?? video.titleKey ?? video.title))
                      .toList();

                  debugPrint('📹 FavoritesPage: Found ${favoriteVideos.length} favorite videos out of ${_allVideos.length} total');

                  if (favoriteVideos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _iconFromName(emptyStateIcon),
                            size: emptyStateIconSize.sp,
                            color: emptyStateIconColor,
                          ),
                          SizedBox(height: (emptyStateConfig?['spacing'] as num?)?.toDouble() ?? 16.h),
                          Text(
                            noFavoritesText.isNotEmpty ? noFavoritesText : 'No favorites yet ❤️',
                            style: TextStyle(
                              color: _parseHexColor(emptyStateConfig?['textStyle']?['color']?.toString() ?? '#888888'),
                              fontSize: (emptyStateConfig?['textStyle']?['fontSize'] as num?)?.toDouble() ?? 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                    itemCount: favoriteVideos.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      try {
                        return VideoCard(
                          data: favoriteVideos[index],
                          language: currentLanguage,
                        );
                      } catch (e) {
                        debugPrint('❌ Error building favorite video card $index: $e');
                        return SizedBox(
                          height: 100.h,
                          child: Center(child: Text('Error loading card')),
                        );
                      }
                    },
                  );
                } catch (e, st) {
                  debugPrint('❌ FavoritesPage BlocBuilder error: $e');
                  debugPrint('   Stack: $st');
                  return Center(
                    child: Text('Error: $e'),
                  );
                }
              },
            ),
          );
        } catch (e, st) {
          debugPrint('❌ FavoritesPage build error: $e');
          debugPrint('   Stack: $st');
          return Scaffold(
            body: Center(
              child: Text('Error building favorites: $e'),
            ),
          );
        }
      },
    );
  }
}