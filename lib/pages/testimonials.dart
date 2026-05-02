import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import '../services/remote_asset_service.dart';
import 'dashboard.dart';

class TestimonialsPage extends StatefulWidget {
  const TestimonialsPage({super.key});

  @override
  State<TestimonialsPage> createState() => _TestimonialsPageState();
}

class _TestimonialsPageState extends State<TestimonialsPage> {
  late Future<Map<String, dynamic>> _configFuture;
  late Future<List<TestimonialData>> _testimonialsFuture;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingTestimonialId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    debugPrint("🎤 TestimonialsPage initState");
    _configFuture = _loadConfig();
    _testimonialsFuture = _loadTestimonials();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _loadConfig() async {
    try {
      debugPrint("📂 TestimonialsPage: Loading config from app_config/testimonials");
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('testimonials')
          .get();

      if (!doc.exists) {
        debugPrint("❌ TestimonialsPage: Config document not found");
        throw Exception('Testimonials config not found');
      }

      final data = doc.data();
      if (data == null) {
        debugPrint("❌ TestimonialsPage: Config document is empty");
        throw Exception('Testimonials config is empty');
      }

      debugPrint("✅ TestimonialsPage: Config loaded");
      debugPrint("   - backgroundColor: ${data['backgroundColor']}");
      debugPrint("   - audioPlayer config: ${data['audioPlayer'] != null}");
      return data;
    } catch (e, st) {
      debugPrint("❌ TestimonialsPage _loadConfig error: $e");
      debugPrint("   Stack: $st");
      rethrow;
    }
  }

