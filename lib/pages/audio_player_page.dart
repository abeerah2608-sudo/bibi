import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../bloc/bloc_exports.dart';
import '../models/video_card_data.dart';
import '../widgets/onboarding_widgets_exports.dart';

// ── Lyric timestamps (mutable; Firestore can override/extend these) ───────────
Map<String, List<double>> _lyricTimestamps = {
  'assets/audio/whatisbreastcancer.mp3': [0, 2, 5, 7, 10, 13, 16],
  'assets/audio/whatisbreastcancer_urdu.m4a': [0, 6, 11, 17],
  'assets/audio/risk.mp3': [0, 3, 6, 10],
  'assets/audio/risk_urdu.m4a': [0, 8, 13],
  'assets/audio/screen.m4a': [0, 5, 8, 12, 16, 20],
  'assets/audio/screen_urdu.m4a': [0, 6, 10, 16, 22, 26],
  'assets/audio/treat.mp3': [0, 4, 9, 15],
  'assets/audio/treat_urdu.mp3': [0, 7, 14, 18],
  'assets/audio/biopsy.m4a': [0, 5, 9, 13],
  'assets/audio/biopsy_urdu.m4a': [0, 5, 10, 15, 17],
  'assets/audio/prevent.m4a': [0, 5, 9, 13],
  'assets/audio/prevent_urdu.m4a': [0, 6, 10, 15],
  'assets/audio/support.mp3': [0, 5, 11, 15],
  'assets/audio/support_urdu.m4a': [0, 8, 16, 21],
};

int _getLyricIndex(String audioPath, double positionSeconds, int lineCount) {
  final timestamps = _lyricTimestamps[audioPath];
  if (timestamps == null || timestamps.isEmpty || lineCount == 0) {
    return (positionSeconds ~/ 10).clamp(0, lineCount - 1);
  }
  for (int i = timestamps.length - 1; i >= 0; i--) {
    if (positionSeconds >= timestamps[i]) {
      return i.clamp(0, lineCount - 1);
    }
  }
  return 0;
}

// ── Translated UI strings ─────────────────────────────────────────────────────

String _tr(String language, String key) {
  const Map<String, Map<String, String>> _strings = {
    'now_playing': {
      'English': 'NOW PLAYING',
      'Urdu': 'ابھی چل رہا ہے',
      'Roman Urdu': 'ABHI CHAL RAHA HAI',
    },
    'now_learning': {
      'English': 'NOW LEARNING',
      'Urdu': 'ابھی سیکھ رہے ہیں',
      'Roman Urdu': 'ABHI SEEKH RAHE HAIN',
    },
    'lyrics': {
      'English': 'LYRICS',
      'Urdu': 'بول',
      'Roman Urdu': 'BOL',
    },
    'bibi': {
      'English': 'BIBI',
      'Urdu': 'بی بی',
      'Roman Urdu': 'BIBI',
    },
  };
  return _strings[key]?[language] ?? _strings[key]?['English'] ?? key;
}

// ── Data model ────────────────────────────────────────────────────────────────

class AudioContent {
  final String title;
  final String urduTitle;
  final String romanUrduTitle;
  final String subtitle;
  final double scale;

  final String audioPath;
  final String urduAudioPath;
  final String animationPath;
  final List<String> urduLyrics;
  final List<String> romanUrduLyrics;
  final List<String> englishLyrics;
  final double offsetXPercent;
  final double offsetYPercent;

  const AudioContent({
    required this.title,
    this.urduTitle = '',
    this.romanUrduTitle = '',
    required this.subtitle,
    required this.audioPath,
    required this.urduAudioPath,
    required this.animationPath,
    required this.urduLyrics,
    required this.romanUrduLyrics,
    required this.englishLyrics,
    this.scale = 1.0,
    this.offsetXPercent = 0.0,
    this.offsetYPercent = 0.0,
  });

  String getTitle(String language) {
    if (language == 'Urdu' && urduTitle.isNotEmpty) return urduTitle;
    if (language == 'Roman Urdu' && romanUrduTitle.isNotEmpty)
      return romanUrduTitle;
    return title;
  }

  List<String> getLyrics(String language) {
    if (language == 'English') return englishLyrics;
    if (language == 'Urdu') return urduLyrics;
    if (language == 'Roman Urdu') return romanUrduLyrics;
    return [];
  }

