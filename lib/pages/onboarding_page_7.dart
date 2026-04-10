import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart'; // ✅ ADDED
import '../services/language_strings.dart';
import '../widgets/onboarding_widgets_exports.dart';
import 'onboarding_page_6.dart';
import 'onboarding_page_8.dart';

// ✅ ADDED audio paths
const String _englishAudio = 'assets/audio/onboarding_10.mp3';
const String _urduAudio = 'assets/audio/onboarding_10_urdu.mp3';

class OnboardingPage7 extends StatefulWidget {
  const OnboardingPage7({super.key});

  @override
  State<OnboardingPage7> createState() => _OnboardingPage7State();
}

class _OnboardingPage7State extends State<OnboardingPage7> {
  bool _showText = false;
  bool _isFavourite = false;
  bool _showContinue = false;

  static const String _videoUrl =
      'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
  static const String _videoDuration = '3:33';

  // ✅ ADDED audio variables
  late AudioPlayer _audioPlayer;
  String _currentLanguage = 'English';
  String _loadedAudioPath = '';

  String get _currentAudioPath {
    return _currentLanguage == 'Urdu' ? _urduAudio : _englishAudio;
  }

  @override
  void initState() {
    super.initState();

    // ✅ INIT AUDIO
    _audioPlayer = AudioPlayer();
    _loadedAudioPath = _englishAudio;
    _loadAudio(_loadedAudioPath);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showText = true);
    });
  }

  // ✅ ADDED
  void _loadAudio(String path) {
    _audioPlayer.setAsset(path).then((_) {
      _audioPlayer.play(); // auto play
      _loadedAudioPath = path;
    }).catchError((e) {
      debugPrint('Audio load error: $e');
    });
  }

  // ✅ ADDED
  void _onLanguageChanged(String newLanguage) {
    if (newLanguage == _currentLanguage) return;

    _currentLanguage = newLanguage;
    final newPath = _currentAudioPath;

    if (newPath != _loadedAudioPath) {
      final wasPlaying = _audioPlayer.playing;

      _audioPlayer.stop();
      _loadAudio(newPath);

      if (wasPlaying) {
        _audioPlayer.play();
      }
    }
  }

  Future<void> _launchVideo() async {
    final uri = Uri.parse(_videoUrl);

    _audioPlayer.stop(); // ✅ ADDED (stop audio before video)

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched && mounted) {
        setState(() => _showContinue = true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch video')),
        );
      }
    } catch (e) {
      debugPrint('Error launching video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening video')),
        );
      }
    }
  }

  void _navigateNext(String currentLanguage) {
    _audioPlayer.stop(); // ✅ ADDED

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const OnboardingPage8(),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // ✅ ADDED
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String currentLanguage = 'English';
        if (state is LanguageSelected) {
          currentLanguage = state.language;
          _onLanguageChanged(currentLanguage); // ✅ ADDED
        }

        final cardTitle = LanguageStrings.getTranslation(
            currentLanguage, 'self_examine_card_title');
        final subtitle = LanguageStrings.getTranslation(
            currentLanguage, 'self_examine_subtitle');
        final watchNow =
            LanguageStrings.getTranslation(currentLanguage, 'watch_now');
        final mainTitle = LanguageStrings.getTranslation(
            currentLanguage, 'self_examine_title');
        final continueText = LanguageStrings.getTranslation(
            currentLanguage, 'continue_after_watching');
        final isUrdu = currentLanguage == 'اردو';

        return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = constraints.maxHeight * 0.40;

            return Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFFFF4F4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  Image.asset(
                    'assets/images/Bibi_Logo_Vector 1.png',
                    height: 72,
                    width: 72,
                  ),

                  const SizedBox(height: 14),

                  // ── Card (UNCHANGED) ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: imageHeight,
                              color: const Color(0xFFEFA7BC),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      'assets/images/miss_bibi.png',
                                      fit: BoxFit.contain,
                                      alignment: Alignment.bottomCenter,
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.play_circle_filled,
                                              color: Color(0xFFE86A8D),
                                              size: 13),
                                          SizedBox(width: 4),
                                          Text(
                                            _videoDuration,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Color(0xFFE86A8D),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Info section
                            Container(
                              width: double.infinity,
                              color: const Color(0xFFFFF4F4),
                              padding:
                                  const EdgeInsets.fromLTRB(16, 14, 16, 16),
                              child: AnimatedSlide(
                                offset: _showText
                                    ? Offset.zero
                                    : const Offset(0, 0.12),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutCubic,
                                child: AnimatedOpacity(
                                  opacity: _showText ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 500),
                                  child: Directionality(
                                    textDirection: isUrdu
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cardTitle,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF8B5E3C),
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          subtitle,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF9A7070),
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 10),

                                        Row(
                                          children: [
                                            // Watch Now button — hides after tap
                                            if (!_showContinue)
                                              GestureDetector(
                                                onTap: _launchVideo,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 14,
                                                      vertical: 7),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                            0xFFF4A7B9)
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(
                                                      color: const Color(
                                                          0xFFFFB2C7),
                                                      width: 1.2,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        watchNow,
                                                        style: const TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Color(
                                                              0xFFE86A8D),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                      const Icon(
                                                          Icons.chevron_right,
                                                          color:
                                                              Color(0xFFE86A8D),
                                                          size: 14),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                            // Continue button — shown after Watch Now
                                            if (_showContinue)
                                              GestureDetector(
                                                onTap: () => _navigateNext(currentLanguage),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 14,
                                                      vertical: 7),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                        0xFFE86A8D),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        continueText,
                                                        style: const TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      const Icon(
                                                          Icons.arrow_forward,
                                                          color: Colors.white,
                                                          size: 14),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                            const Spacer(),

                                            // Heart toggle
                                            GestureDetector(
                                              onTap: () => setState(() =>
                                                  _isFavourite =
                                                      !_isFavourite),
                                              child: AnimatedSwitcher(
                                                duration: const Duration(
                                                    milliseconds: 250),
                                                transitionBuilder:
                                                    (child, anim) =>
                                                        ScaleTransition(
                                                            scale: anim,
                                                            child: child),
                                                child: Icon(
                                                  _isFavourite
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  key: ValueKey(_isFavourite),
                                                  color: _isFavourite
                                                      ? Colors.red
                                                      : const Color(0xFF8B5E3C),
                                                  size: 22,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        mainTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        color: Color(0xFF8B5E3C),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  OnboardingPageIndicator(currentPage: 9, totalPages: 14),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OnboardingNavigationButtons(
                      onBackPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const OnboardingPage6(),
                          ),
                        );
                      },
                      onNextPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const OnboardingPage8(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
      },
    );
  }
}