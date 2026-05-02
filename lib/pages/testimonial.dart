import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import '../services/remote_asset_service.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class TestimonialData {
  final String id;
  final Map<String, dynamic> text; // Map with English, Roman Urdu, اردو keys
  final String audioPath; // gs:// path
  final String urduAudioPath; // gs:// path
  final Color avatarColor;
  final int order;

  TestimonialData({
    required this.id,
    required this.text,
    required this.audioPath,
    required this.urduAudioPath,
    required this.avatarColor,
    required this.order,
  });


  String getText(String language) {
    // Map language names to Firebase keys
    String firebaseKey = 'English';
    if (language == 'Urdu') {
      firebaseKey = 'اردو';
    } else if (language == 'Roman Urdu') {
      firebaseKey = 'Roman Urdu';
    }
    
    if (text.containsKey(firebaseKey)) {
      return text[firebaseKey] as String? ?? '';
    }
    return text['English'] as String? ?? '';
  }

  String getAudioPath(String language) {
    if ((language == 'Urdu' || language == 'Roman Urdu') && urduAudioPath.isNotEmpty) {
      return urduAudioPath;
    }
    return audioPath;
  }

  factory TestimonialData.fromFirestore(Map<String, dynamic> data) {
    debugPrint('🔨 TestimonialData.fromFirestore parsing:');
    debugPrint('   id: ${data['id']}');
    debugPrint('   audioPath: ${data['audioPath']}');
    debugPrint('   urduAudioPath: ${data['urduAudioPath']}');
    debugPrint('   text keys: ${(data['text'] as Map?)?.keys.toList()}');
    
    // Parse color
    Color parsedColor = const Color(0xFFE86A8D);
    try {
      final colorStr = data['avatarColor'] as String?;
      if (colorStr != null && colorStr.isNotEmpty) {
        parsedColor = Color(int.parse(colorStr.replaceFirst('#', '0xff')));
        debugPrint('   ✅ Color parsed: $colorStr → 0x${parsedColor.value.toRadixString(16)}');
      }
    } catch (e) {
      debugPrint('   ⚠️ Color parse failed: ${data['avatarColor']} - $e');
    }

    return TestimonialData(
      id: data['id'] as String? ?? '',
      text: (data['text'] as Map<String, dynamic>?) ?? {},
      audioPath: data['audioPath'] as String? ?? '',
      urduAudioPath: data['urduAudioPath'] as String? ?? '',
      avatarColor: parsedColor,
      order: data['order'] as int? ?? 0,
    );
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────

class TestimonialsPage extends StatefulWidget {
  const TestimonialsPage({super.key});

  @override
  State<TestimonialsPage> createState() => _TestimonialsPageState();
}

class _TestimonialsPageState extends State<TestimonialsPage> {
  // One player per card — indexed by testimonial id
  final Map<String, AudioPlayer> _players = {};
  final Map<String, bool> _isPlaying = {};
  final Map<String, bool> _isLoading = {};
  final Map<String, double> _positions = {};
  final Map<String, double> _durations = {};

  // Only one card plays at a time
  String? _activeId;

  String _currentLanguage = 'English';
  
  late Future<List<TestimonialData>> _testimonialsFuture;

  @override
  void initState() {
    super.initState();
    debugPrint('🎤 TestimonialsPage initState - loading from Firebase');
    _testimonialsFuture = _loadTestimonialsFromFirebase();
  }

  Future<List<TestimonialData>> _loadTestimonialsFromFirebase() async {
    try {
      debugPrint('📂 Fetching testimonials from Firebase...');
      debugPrint('   Path: app_config/testimonials/items');
      
      final snapshot = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('testimonials')
          .collection('items')
          .orderBy('order', descending: false)
          .get();

      debugPrint('📦 Retrieved ${snapshot.docs.length} documents from Firestore');

      final testimonials = snapshot.docs.map((doc) {
        debugPrint('\n🔍 Processing document: ${doc.id}');
        final data = doc.data();
        debugPrint('   Raw data: $data');
        return TestimonialData.fromFirestore(data);
      }).toList();

      debugPrint('\n✅ Successfully loaded ${testimonials.length} testimonials from Firebase');
      for (final t in testimonials) {
        debugPrint('   - ${t.id}:  | audioPath: ${t.audioPath.substring(0, (t.audioPath.length > 60 ? 60 : t.audioPath.length))}...');
      }

      return testimonials;
    } catch (e, st) {
      debugPrint('❌ Error loading testimonials from Firebase: $e');
      debugPrint('   Stack: $st');
      rethrow;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<LanguageBloc>().state;
    if (state is LanguageSelected) {
      _currentLanguage = state.language;
    }
  }

  // Lazily creates a player for id and loads its audio from Firebase
  Future<AudioPlayer> _getOrCreatePlayer(String id, String audioPath) async {
    if (_players.containsKey(id)) {
      debugPrint('🔄 Player exists for $id, reusing');
      return _players[id]!;
    }

    debugPrint('🎵 Creating new AudioPlayer for $id');
    final player = AudioPlayer();
    _players[id] = player;

    player.playingStream.listen((playing) {
      if (!mounted) return;
      debugPrint('🎵 playingStream: $id → playing=$playing');
      setState(() => _isPlaying[id] = playing);
    });

    player.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() => _positions[id] = pos.inMilliseconds / 1000.0);
    });

    player.playerStateStream.listen((state) {
      if (!mounted) return;
      debugPrint('🎵 playerStateStream: $id → processingState=${state.processingState}');
      if (state.processingState == ProcessingState.completed) {
        debugPrint('✅ Audio completed for $id');
        setState(() {
          _isPlaying[id] = false;
          _positions[id] = 0.0;
          _activeId = null;
        });
        player.seek(Duration.zero);
      }
    });

    return player;
  }

  Future<void> _togglePlay(String id, String audioPath) async {
    debugPrint('\n▶️ _togglePlay called for $id');
    debugPrint('   audioPath from Firestore: $audioPath');

    // Pause any currently playing card
    if (_activeId != null && _activeId != id) {
      debugPrint('⏹️ Stopping previous player: $_activeId');
      final prev = _players[_activeId!];
      await prev?.pause();
      setState(() {
        _isPlaying[_activeId!] = false;
      });
    }

    final player = await _getOrCreatePlayer(id, audioPath);

    // Load audio if not yet loaded for this player
    if (player.duration == null) {
      debugPrint('📍 Loading audio into player for $id');
      setState(() => _isLoading[id] = true);
      try {
        // Check if it's a Firebase path (gs://)
        if (audioPath.startsWith('gs://')) {
          debugPrint('🌐 Detected Firebase path, resolving to HTTPS URL');
          debugPrint('   Input: $audioPath');
          
          final resolvedUrl = await RemoteAssetService.resolveDownloadUrl(audioPath);
          debugPrint('   ✅ Resolved URL: $resolvedUrl');
          
          debugPrint('📍 Setting resolved URL in AudioPlayer');
          await player.setUrl(resolvedUrl);
          debugPrint('✅ URL set successfully');
        } else {
          debugPrint('⚠️ WARNING: audioPath does NOT start with gs:// - treating as local asset');
          debugPrint('   Path: $audioPath');
          await player.setAsset(audioPath);
        }

        final dur = player.duration;
        if (mounted) {
          setState(() {
            _durations[id] = dur?.inMilliseconds != null
                ? dur!.inMilliseconds / 1000.0
                : 0.0;
            _isLoading[id] = false;
          });
          debugPrint('✅ Audio loaded, duration: ${_durations[id]}s');
        }
      } catch (e, st) {
        debugPrint('❌ Error loading audio for $id: $e');
        debugPrint('   Type: ${e.runtimeType}');
        debugPrint('   Stack: $st');
        if (mounted) {
          setState(() => _isLoading[id] = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
        return;
      }
    }

    // Play or pause
    if (player.playing) {
      debugPrint('⏸️ Pausing player');
      await player.pause();
      setState(() => _activeId = null);
    } else {
      debugPrint('▶️ Starting playback');
      await player.play();
      setState(() => _activeId = id);
    }
  }

  void _onLanguageChanged(String lang) {
    if (lang == _currentLanguage) return;
    debugPrint('🌐 Language changed: $_currentLanguage → $lang');
    // Stop all players on language switch — new audio paths
    for (final entry in _players.entries) {
      entry.value.stop();
      entry.value.dispose();
    }
    _players.clear();
    setState(() {
      _currentLanguage = lang;
      _activeId = null;
      _isPlaying.clear();
      _isLoading.clear();
      _positions.clear();
      _durations.clear();
    });
  }

  @override
  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LanguageBloc, LanguageState>(
      listener: (context, state) {
        if (state is LanguageSelected) _onLanguageChanged(state.language);
      },
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          String currentLanguage = 'English';
          if (state is LanguageSelected) {
            currentLanguage = state.language;
            _currentLanguage = currentLanguage;
          }

          return FutureBuilder<List<TestimonialData>>(
            future: _testimonialsFuture,
            builder: (context, snapshot) {
              debugPrint('🏗️ build() - FutureBuilder state: ${snapshot.connectionState}');

              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen();
              }

              if (snapshot.hasError) {
                debugPrint('❌ FutureBuilder error: ${snapshot.error}');
                return _buildErrorScreen('Error loading testimonials: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                debugPrint('❌ No testimonials data');
                return _buildErrorScreen('No testimonials available');
              }

              final testimonials = snapshot.data!;
              debugPrint('✅ Building page with ${testimonials.length} testimonials');

              final testimonialsTitle = LanguageStrings.getTranslation(
                currentLanguage,
                'testimonials',
              );

              return Scaffold(
                backgroundColor: const Color(0xFFFFF5F5),
                body: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(testimonialsTitle),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                          itemCount: testimonials.length,
                          itemBuilder: (context, i) =>
                              _buildCard(testimonials[i], currentLanguage),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFFE86A8D),
            strokeWidth: 2.5.w,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.r, color: const Color(0xFFE86A8D)),
                SizedBox(height: 16.h),
                Text('Error', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 8.h),
                Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  color: const Color(0xFF8B5E3C), size: 15.sp),
            ),
          ),
          SizedBox(width: 14.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(TestimonialData t, String currentLanguage) {
    final isRtl = currentLanguage == 'اردو';
    final playing = _isPlaying[t.id] ?? false;
    final loading = _isLoading[t.id] ?? false;
    final position = _positions[t.id] ?? 0.0;
    final duration = _durations[t.id] ?? 0.0;
    final audioPath = t.getAudioPath(currentLanguage);

    debugPrint('🎬 Building card for ${t.id}:');
    debugPrint('   language: $currentLanguage');
    debugPrint('   audioPath: $audioPath');

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top section: review text ──────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Column(
              crossAxisAlignment: isRtl
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  t.getText(currentLanguage),
                  textDirection:
                      isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF555555),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),

          // ── Audio player card (pink) ───────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            decoration: BoxDecoration(
              color: const Color(0xFFE86A8D),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            child: Row(
              children: [
                // Avatar circle
                Container(
                  width: 42.w,
                  height: 42.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.25),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ),
                ),

                SizedBox(width: 10.w),

                // Name + waveform
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWaveformScrubber(t.id, position, duration, playing),
                    ],
                  ),
                ),

                SizedBox(width: 10.w),

                // Play/pause button
                GestureDetector(
                  onTap: () => _togglePlay(t.id, audioPath),
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                    ),
                    child: loading
                        ? Padding(
                            padding: EdgeInsets.all(10.w),
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 24.sp,
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

  Widget _buildWaveformScrubber(
      String id, double position, double duration, bool playing) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null || duration <= 0) return;
        // rough seek based on drag delta
        final player = _players[id];
        if (player == null) return;
        final pct = details.delta.dx / box.size.width;
        final newPos =
            (position + pct * duration).clamp(0.0, duration);
        player.seek(
            Duration(milliseconds: (newPos * 1000).toInt()));
      },
      child: SizedBox(
        height: 28.h,
        child: CustomPaint(
          painter: _WaveformPainter(
            progress: duration > 0 ? (position / duration).clamp(0.0, 1.0) : 0.0,
            isPlaying: playing,
            seed: id.hashCode,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

// ── Waveform painter ──────────────────────────────────────────────────────────

class _WaveformPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;
  final int seed;

  _WaveformPainter({
    required this.progress,
    required this.isPlaying,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 30;
    final barWidth = (size.width - barCount * 2) / barCount;
    final rng = math.Random(seed * 17 + 3);

    // Pre-generate bar heights so they're stable across repaints
    final heights = List.generate(
        barCount, (_) => 0.25 + rng.nextDouble() * 0.75);

    final playedPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final unplayedPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    for (int j = 0; j < barCount; j++) {
      final fraction = j / barCount;
      final barH = heights[j] * size.height;
      final x = j * (barWidth + 2);
      final y = (size.height - barH) / 2;

      final paint = fraction <= progress ? playedPaint : unplayedPaint;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barH),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress || old.isPlaying != isPlaying;
}