  String getAudioPath(String language) {
    if (language == 'Urdu') return urduAudioPath;
    if (language == 'Roman Urdu') return urduAudioPath;
    return audioPath;
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────

class AudioPlayerPage extends StatefulWidget {
  final AudioContent? audioContent;

  final List<AudioContent>? allContent;
  final int? currentIndex;

  const AudioPlayerPage({
    super.key,
    this.audioContent,
    this.allContent,
    this.currentIndex,
  });

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage>
    with WidgetsBindingObserver {
  late PageController _pageController;
  late AudioPlayer _player;
  bool _didInitLanguage = false;

  bool _isPlaying = false;
  double _position = 0.0;
  double _duration = 166.0;
  int _currentLyricLineIndex = 0;
  String _currentLanguage = 'English';
  String _loadedAudioPath = '';

  AudioContent _activeContent = const AudioContent(
    title: '',
    subtitle: '',
    audioPath: '',
    urduAudioPath: '',
    animationPath: '',
    urduLyrics: [],
    romanUrduLyrics: [],
    englishLyrics: [],
  );

  List<AudioContent>? _fetchedContent;
  String _backgroundHex = '#FFF4F4';

  int _loadGeneration = 0;
  bool _isLoading = false;
  bool _isInitializing = true;

  List<String> get _lyricLines =>
      _activeContent.getLyrics(_currentLanguage);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _player.pause();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();

    // Always prefer the Firestore document; fall back to the passed content
    // only if the remote config cannot be loaded.
    debugPrint('🎧 AudioPlayerPage init: fetching Firestore config first');
    _loadFromFirestoreAndInit();
  }

  Future<void> _loadFromFirestoreAndInit() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('json_documents')
          .doc('audioPlayer')
          .get();

      if (!snap.exists) return _useFallbackAndInit();
      final data = snap.data();
      if (data == null) return _useFallbackAndInit();

      final root = data['audioPlayer'] as Map<String, dynamic>? ?? data;
      _backgroundHex = (root['backgroundColor'] as String?) ?? _backgroundHex;
      debugPrint('🎧 AudioPlayerPage Firestore document loaded: json_documents/audioPlayer');

      // Merge lyric timestamps from Firestore (keys are audio paths like gs://...)
      final lyricRaw = root['lyricTimestamps'] as Map<String, dynamic>?;
      if (lyricRaw != null) {
        lyricRaw.forEach((key, val) {
          if (val is List) {
            try {
              final parsed = val
                  .map<double>((e) => (e is num) ? e.toDouble() : double.parse(e.toString()))
                  .toList();
              _lyricTimestamps[key.toString()] = parsed;
            } catch (_) {
              // ignore parse errors per-entry
            }
          }
        });
      }

      final contentRaw = root['content'] as List<dynamic>? ?? [];
      final parsed = <AudioContent>[];
      for (final item in contentRaw) {
        if (item is! Map<String, dynamic>) continue;
        parsed.add(_parseAudioContent(item));
      }

      if (parsed.isEmpty) return _useFallbackAndInit();

      _fetchedContent = parsed;
      _activeContent = _selectInitialContent(parsed);
      debugPrint(
        '🎧 AudioPlayerPage selected remote content: ${_activeContent.title.isNotEmpty ? _activeContent.title : '(untitled)'} | '
        'audio=${_activeContent.audioPath} | urduAudio=${_activeContent.urduAudioPath} | '
        'animation=${_activeContent.animationPath}',
      );
      if (mounted) setState(() {});
      _initializeAudioPlayer();
    } catch (e) {
      if (kDebugMode) print('Failed to load audioPlayer config: $e');
      _useFallbackAndInit();
    }
  }

  AudioContent _parseAudioContent(Map<String, dynamic> raw) {
    String title = '';
    String urduTitle = '';
    String romanTitle = '';
    final titleMap = raw['title'] as Map<String, dynamic>?;
    if (titleMap != null) {
      title = titleMap['English']?.toString() ?? titleMap['english']?.toString() ?? '';
      urduTitle = titleMap['اردو']?.toString() ?? titleMap['Urdu']?.toString() ?? '';
      romanTitle = titleMap['Roman Urdu']?.toString() ?? '';
    }

    final subtitle = raw['subtitle']?.toString() ?? '';
    final scale = (raw['animation']?['scale'] is num) ? (raw['animation']['scale'] as num).toDouble() : 1.0;
    final offsetX = (raw['animation']?['offsetXPercent'] is num) ? (raw['animation']['offsetXPercent'] as num).toDouble() : 0.0;
    final offsetY = (raw['animation']?['offsetYPercent'] is num) ? (raw['animation']['offsetYPercent'] as num).toDouble() : 0.0;

    final animAsset = raw['animation']?['asset']?.toString() ?? '';

    final audioMap = raw['audio'] as Map<String, dynamic>? ?? {};
    final audioEnglish = audioMap['English']?.toString() ?? audioMap['english']?.toString() ?? '';
    final audioUrdu = audioMap['Urdu']?.toString() ?? audioMap['اردو']?.toString() ?? audioMap['Roman Urdu']?.toString() ?? '';

    final lyricsMap = raw['lyrics'] as Map<String, dynamic>? ?? {};
    final englishLyrics = <String>[];
    final urduLyrics = <String>[];
    final romanLyrics = <String>[];
    if (lyricsMap['English'] is List) englishLyrics.addAll((lyricsMap['English'] as List).map((e) => e.toString()));
    if (lyricsMap['Urdu'] is List) urduLyrics.addAll((lyricsMap['Urdu'] as List).map((e) => e.toString()));
    if (lyricsMap['Roman Urdu'] is List) romanLyrics.addAll((lyricsMap['Roman Urdu'] as List).map((e) => e.toString()));

    return AudioContent(
      title: title,
      urduTitle: urduTitle,
      romanUrduTitle: romanTitle,
      subtitle: subtitle,
      audioPath: audioEnglish,
      urduAudioPath: audioUrdu,
      animationPath: animAsset,
      urduLyrics: urduLyrics,
      romanUrduLyrics: romanLyrics,
      englishLyrics: englishLyrics,
      scale: scale,
      offsetXPercent: offsetX,
      offsetYPercent: offsetY,
    );
  }