  Future<List<TestimonialData>> _loadTestimonials() async {
    try {
      debugPrint("📂 TestimonialsPage: Loading testimonials from items subcollection");
      final snapshot = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('testimonials')
          .collection('items')
          .orderBy('order', descending: false)
          .get();

      final testimonials = snapshot.docs
          .map((doc) => TestimonialData.fromFirestore(doc.data()))
          .toList();

      debugPrint("✅ TestimonialsPage: Loaded ${testimonials.length} testimonials");
      for (final t in testimonials) {
        debugPrint("   - ${t.id}: ${t.name} (order=${t.order})");
      }
      return testimonials;
    } catch (e, st) {
      debugPrint("❌ TestimonialsPage _loadTestimonials error: $e");
      debugPrint("   Stack: $st");
      rethrow;
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

  Future<void> _playAudio({
    required String audioPath,
    required String testimonialId,
  }) async {
    try {
      if (_playingTestimonialId == testimonialId) {
        // Toggle play/pause
        if (_audioPlayer.playing) {
          await _audioPlayer.pause();
          debugPrint("⏸️ Paused audio: $testimonialId");
        } else {
          await _audioPlayer.play();
          debugPrint("▶️ Resumed audio: $testimonialId");
        }
        return;
      }

      // Stop current and play new
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }

      setState(() {
        _isLoading = true;
        _playingTestimonialId = testimonialId;
      });

      debugPrint("🎵 Resolving audio URL: $audioPath");
      final resolvedUrl = await RemoteAssetService.resolveDownloadUrl(audioPath);
      debugPrint("✅ Resolved audio URL: $resolvedUrl");

      await _audioPlayer.setUrl(resolvedUrl);
      await _audioPlayer.play();

      setState(() {
        _isLoading = false;
      });

      debugPrint("▶️ Playing audio: $testimonialId");

      // Listen for completion
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            _playingTestimonialId = null;
          });
          debugPrint("✅ Audio completed: $testimonialId");
        }
      });
    } catch (e, st) {
      debugPrint("❌ Error playing audio: $e");
      debugPrint("   Stack: $st");
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  Color _parseColor(dynamic value, Color fallback) {
    if (value == null) return fallback;
    final hex = value.toString();
    if (hex.isEmpty) return fallback;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (e) {
      debugPrint("⚠️ Failed to parse color: $hex");
      return fallback;
    }
  }

  FontWeight _parseFontWeight(dynamic value, [FontWeight fallback = FontWeight.w400]) {
    switch (value?.toString().toLowerCase()) {
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
      case 'normal':
        return FontWeight.w400;
      case 'w500':
      case 'medium':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
      case 'bold':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      default:
        return fallback;
    }
  }

  double _parseDouble(dynamic value, [double fallback = 0.0]) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  int _parseInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🏗️ TestimonialsPage build");
    
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        String currentLanguage = 'English';
        if (languageState is LanguageSelected) {
          currentLanguage = languageState.language;
        }
        debugPrint("🌐 TestimonialsPage: language=$currentLanguage");

        return FutureBuilder<Map<String, dynamic>>(
          future: _configFuture,
          builder: (context, configSnapshot) {
            if (configSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScreen();
            }
            if (configSnapshot.hasError) {
              return _buildErrorScreen("Failed to load config: ${configSnapshot.error}");
            }
            if (!configSnapshot.hasData) {
              return _buildErrorScreen("No config data");
            }

            final config = configSnapshot.data!;

            return FutureBuilder<List<TestimonialData>>(
              future: _testimonialsFuture,
              builder: (context, testimonialsSnapshot) {
                if (testimonialsSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingScreen();
                }
                if (testimonialsSnapshot.hasError) {
                  return _buildErrorScreen("Failed to load testimonials: ${testimonialsSnapshot.error}");
                }
                if (!testimonialsSnapshot.hasData || testimonialsSnapshot.data!.isEmpty) {
                  return _buildErrorScreen("No testimonials available");
                }

                final testimonials = testimonialsSnapshot.data!;

                return _buildPage(
                  context: context,
                  config: config,
                  testimonials: testimonials,
                  currentLanguage: currentLanguage,
                );
              },
            );
          },
        );
      },
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
                Icon(
                  Icons.error_outline,
                  size: 48.r,
                  color: const Color(0xFFE86A8D),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Error',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required BuildContext context,
    required Map<String, dynamic> config,
    required List<TestimonialData> testimonials,
    required String currentLanguage,
  }) {
    try {
      final backgroundColor = _parseColor(config['backgroundColor'], const Color(0xFFFFF5F5));
      final topBar = _asMap(config['topBar']);
      final testimonialCard = _asMap(config['testimonialCard']);
      final audioPlayer = _asMap(config['audioPlayer']);
      final translations = _asMap(_asMap(config['translations'])['testimonials']);

      final appBarTitle = translations[_languageKey(currentLanguage)] as String? ??
          translations['English'] as String? ??
          'Testimonials';

      return Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar with back button
              _buildTopBar(
                context: context,
                topBar: topBar,
                title: appBarTitle,
              ),
              // Testimonials list
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _parseDouble(topBar['horizontalPadding'], 16).w,
                      vertical: _parseDouble(topBar['verticalPadding'], 16).h,
                    ),
                    child: Column(
                      children: testimonials
                          .map((testimonial) => _buildTestimonialCard(
                                testimonial: testimonial,
                                cardConfig: testimonialCard,
                                audioPlayerConfig: audioPlayer,
                                currentLanguage: currentLanguage,
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e, st) {
      debugPrint("❌ TestimonialsPage _buildPage error: $e");
      debugPrint("   Stack: $st");
      return _buildErrorScreen("Error building page: $e");
    }
  }

  Widget _buildTopBar({
    required BuildContext context,
    required Map<String, dynamic> topBar,
    required String title,
  }) {
    final backButton = _asMap(topBar['backButton']);
    final backSize = _parseDouble(backButton['size'], 36);
    const backIconSize = 15;
    final backIconColor = _parseColor(backButton['iconColor'], const Color(0xFF8B5E3C));

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _parseDouble(topBar['horizontalPadding'], 16).w,
        vertical: _parseDouble(topBar['verticalPadding'], 16).h,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: backSize.r,
              height: backSize.r,
              decoration: BoxDecoration(
                color: _parseColor(backButton['backgroundColor'], Colors.white),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _parseColor(backButton['shadowColor'], const Color(0x14000000)),
                    blurRadius: _parseDouble(backButton['shadowBlurRadius'], 6),
                    offset: Offset(0, _parseDouble(backButton['shadowOffset']?['y'], 2)),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: backIconColor,
                  size: backIconSize.r,
                ),
              ),
            ),
          ),
          SizedBox(width: _parseDouble(topBar['spacing'], 14).w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: _parseDouble(topBar['titleFontSize'], 20).sp,
                fontWeight: _parseFontWeight(topBar['titleFontWeight'], FontWeight.w800),
                color: _parseColor(topBar['titleColor'], const Color(0xFF333333)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard({
    required TestimonialData testimonial,
    required Map<String, dynamic> cardConfig,
    required Map<String, dynamic> audioPlayerConfig,
    required String currentLanguage,
  }) {
    final langKey = _languageKey(currentLanguage);
    final testimonialText = testimonial.text[langKey] as String? ??
        testimonial.text['English'] as String? ??
        '';

    // Choose audio path based on language
    final audioPath = langKey == 'اردو' || langKey == 'Roman Urdu'
        ? testimonial.urduAudioPath
        : testimonial.audioPath;

    final isPlaying = _playingTestimonialId == testimonial.id;

    return Container(
      margin: EdgeInsets.only(bottom: _parseDouble(cardConfig['bottomMargin'], 16).h),
      padding: EdgeInsets.fromLTRB(
        _parseDouble(cardConfig['sidePadding'], 16).w,
        _parseDouble(cardConfig['topPadding'], 16).h,
        _parseDouble(cardConfig['sidePadding'], 16).w,
        _parseDouble(cardConfig['bottomPadding'], 12).h,
      ),
      decoration: BoxDecoration(
        color: _parseColor(cardConfig['backgroundColor'], Colors.white),
        borderRadius: BorderRadius.circular(_parseDouble(cardConfig['borderRadius'], 20).r),
        boxShadow: [
          BoxShadow(
            color: _parseColor(cardConfig['shadowColor'], const Color(0x0F000000)),
            blurRadius: _parseDouble(cardConfig['shadowBlurRadius'], 12),
            offset: Offset(
              _parseDouble(cardConfig['shadowOffset']?['x'], 0),
              _parseDouble(cardConfig['shadowOffset']?['y'], 4),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(
            testimonialText,
            style: TextStyle(
              fontSize: _parseDouble(cardConfig['questionText']?['fontSize'] ?? 15, 15).sp,
              fontWeight: _parseFontWeight(cardConfig['questionText']?['fontWeight'], FontWeight.w600),
              color: _parseColor(cardConfig['questionText']?['color'], const Color(0xFF333333)),
              height: _parseDouble(cardConfig['questionText']?['lineHeight'], 1.5),
            ),
          ),
          SizedBox(height: _parseDouble(cardConfig['questionText']?['bottomSpacing'] ?? 12, 12).h),
          // Audio player
          _buildAudioPlayer(
            testimonial: testimonial,
            audioPath: audioPath,
            currentLanguage: currentLanguage,
            audioPlayerConfig: audioPlayerConfig,
            isPlaying: isPlaying,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer({
    required TestimonialData testimonial,
    required String audioPath,
    required String currentLanguage,
    required Map<String, dynamic> audioPlayerConfig,
    required bool isPlaying,
  }) {
    final langKey = _languageKey(currentLanguage);
    final name = langKey == 'اردو'
        ? testimonial.urduName
        : (langKey == 'Roman Urdu' ? testimonial.romanUrduName : testimonial.name);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _parseDouble(audioPlayerConfig['horizontalPadding'], 14).w,
      ),
      decoration: BoxDecoration(
        color: _parseColor(audioPlayerConfig['backgroundColor'], const Color(0xFFE86A8D)),
        borderRadius: BorderRadius.circular(_parseDouble(audioPlayerConfig['borderRadius'], 20).r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: _parseDouble(audioPlayerConfig['topPadding'], 12).h,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: _parseDouble(audioPlayerConfig['avatarSize'], 42).r,
              height: _parseDouble(audioPlayerConfig['avatarSize'], 42).r,
              decoration: BoxDecoration(
                color: _parseColor(audioPlayerConfig['avatarBackground'], const Color(0x40FFFFFF)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'T',
                  style: TextStyle(
                    fontSize: _parseDouble(audioPlayerConfig['avatarTextFontSize'], 18).sp,
                    fontWeight: _parseFontWeight(audioPlayerConfig['avatarTextFontWeight'], FontWeight.w700),
                    color: _parseColor(audioPlayerConfig['avatarTextColor'], Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(width: _parseDouble(audioPlayerConfig['nameSpacing'], 6).w),
            // Name
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: _parseDouble(audioPlayerConfig['nameFontSize'], 13).sp,
                  fontWeight: _parseFontWeight(audioPlayerConfig['nameFontWeight'], FontWeight.w700),
                  color: _parseColor(audioPlayerConfig['nameColor'], Colors.white),
                ),
              ),
            ),
            // Play button
            GestureDetector(
              onTap: () => _playAudio(
                audioPath: audioPath,
                testimonialId: testimonial.id,
              ),
              child: Container(
                width: _parseDouble(audioPlayerConfig['playButtonSize'], 40).r,
                height: _parseDouble(audioPlayerConfig['playButtonSize'], 40).r,
                decoration: BoxDecoration(
                  color: _parseColor(audioPlayerConfig['playButtonBackground'], const Color(0x40FFFFFF)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _isLoading && isPlaying
                      ? SizedBox(
                          width: _parseDouble(audioPlayerConfig['playIconSize'], 24).r,
                          height: _parseDouble(audioPlayerConfig['playIconSize'], 24).r,
                          child: CircularProgressIndicator(
                            color: _parseColor(audioPlayerConfig['playIconColor'], Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: _parseColor(audioPlayerConfig['playIconColor'], Colors.white),
                          size: _parseDouble(audioPlayerConfig['playIconSize'], 24).r,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}

class TestimonialData {
  final String id;
  final int order;
  final String name;
  final String urduName;
  final String romanUrduName;
  final Map<String, dynamic> text; // translations
  final String audioPath;
  final String urduAudioPath;
  final String avatarColor;

  TestimonialData({
    required this.id,
    required this.order,
    required this.name,
    required this.urduName,
    required this.romanUrduName,
    required this.text,
    required this.audioPath,
    required this.urduAudioPath,
    required this.avatarColor,
  });

  factory TestimonialData.fromFirestore(Map<String, dynamic> data) {
    return TestimonialData(
      id: data['id'] as String? ?? '',
      order: data['order'] as int? ?? 0,
      name: data['name'] as String? ?? '',
      urduName: data['urduName'] as String? ?? '',
      romanUrduName: data['romanUrduName'] as String? ?? '',
      text: (data['text'] as Map<String, dynamic>?) ?? {},
      audioPath: data['audioPath'] as String? ?? '',
      urduAudioPath: data['urduAudioPath'] as String? ?? '',
      avatarColor: data['avatarColor'] as String? ?? '#E86A8D',
    );
  }
}