  AudioContent _selectInitialContent(List<AudioContent> parsed) {
    final local = widget.audioContent;
    if (local == null) {
      debugPrint('🎧 AudioPlayerPage no local content passed; using first Firestore item');
      return parsed.first;
    }

    final localAudio = local.audioPath.trim();
    final localUrduAudio = local.urduAudioPath.trim();
    for (final item in parsed) {
      if (item.audioPath == localAudio ||
          item.urduAudioPath == localAudio ||
          item.audioPath == localUrduAudio ||
          item.urduAudioPath == localUrduAudio) {
        debugPrint(
          '🎧 AudioPlayerPage matched local content to Firestore item by audio path: '
          'local=$localAudio / $localUrduAudio -> remote=${item.audioPath} / ${item.urduAudioPath}',
        );
        return item;
      }
    }

    final localTitle = local.title.trim().toLowerCase();
    final localSubtitle = local.subtitle.trim().toLowerCase();
    for (final item in parsed) {
      if (item.title.trim().toLowerCase() == localTitle ||
          item.subtitle.trim().toLowerCase() == localSubtitle) {
        debugPrint(
          '🎧 AudioPlayerPage matched local content to Firestore item by title/subtitle: '
          'localTitle=$localTitle localSubtitle=$localSubtitle -> remoteTitle=${item.title}',
        );
        return item;
      }
    }

    debugPrint(
      '🎧 AudioPlayerPage could not match local content; falling back to first Firestore item. '
      'localAudio=$localAudio localUrduAudio=$localUrduAudio localTitle=$localTitle localSubtitle=$localSubtitle',
    );
    return parsed.first;
  }

  void _useFallbackAndInit() {
    // fallback to provided widget.audioContent or keep existing
    if (widget.audioContent != null) {
      _activeContent = widget.audioContent!;
      debugPrint(
        '🎧 AudioPlayerPage fallback: using passed local content '
        'audio=${_activeContent.audioPath} | urduAudio=${_activeContent.urduAudioPath} | '
        'animation=${_activeContent.animationPath}',
      );
    } else {
      _activeContent = const AudioContent(
        title: '',
        subtitle: '',
        audioPath: '',
        urduAudioPath: '',
        animationPath: '',
        urduLyrics: [],
        romanUrduLyrics: [],
        englishLyrics: [],
      );
      debugPrint('🎧 AudioPlayerPage fallback: no content available, using empty placeholder');
    }
    _initializeAudioPlayer();
  }

  Color _hexToColor(String hex) {
    var h = hex.replaceAll('#', '').toUpperCase();
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<LanguageBloc>().state;
    if (state is LanguageSelected && !_didInitLanguage) {
      // If we don't yet have content loaded, delay until it arrives
      if (widget.audioContent == null && _fetchedContent == null) return;
      _didInitLanguage = true;
      _currentLanguage = state.language;
      final path = _activeContent.getAudioPath(_currentLanguage);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAudio(path);
      });
    }
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      _player = AudioPlayer();
      if (!mounted) return;
      setState(() => _isInitializing = false);

      debugPrint(
        '🎧 AudioPlayerPage initializing player with current content: '
        'title=${_activeContent.title} audio=${_activeContent.audioPath} '
        'urduAudio=${_activeContent.urduAudioPath} animation=${_activeContent.animationPath}',
      );

      _loadedAudioPath = _activeContent.audioPath;
      _loadAudio(_loadedAudioPath);

      _player.positionStream.listen((pos) {
        if (!mounted) return;
        final secs =
            pos.inSeconds.toDouble().clamp(0.0, _duration);
        setState(() {
          _position = secs;
          _currentLyricLineIndex = _getLyricIndex(
              _loadedAudioPath, secs, _lyricLines.length);
        });
      });

      _player.playingStream.listen((playing) {
        if (!mounted) return;
        setState(() => _isPlaying = playing);
      });
    } catch (e) {
      if (kDebugMode) print('Failed to initialize audio player: $e');
      if (mounted) {
        setState(() => _isInitializing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Audio player unavailable. Please restart the app.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _loadAudio(String path) {
    final int generation = ++_loadGeneration;
    setState(() => _isLoading = true);

    debugPrint('🎧 AudioPlayerPage load requested: $path');
    Future<void> _setAndPlay(String urlOrAsset, {bool isUrl = false}) async {
      if (generation != _loadGeneration) return;
      try {
        debugPrint(
          '🎧 AudioPlayerPage loading media type=${isUrl ? 'network' : 'asset'} '
          'value=$urlOrAsset',
        );
        if (isUrl) {
          await _player.setUrl(urlOrAsset);
        } else {
          await _player.setAsset(urlOrAsset);
        }
        if (!mounted || generation != _loadGeneration) return;
        final dur = _player.duration;
        setState(() {
          if (dur != null) _duration = dur.inSeconds.toDouble();
          _position = 0.0;
          _currentLyricLineIndex = 0;
          _loadedAudioPath = path;
          _isLoading = false;
        });
        _player.play();
        debugPrint('🎧 AudioPlayerPage playback started: $_loadedAudioPath');
      } catch (e) {
        if (!mounted || generation != _loadGeneration) return;
        if (kDebugMode) print('Audio load error: $e');
        setState(() => _isLoading = false);
      }
    }

    // Determine type of path: http(s), gs:// (Firebase Storage), or local asset
    if (path.startsWith('http://') || path.startsWith('https://')) {
      debugPrint('🎧 AudioPlayerPage resolved audio source: network url');
      _setAndPlay(path, isUrl: true);
    } else if (path.startsWith('gs://')) {
      debugPrint('🎧 AudioPlayerPage resolved audio source: Firebase Storage gs://');
      FirebaseStorage.instance.refFromURL(path).getDownloadURL().then((downloadUrl) {
        debugPrint('🎧 AudioPlayerPage gs:// download URL resolved: $downloadUrl');
        _setAndPlay(downloadUrl, isUrl: true);
      }).catchError((e) {
        if (kDebugMode) print('Failed to resolve gs:// URL: $e');
        // fallback try as asset
        debugPrint('🎧 AudioPlayerPage falling back to asset load for: $path');
        _setAndPlay(path, isUrl: false);
      });
    } else {
      debugPrint('🎧 AudioPlayerPage resolved audio source: local asset');
      _setAndPlay(path, isUrl: false);
    }
  }

  void _onLanguageChanged(String newLanguage) {
    if (newLanguage == _currentLanguage) return;
    setState(() => _currentLanguage = newLanguage);
    final newPath = _activeContent.getAudioPath(newLanguage);
    if (newPath != _loadedAudioPath) {
      _player.stop();
      _loadAudio(newPath);
    }
  }

  void _seekTo(double value) {
    if (_isLoading) return;
    final clamped = value.clamp(0.0, _duration);
    _player.seek(Duration(seconds: clamped.toInt()));
    setState(() {
      _position = clamped;
      _currentLyricLineIndex = _getLyricIndex(
          _loadedAudioPath, clamped, _lyricLines.length);
    });
  }

  void _switchContent(AudioContent newContent) {
    _player.stop();
    setState(() {
      _activeContent = newContent;
      _position = 0.0;
      _currentLyricLineIndex = 0;
      if (_pageController.hasClients &&
          _pageController.page != 0) {
        _pageController.jumpToPage(0);
      }
    });
    final path = newContent.getAudioPath(_currentLanguage);
    _loadAudio(path);
  }

  void _goToPrevious() {
    final all = widget.allContent ?? _fetchedContent;
    if (all == null) return;
    final idx = all.indexOf(_activeContent);
    if (idx > 0) _switchContent(all[idx - 1]);
  }

  void _goToNext() {
    final all = widget.allContent ?? _fetchedContent;
    if (all == null) return;
    final idx = all.indexOf(_activeContent);
    if (idx < all.length - 1) _switchContent(all[idx + 1]);
  }

  VideoCardData _favoriteVideoData() {
    final title = _activeContent.getTitle(_currentLanguage).trim();
    final subtitle = _activeContent.subtitle.trim();
    return VideoCardData(
      title: title.isNotEmpty ? title : 'Audio',
      subtitle: subtitle.isNotEmpty ? subtitle : 'Audio',
      videoUrl: _activeContent.audioPath.isNotEmpty ? _activeContent.audioPath : null,
      duration: _formatTime(_duration),
      imagePlaceholder: 'miss_bibi.png',
      audioContent: _activeContent,
      titleKey: title.isNotEmpty ? title : _activeContent.audioPath,
      subtitleKey: subtitle.isNotEmpty ? subtitle : null,
      favoriteId: _activeContent.audioPath.isNotEmpty
          ? _activeContent.audioPath
          : (title.isNotEmpty ? title : _activeContent.subtitle),
    );
  }

  void _toggleFavorite() {
    context.read<FavoritesBloc>().add(ToggleFavoriteEvent(_favoriteVideoData()));
  }

  bool get _isFavorite => context
      .read<FavoritesBloc>()
      .state
      .favoriteIds
      .contains(_favoriteVideoData().favoriteId);

  bool get _hasPrevious {
    final all = widget.allContent ?? _fetchedContent;
    if (all == null) return false;
    return all.indexOf(_activeContent) > 0;
  }

  bool get _hasNext {
    final all = widget.allContent ?? _fetchedContent;
    if (all == null) return false;
    final idx = all.indexOf(_activeContent);
    return idx < all.length - 1;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _loadGeneration++;
    _pageController.dispose();
    _player.dispose();
    super.dispose();
  }

  String _formatTime(double seconds) {
    final int s = seconds.toInt();
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                  color: Color(0xFFE86A8D)),
              SizedBox(height: 16.h),
              Text(
                'Preparing audio...',
                style: TextStyle(
                    fontSize: 14.sp, color: const Color(0xFF999999)),
              ),
            ],
          ),
        ),
      );
    }

    return BlocListener<LanguageBloc, LanguageState>(
      listener: (context, state) {
        if (state is LanguageSelected)
          _onLanguageChanged(state.language);
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (!didPop) Navigator.pop(context);
        },
        child: Scaffold(
          body: SafeArea(
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              children: [
                _buildPlayScreen(),
                _buildLyricsScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Play screen ───────────────────────────────────────────────────────────

  Widget _buildPlayScreen() {
    // Check if the current animation needs a gradient
    final bool needsGradient = _activeContent.animationPath ==
        'assets/images/Bibi_Onboarding_Right.lottie';

    final bgColor = _hexToColor(_backgroundHex);
    return Container(
      color: bgColor,
      child: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: RepaintBoundary(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Center(
                    child: OnboardingAnimation(
                      key: ValueKey(_activeContent.animationPath),
                      assetPath: _activeContent.animationPath,
                      scale: _activeContent.scale,
                      translateXPercent:
                          _activeContent.offsetXPercent,
                      translateYPercent:
                          _activeContent.offsetYPercent,
                      alignment: Alignment.center,
                      repeat: true,
                    ),
                  ),

                  // Only show gradient for Bibi_Onboarding_Right.lottie
                          if (needsGradient)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: -15.h, // anchor to bottom of Stack
                              child: IgnorePointer(
                                child: Container(
                                  height: 0.20.sh,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        bgColor.withAlpha(0x00),
                                        bgColor.withAlpha(0x18),
                                        bgColor.withAlpha(0x55),
                                        bgColor.withAlpha(0xAA),
                                        bgColor.withAlpha(0xF2),
                                        bgColor.withAlpha(0xFF),
                                      ],
                                      stops: [0.0, 0.2, 0.42, 0.64, 0.84, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                ],
              ),
            ),
          ),

          _buildPlayerControls(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: _circleButton(
              child: Icon(Icons.arrow_back_ios_new,
                  color: const Color(0xFF8B5E3C), size: 16.r),
            ),
          ),

          Text(
            _tr(_currentLanguage, 'now_playing'),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF333333),
              letterSpacing: 1.2,
            ),
          ),

          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, favoritesState) {
              final isFavorite = favoritesState.favoriteIds.contains(_favoriteVideoData().favoriteId);
              return _favoriteCircleButton(
                isFavorite: isFavorite,
                onTap: _toggleFavorite,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatTime(_position),
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF999999),
                      fontWeight: FontWeight.w500)),
              Text(_formatTime(_duration),
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF999999),
                      fontWeight: FontWeight.w500)),
            ],
          ),

          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4.h,
              thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: 8.r),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: _position.clamp(0.0, _duration),
              min: 0.0,
              max: _duration,
              activeColor: const Color(0xFFE86A8D),
              inactiveColor: const Color(0xFFFFD5E0),
              onChanged:
                  _isLoading ? null : (value) => _seekTo(value),
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            _activeContent.getTitle(_currentLanguage),
            textAlign: TextAlign.center,
            textDirection:
                _currentLanguage == 'Urdu'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
            style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF333333)),
          ),
          SizedBox(height: 4.h),

          Text(
            _tr(_currentLanguage, 'bibi'),
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF999999),
                letterSpacing: 1.2),
          ),

          SizedBox(height: 20.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _hasPrevious ? _goToPrevious : null,
                child: Icon(Icons.skip_previous_rounded,
                    color: _hasPrevious
                        ? const Color(0xFFE86A8D)
                        : const Color(0xFFE86A8D).withOpacity(0.3),
                    size: 36.r),
              ),

              SizedBox(width: 16.w),

              GestureDetector(
                onTap: _isLoading
                    ? null
                    : () => _seekTo(_position - 15),
                child: Icon(Icons.fast_rewind_rounded,
                    color: _isLoading
                        ? const Color(0xFFE86A8D).withOpacity(0.4)
                        : const Color(0xFFE86A8D),
                    size: 38.r),
              ),

              SizedBox(width: 20.w),

              GestureDetector(
                onTap: _isLoading
                    ? null
                    : () {
                        if (_player.playing) {
                          _player.pause();
                        } else {
                          _player.play();
                        }
                      },
                child: Container(
                  width: 68.r,
                  height: 68.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isLoading
                        ? const Color(0xFFE86A8D).withOpacity(0.5)
                        : const Color(0xFFE86A8D),
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromARGB(89, 232, 106, 141),
                          blurRadius: 20,
                          offset: Offset(0, 8))
                    ],
                  ),
                  child: _isLoading
                      ? Padding(
                          padding: EdgeInsets.all(20.r),
                          child: const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Icon(
                          _isPlaying
                              ? Icons.pause
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 36.r),
                ),
              ),

              SizedBox(width: 20.w),

              GestureDetector(
                onTap: _isLoading
                    ? null
                    : () => _seekTo(_position + 15),
                child: Icon(Icons.fast_forward_rounded,
                    color: _isLoading
                        ? const Color(0xFFE86A8D).withOpacity(0.4)
                        : const Color(0xFFE86A8D),
                    size: 38.r),
              ),

              SizedBox(width: 16.w),

              GestureDetector(
                onTap: _hasNext ? _goToNext : null,
                child: Icon(Icons.skip_next_rounded,
                    color: _hasNext
                        ? const Color(0xFFE86A8D)
                        : const Color(0xFFE86A8D).withOpacity(0.3),
                    size: 36.r),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          GestureDetector(
            onTap: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut),
            child: Column(
              children: [
                Icon(Icons.keyboard_arrow_up,
                    color: const Color(0xFFE86A8D), size: 22.r),
                Text(
                  _tr(_currentLanguage, 'lyrics'),
                  style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF999999),
                      letterSpacing: 1.2),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  // ── Lyrics screen ─────────────────────────────────────────────────────────

  Widget _buildLyricsScreen() {
    final lines = _lyricLines;
    final isRtl = _currentLanguage == 'Urdu';

    return Container(
      color: const Color(0xFFFFF5F5),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut),
                  child: _circleButton(
                      child: Icon(Icons.keyboard_arrow_down,
                          color: const Color(0xFF8B5E3C),
                          size: 20.r)),
                ),
                Text(
                  _tr(_currentLanguage, 'now_learning'),
                  style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF333333),
                      letterSpacing: 1.2),
                ),
                BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, favoritesState) {
                    final isFavorite = favoritesState.favoriteIds.contains(_favoriteVideoData().favoriteId);
                    return _favoriteCircleButton(
                      isFavorite: isFavorite,
                      onTap: _toggleFavorite,
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              _activeContent.getTitle(_currentLanguage),
              textAlign: TextAlign.center,
              textDirection:
                  isRtl ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE86A8D)),
            ),
          ),

          SizedBox(height: 20.h),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                  horizontal: 28.w, vertical: 8.h),
              itemCount: lines.length,
              itemBuilder: (context, index) {
                final bool isActive =
                    index == _currentLyricLineIndex;
                final bool isPast =
                    index < _currentLyricLineIndex;
                final Color lineColor = isActive
                    ? const Color(0xFFE86A8D)
                    : isPast
                        ? const Color(0xFFE86A8D).withOpacity(0.3)
                        : const Color(0xFFCCCCCC);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.symmetric(
                      vertical: isActive ? 10.h : 5.h),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                        fontSize: isActive ? 17.sp : 13.sp,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: lineColor,
                        height: 1.7),
                    child: Text(lines[index],
                        textAlign: TextAlign.center,
                        textDirection: isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 28.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _pageController.previousPage(
                          duration:
                              const Duration(milliseconds: 300),
                          curve: Curves.easeInOut),
                      child: Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFD5E0))),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE86A8D))),
                  ],
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut),
                  child: Container(
                    width: 64.r,
                    height: 64.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE86A8D),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFFE86A8D)
                                .withOpacity(0.35),
                            blurRadius: 16.r,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 32.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required Widget child}) {
    return Container(
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6.r,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  Widget _favoriteCircleButton({
    required bool isFavorite,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6.r,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? const Color(0xFFE86A8D) : const Color(0xFFE86A8D),
          size: 20.r,
        ),
      ),
    );
  }
}

// ── Audio Content Instances ───────────────────────────────────────────────────

const audioContent1 = AudioContent(
  title: 'What is Breast Cancer?',
  urduTitle: 'چھاتی کا کینسر کیا ہے؟',
  romanUrduTitle: 'Chhaati ka Cancer kya hai?',
  subtitle: 'Understanding the basics',
  audioPath: 'assets/audio/whatisbreastcancer.mp3',
  urduAudioPath: 'assets/audio/whatisbreastcancer_urdu.m4a',
  animationPath:
      'assets/images/Cancer Cell Animation from Bibi Project (1).lottie',
  scale: 1.9,
  offsetXPercent: 0.015,
  offsetYPercent: -0.02,
  urduLyrics: [
    'چھاتی کا کینسر تب ہوتا ہے جب جسم کے خلیات بڑھنے لگتے ہیں۔',
    'یہ کسی بھی عمر کی خواتین اور کبھی کبار مردوں کو بھی ہو سکتا ہے۔',
    'پاکستان میں ہر نو میں سے ایک خاتون کو زندگی میں اس کا سامنا کرنا پڑتا ہے۔',
    'لیکن یاد رکھیں، وقت پر تشخیص زندگی کو بچا سکتی ہے۔',
  ],
  romanUrduLyrics: [
    'Chhaati ka cancer tab hota hai jab jism ke khaliaat barhne lagte hain.',
    'Yeh kisi bhi umr ki khawateen aur kabhi kabhar mardon ko bhi ho sakta hai.',
    'Pakistan mein har nau mein se aik khatoon ko zindagi mein is ka samna karna parta hai.',
    'Lekin yaad rakhein, waqt par tashkhees zindagi ko bacha sakti hai.',
  ],
  englishLyrics: [
    'Breast cancer happens when',
    'cells in the breast start growing',
    'abnormally. It can happen to women',
    '-and sometimes men- of any age',
    'In Pakistan one in nine women',
    'may face it in their lifetime.',
    'But remember early detection can save lives.',
  ],
);

const audioContent2 = AudioContent(
  title: 'Are you at Risk?',
  urduTitle: 'کیا آپ کو خطرہ ہے؟',
  romanUrduTitle: 'Kya aap ko khatra hai?',
  subtitle: 'When an abnormality is found',
  audioPath: 'assets/audio/risk.mp3',
  scale: 1.9,
  offsetXPercent: 0.015,
  offsetYPercent: -0.02,
  urduAudioPath: 'assets/audio/risk_urdu.m4a',
  animationPath: 'assets/images/family_tree.lottie',
  urduLyrics: [
    'اگر آپ کے خاندان میں کسی کو یہ کینسر ہو رہا ہو، آپ کی عمر چالیس سال سے زیادہ ہو',
    'یا آپ کی زندگی میں ورزش کی کمی ہو تو خطرہ بڑھ سکتا ہے۔',
    'آئیے آپ کے خطرے کا جائزہ لیتے ہیں، اس میں صرف ایک منٹ لگے گا۔',
  ],
  romanUrduLyrics: [
    'Agar aap ke khandan mein kisi ko yeh cancer ho, aap ki umr chalees saal se zyada ho,',
    'ya aap ki zindagi mein warzish ki kami ho to khatra barh sakta hai.',
    'Aaiye aap ke khatray ka jaiza letay hain — is mein sirf aik minute lagay ga.',
  ],
  englishLyrics: [
    'You may be at higher risk if someone',
    'in your family had breast cancer, if you\'re',
    'over forty, or if you live a less active lifestyle.',
    'Let\'s check your risk—it only takes a minute!',
  ],
);

const audioContent3 = AudioContent(
  title: 'Preventive Screening',
  urduTitle: 'احتیاطی اسکریننگ',
  romanUrduTitle: 'Ehtiyati Screening',
  scale: 2.5,
  offsetXPercent: 0.015,
  offsetYPercent: -0.02,
  subtitle: 'Understanding preventive screening',
  audioPath: 'assets/audio/screen.m4a',
  urduAudioPath: 'assets/audio/screen_urdu.m4a',
  animationPath: 'assets/images/mammogram.lottie',
  urduLyrics: [
    'چھاتی کے کینسر کا علاج ممکن ہے، اگر یہ جلد معلوم ہو جائے',
    'ہر عورت کو اپنے جسم سے واقف ہونا چاہیے',
    'ہر ماہ مہواری ختم ہونے کے 7 سے 10 دن بعد اپنا معائنہ خود کریں',
    'چالیس سال سے اوپر کی خواتین کے لیے سال میں ایک بار میموگرافی ضروری ہے',
  ],
  romanUrduLyrics: [
    'Chhaati ke cancer ka ilaaj mumkin hai, agar yeh jald maloom ho jaaye.',
    'Har aurat ko apne jism se waqif hona chahiye.',
    'Har maah mahwari khatam honay ke 7 se 10 din baad apna muaaina khud karein.',
    'Chalees saal se upar ki khawateen ke liye saal mein aik baar mammography zaroori hai.',
  ],
  englishLyrics: [
    'Breast cancer can be treated—if it\'s found',
    'early. Every woman should know her body.',
    'Start by checking yourself once a month, seven to ten',
    'days after your period ends. For women over',
    'forty, a mammogram once a year is essential.',
    'Screening doesn\'t mean you\'re sick; it means you\'re strong.',
  ],
);

const audioContent4 = AudioContent(
  title: 'How to Treat?',
  urduTitle: 'علاج کیسے کریں؟',
  romanUrduTitle: 'Ilaaj kaise karein?',
  scale: 1.9,
  offsetXPercent: 0.015,
  offsetYPercent: -0.02,
  subtitle: 'Care options after detection',
  audioPath: 'assets/audio/treat.mp3',
  urduAudioPath: 'assets/audio/treat_urdu.mp3',
  animationPath: 'assets/images/chemotherapy.lottie',
  urduLyrics: [
    'جب مجھے بتایا گیا کہ مجھے کینسر ہے تو میں ڈر گئی تھی لیکن علاج اثر کرتا ہے',
    'میری کیموتھراپی، سرجری اور ریڈیئیشن ہوئی۔ یہ ہمیشہ آسان نہیں تھا',
    'میرے بال جھڑ گئے اور میں تھکاوٹ محسوس کرتی تھی',
    'لیکن اس سے رسولی ختم ہوئی اور الحمدللہ میری جان بچ گئی',
  ],
  romanUrduLyrics: [
    'Jab mujhe bataya gaya ke mujhe cancer hai to mein dar gayi thi, lekin ilaaj asar karta hai.',
    'Meri chemotherapy, surgery aur radiation hui. Yeh hamesha aasaan nahi tha.',
    'Mere baal jharh gaye aur mein thakawat mehsoos karti thi.',
    'Lekin is se rasoli khatam hui aur Alhamdulillah meri jaan bach gayi.',
  ],
  englishLyrics: [
    'When I was told I had cancer, I was afraid.',
    'But treatment works — I had chemotherapy, surgery, and radiation.',
    ' It wasn\'t always easy —I lost my hair and felt tired—',
    ' but it shrank the tumor and saved my life.',
  ],
);

const audioContent5 = AudioContent(
  title: 'How to Confirm?',
  urduTitle: 'تصدیق کیسے کریں؟',
  romanUrduTitle: 'Tasdeeq kaise karein?',
  subtitle: 'Tests and checks to know for sure',
  scale: 1.9,
  offsetXPercent: 0.018,
  offsetYPercent: -0.02,
  audioPath: 'assets/audio/biopsy.m4a',
  urduAudioPath: 'assets/audio/how_to_confirm_urdu.m4a',
  animationPath: 'assets/images/ultrasound.lottie',
  urduLyrics: [
    'اگر آپ کو کچھ غیر معمولی لگے تو گھبرائیں نہیں۔',
    'بائیوپسی معلومات دیتی ہے — یہ موت کا پروانہ نہیں ہے۔',
    'بہت سے لوگ سمجھتے ہیں کہ بائیوپسی سے کینسر پھیلتا ہے۔',
    'یہ بالکل غلط ہے — یہ صحیح علاج شروع کرنے کا ایک محفوظ طریقہ ہے۔',
  ],
  romanUrduLyrics: [
    'Agar aap ko kuch ghair mamool lagay to ghabrayein nahi.',
    'Biopsy maloomat deti hai — yeh maut ka parwana nahi hai.',
    'Bohot se log samajhte hain ke biopsy se cancer phailta hai.',
    'Yeh bilkul ghalat hai — yeh sahih ilaaj shuru karne ka aik mehfooz tareeqa hai.',
  ],
  englishLyrics: [
    'If you find something, don\'t panic. A biopsy',
    'gives answers, not a death sentence. Many people',
    'believe a biopsy spreads cancer — that is a myth!',
    'It is a safe way to get the right treatment started.',
  ],
);

const audioContent6 = AudioContent(
  title: 'How to Prevent?',
  urduTitle: 'بچاؤ کیسے کریں؟',
  romanUrduTitle: 'Bachao kaise karein?',
  subtitle: 'Simple steps to lower the risk',
  audioPath: 'assets/audio/prevent.m4a',
  scale: 2.9,
  offsetXPercent: 0.015,
  offsetYPercent: -0.02,
  urduAudioPath: 'assets/audio/how_to_prevent_urdu.m4a',
  animationPath: 'assets/images/Bibi_Onboarding_Right.lottie',
  urduLyrics: [
    'اچھی غذا اور متحرک رہنا خطرے کو کم کر سکتا ہے۔',
    'سبزیوں، پھلوں اور دالوں کا استعمال زیادہ کریں۔',
    'تلی ہوئی چیزوں سے پرہیز کریں اور روزانہ سیر کی عادت ڈالیں،',
    'چاہے وہ گھر میں ہو یا کسی قریبی پارک میں۔',
  ],
  romanUrduLyrics: [
    'Achi ghaza aur mutaharrik rehna khatray ko kam kar sakta hai.',
    'Sabziyon, phalon aur dalon ka istemaal zyada karein.',
    'Tali hui cheezon se parhez karein aur rozana sair ki aadat dalein,',
    'chahay woh ghar mein ho ya kisi qareeb park mein.',
  ],
  englishLyrics: [
    'Healthy eating and staying active can reduce your risk.',
    'Eat more vegetables, fruits, and whole grains.',
    'Avoid oily foods and try to walk daily,',
    'even if it\'s just in your home or a nearby park.',
  ],
);

const audioContent7 = AudioContent(
  title: 'How to Support?',
  urduTitle: 'مدد کیسے کریں؟',
  romanUrduTitle: 'Madad kaise karein?',
  scale: 2.9,
  offsetXPercent: 0.015,
  offsetYPercent: -0.02,
  subtitle: 'Ways to help with care and comfort',
  audioPath: 'assets/audio/support.mp3',
  urduAudioPath: 'assets/audio/support_urdu.m4a',
  animationPath: 'assets/images/Bibi_Onboarding_Right.lottie',
  urduLyrics: [
    'اگر آپ کی جان پہچان میں کوئی اس بیماری سے لڑ رہا ہے تو اس کا ساتھ دیں۔',
    'آپ کو بڑے بڑے الفاظ کی ضرورت نہیں، ایک مسکراہٹ، چائے کا کپ یا صرف بات سن لینا ہی کافی ہے۔',
    'ہم سب مل کر ایک دوسرے کو حمت اور امید دے سکتے ہیں۔',
    'یہ ایپ ہر اس خاتون کے ساتھ شیئر کریں جس سے آپ پیار کرتے ہیں۔',
  ],
  romanUrduLyrics: [
    'Agar aap ki jaan pehchan mein koi is bimari se larh raha hai to us ka saath dein.',
    'Aap ko baray baray alfaaz ki zaroorat nahi — aik muskurahat, chaay ka cup ya sirf baat sun lena hi kaafi hai.',
    'Hum sab mil kar aik doosray ko himmat aur umeed de saktay hain.',
    'Yeh app har us khatoon ke saath share karein jis se aap pyaar kartay hain.',
  ],
  englishLyrics: [
    'If someone you know is fighting cancer, be there for her.',
    'You don\'t need big words—a smile, a cup of tea, or just listening is enough.',
    'Together, we can give hope and the strength to heal.',
    'Share this app with every woman you love.',
  ],
);

const List<AudioContent> allAudioContent = [
  audioContent1,
  audioContent2,
  audioContent3,
  audioContent4,
  audioContent5,
  audioContent6,
  audioContent7,
];