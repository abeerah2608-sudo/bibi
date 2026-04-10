import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import '../widgets/onboarding_widgets_exports.dart';

// Keys are the audioPath of each AudioContent.
// Values are lists of start-times for each lyric line.
// Line N is active from timestamps[n] up to but not including timestamps[n+1].
// The last line stays active until the audio ends.
const Map<String, List<double>> _lyricTimestamps = {
  'assets/audio/whatisbreastcancer.m4a': [
    0,    // line 1 – shown from 0:00
    4,    // line 2 – 0:04
    6,    // line 3 – 0:06
    9,    // line 4 – 0:09
    11,   // line 5 – 0:11
    15,   // line 6 – 0:15
    17,   // line 7 – 0:17
  ],
  'assets/audio/whatisbreastcancer_urdu.m4a': [
    0,
    4,
    6,
    9,
  ],
  'assets/audio/risk.m4a': [
    0,    // line 1 – shown from 0:00
    4,    // line 2 – 0:04
    8,    // line 3 – 0:06
    12,   // line 4 – 0:09
  ],
  'assets/audio/risk_urdu.m4a': [
    0,
    4,
    8,
    12,
  ],
  'assets/audio/screen.m4a': [
    0,    // line 1 – shown from 0:00
    5,    // line 2 – 0:04
    8,    // line 3 – 0:06
    12,
    16,
    20,   // line 4 – 0:09
  ],
  'assets/audio/screen_urdu.m4a': [
    0,
    5,
    8,
    12,
  ],
  'assets/audio/treat.m4a': [
    0,    // line 1 – shown from 0:00
    7,    // line 2 – 0:04
    12,   // line 3 – 0:06
    18,   // line 4 – 0:09
  ],
  'assets/audio/treat_urdu.m4a': [
    0,
    7,
    12,
    18,
  ],
  'assets/audio/biopsy.m4a': [
    0,    // line 1 – shown from 0:00
    5,    // line 2 – 0:04
    9,    // line 3 – 0:06
    13,   // line 4 – 0:09
  ],
  'assets/audio/biopsy_urdu.m4a': [
    0,
    4,
    8,
    12,
  ],
  'assets/audio/prevent.m4a': [
    0,    // line 1 – shown from 0:00
    5,    // line 2 – 0:04
    9,    // line 3 – 0:06
    13,   // line 4 – 0:09
  ],
  'assets/audio/prevent_urdu.m4a': [
    0,
    4,
    8,
    12,
  ],
  'assets/audio/support.m4a': [
    0,   // line 1 - shown from 0:00
    6,   // line 2 - shown from :04
    12,   // line 3 - shown from :08
    16,  // line 4 - shown from :12
  ],
  'assets/audio/support_urdu.m4a': [
    0,
    4,
    8,
    12,
  ],
};

int _getLyricIndex(String audioPath, double positionSeconds, int lineCount) {
  final timestamps = _lyricTimestamps[audioPath];
  if (timestamps == null || timestamps.isEmpty || lineCount == 0) {
    // Fallback: one line per 10 seconds
    return (positionSeconds ~/ 10).clamp(0, lineCount - 1);
  }

  // Walk backwards through the timestamp list and return the last index whose
  // start-time is ≤ the current position.
  for (int i = timestamps.length - 1; i >= 0; i--) {
    if (positionSeconds >= timestamps[i]) {
      return i.clamp(0, lineCount - 1);
    }
  }
  return 0;
}

// ── Data model ────────────────────────────────────────────────────────────────

class AudioContent {
  final String title;
  final String subtitle;
  final String audioPath;
  final String urduAudioPath; // <-- NEW: Urdu audio file
  final String animationPath;
  final List<String> urduLyrics;
  final List<String> englishLyrics;

  const AudioContent({
    required this.title,
    required this.subtitle,
    required this.audioPath,
    required this.urduAudioPath, // <-- NEW
    required this.animationPath,
    required this.urduLyrics,
    required this.englishLyrics,
  });

  List<String> getLyrics(String language) {
    if (language == 'English') return englishLyrics;
    if (language == 'Urdu') return urduLyrics;
    return [];
  }

  /// Returns the correct audio path for the given language.
  String getAudioPath(String language) {
    if (language == 'Urdu') return urduAudioPath;
    return audioPath;
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────

class AudioPlayerPage extends StatefulWidget {
  final AudioContent audioContent;

  const AudioPlayerPage({
    Key? key,
    required this.audioContent,
  }) : super(key: key);

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late PageController _pageController;
  late AudioPlayer _audioPlayer;

  bool _isPlaying = false;
  double _position = 0.0;
  double _duration = 166.0;
  int _currentLyricLineIndex = 0;
  String _currentLanguage = 'English';
  String _loadedAudioPath = ''; // tracks which audio is currently loaded

  List<String> get _lyricLines =>
      widget.audioContent.getLyrics(_currentLanguage);

  String get _currentAudioPath =>
      widget.audioContent.getAudioPath(_currentLanguage);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _audioPlayer = AudioPlayer();

    _loadedAudioPath = widget.audioContent.audioPath;
    _loadAudio(_loadedAudioPath);

    _audioPlayer.positionStream.listen((pos) {
      if (!mounted) return;
      final secs = pos.inSeconds.toDouble().clamp(0.0, _duration);
      setState(() {
        _position = secs;
        _currentLyricLineIndex = _getLyricIndex(
          _loadedAudioPath,
          secs,
          _lyricLines.length,
        );
      });
    });

    _audioPlayer.playingStream.listen((playing) {
      if (!mounted) return;
      setState(() => _isPlaying = playing);
    });
  }

void _loadAudio(String path) {
  _audioPlayer.setAsset(path).then((_) {
    final dur = _audioPlayer.duration;
    if (dur != null && mounted) {
      setState(() {
        _duration = dur.inSeconds.toDouble();
        _position = 0.0;
        _currentLyricLineIndex = 0;
        _loadedAudioPath = path;
      });
    }
    _audioPlayer.play(); // <-- add this line
  }).catchError((e) {
    debugPrint('Audio load error: $e');
  });
}
  /// Called whenever the language changes — swaps audio if needed.
  void _onLanguageChanged(String newLanguage) {
    if (newLanguage == _currentLanguage) return;
    _currentLanguage = newLanguage;

    final newPath = widget.audioContent.getAudioPath(newLanguage);
    if (newPath != _loadedAudioPath) {
      final wasPlaying = _audioPlayer.playing;
      _audioPlayer.stop();
      _loadAudio(newPath);
      // Resume playback after load if it was playing before
      if (wasPlaying) {
        _audioPlayer.setAsset(newPath).then((_) {
          _audioPlayer.play();
        });
      }
    }
  }

  void _seekTo(double value) {
    final clamped = value.clamp(0.0, _duration);
    _audioPlayer.seek(Duration(seconds: clamped.toInt()));
    setState(() {
      _position = clamped;
      _currentLyricLineIndex = _getLyricIndex(
        _loadedAudioPath,
        clamped,
        _lyricLines.length,
      );
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _formatTime(double seconds) {
    final int s = seconds.toInt();
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        if (state is LanguageSelected) {
          _onLanguageChanged(state.language); // <-- swap audio on language change
        }

        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            return false;
          },
          child: Scaffold(
            body: SafeArea(
              child: PageView(
  controller: _pageController,
  scrollDirection: Axis.vertical, // <-- add this
  children: [
    _buildPlayScreen(),
    _buildLyricsScreen(),
  ],
),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayScreen() {
    return Container(
      color: const Color(0xFFFFF5F5),
      child: Column(
        children: [
          const _Header(),
          Expanded(
            child: RepaintBoundary(
              child: Center(
                child: OnboardingAnimation(
                  assetPath: widget.audioContent.animationPath,
                  translateX: 0,
                  translateY: 0,
                  repeat: false,
                ),
              ),
            ),
          ),
          _buildPlayerControls(),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(_position),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatTime(_duration),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: _position.clamp(0.0, _duration),
              min: 0.0,
              max: _duration,
              activeColor: const Color(0xFFE86A8D),
              inactiveColor: const Color(0xFFFFD5E0),
              onChanged: (value) => _seekTo(value),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            widget.audioContent.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'BIBI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF999999),
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _seekTo(_position - 15),
                child: const Icon(Icons.fast_rewind_rounded,
                    color: Color(0xFFE86A8D), size: 42),
              ),
              const SizedBox(width: 40),

              GestureDetector(
                onTap: () {
                  if (_audioPlayer.playing) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.play();
                  }
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE86A8D),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(89, 232, 106, 141),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),

              const SizedBox(width: 40),
              GestureDetector(
                onTap: () => _seekTo(_position + 15),
                child: const Icon(Icons.fast_forward_rounded,
                    color: Color(0xFFE86A8D), size: 42),
              ),
            ],
          ),

          const SizedBox(height: 24),

          GestureDetector(
            onTap: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            child: const Column(
              children: [
                Icon(Icons.keyboard_arrow_up,
                    color: Color(0xFFE86A8D), size: 22),
                Text(
                  'LYRICS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF999999),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLyricsScreen() {
    final lines = _lyricLines;
    final isUrdu = _currentLanguage == 'Urdu';

    return Container(
      color: const Color(0xFFFFF5F5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
             GestureDetector(
  onTap: () => _pageController.previousPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  ),
  child: _circleButton(
    child: const Icon(Icons.keyboard_arrow_down, // <-- was arrow_back_ios_new
        color: Color(0xFF8B5E3C), size: 20),
  ),
),
                const Text(
                  'NOW LEARNING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                    letterSpacing: 1.2,
                  ),
                ),
                _circleButton(
                  child: const Icon(Icons.favorite,
                      color: Color(0xFFE86A8D), size: 18),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              widget.audioContent.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE86A8D),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              itemCount: lines.length,
              itemBuilder: (context, index) {
                final bool isActive = index == _currentLyricLineIndex;
                final bool isPast = index < _currentLyricLineIndex;

                final Color lineColor = isActive
                    ? const Color(0xFFE86A8D)
                    : isPast
                        ? const Color(0xFFE86A8D).withOpacity(0.3)
                        : const Color(0xFFCCCCCC);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.symmetric(vertical: isActive ? 10 : 5),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize: isActive ? 17 : 13,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w400,
                      color: lineColor,
                      height: 1.7,
                    ),
                    child: Text(
                      lines[index],
                      textAlign: TextAlign.center,
                      textDirection:
                          isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFD5E0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE86A8D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE86A8D),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE86A8D).withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
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

  Widget _circleButton({required Widget child}) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Stateless header ──────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Color(0xFF8B5E3C), size: 16),
            ),
          ),
          const Text(
            'NOW PLAYING',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
              letterSpacing: 1.2,
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.favorite_border,
                color: Color(0xFFE86A8D), size: 18),
          ),
        ],
      ),
    );
  }
}

// ── Audio Content Instances ───────────────────────────────────────────────────

const audioContent1 = AudioContent(
  title: 'What is Breast Cancer?',
  subtitle: 'Understanding the basics',
  audioPath: 'assets/audio/whatisbreastcancer.m4a',
  urduAudioPath: 'assets/audio/whatisbreastcancer_urdu.m4a', // <-- ADD YOUR URDU FILE
  animationPath: 'assets/images/Cancer Cell Animation from Bibi Project (1).lottie',
  urduLyrics: [
    ' چھاتی کا کینسر تب ہوتا ہے جب جسم کے خلیات بڑھنے لگتے ہیں۔',
    'یہ کسی بھی عمر کی خواتین اور کبھی کبار مردوں کو بھی ہو سکتا ہے۔',
    'پاکستان میں ہر نو میں سے ایک خاتون کو زندگی میں اس کا سامنا کرنا بڑھتا ہے۔',
    'لیکن یاد رکھیں، وقت پر تشخیص زندگی کو بچا سکتی ہے۔',
  ],
  englishLyrics: [
    'Breast cancer happens when',
    'cells in the breast start growing',
    'abnormally.It can happen to women',
    '-and sometimes men- of any age',
    'In Pakistan one in nine women',
    'may face it in their lifetime.',
    '.But remember early detection can save lives.',
  ],
);

const audioContent2 = AudioContent(
  title: 'Are you at Risk?',
  subtitle: 'When an abnormality is found',
  audioPath: 'assets/audio/risk.m4a',
  urduAudioPath: 'assets/audio/risk_urdu.m4a', // <-- ADD YOUR URDU FILE
  animationPath: 'assets/images/family_tree.lottie',
  urduLyrics: [
    'اگر آپ کے خاندان میں کسی کو یہ کینسر ہو رہا ہو، آپ کی عمر چالیس سال سے زیادہ ہو',
    'یا آپ کی زندگی میں ورزش کی کمی ہو تو خطرہ بڑھ سکتا ہے۔',
    'آئیے آپ کے خطرے کا جائزہ لیتے ہیں، اس میں صرف ایک منٹ لگے گا۔',
    
  ],
  englishLyrics: [
    '"You may be at higher risk if someone',
    ' in your family had breast cancer, if you\'re',
    'over forty, or if you live a less active lifestyle.',
    'Let\'s check your risk—it only takes a minute!',
  ],
);

const audioContent3 = AudioContent(
  title: 'Preventive Screening',
  subtitle: 'Understanding preventive screening',
  audioPath: 'assets/audio/screen.m4a',
  urduAudioPath: 'assets/audio/screen_urdu.m4a', // <-- ADD YOUR URDU FILE
  animationPath: 'assets/images/mammogram.lottie',
  urduLyrics: [
    'چھاتی کے کینسر کا علاج ممکن ہے، اگر یہ جلد معلوم ہو جائے',
    ' ہر عورت کو اپنے جسم سے واقف ہونا چاہیے',
    'ہر ماہ مہواری ختم ہونے کے 7 سے 10 دن بعد اپنا مائنہ خود کریں',
    'چالیس سال سے اوپر کی خواتین کے لیے سال میں ایک بار میموگرافی ضروری ہے',
    'سکریننگ کا مطلب یہ نہیں کہ آپ بیمار ہیں'
    'اس کا مطلب یہ ہے کہ آپ اپنی صحت کے لیے سنجیدہ اور مضبوط ہیں'
  ],
  englishLyrics: [
    'Breast cancer can be treated—if it\'s found',
    'early. Every woman should know her body.',
    ' Start by checking yourself once a month, seven to ten ',
    'days after your period ends. For women over',
    ' forty, a mammogram once a year is essential.',
    'Screening doesn\'t mean you\'re sick; it means you\'re strong.'
  ],
);

const audioContent4 = AudioContent(
  title: 'How to Treat?',
  subtitle: 'Care options after detection',
  audioPath: 'assets/audio/treat.m4a',
  urduAudioPath: 'assets/audio/treat_urdu.m4a',
  animationPath: 'assets/images/chemotherapy.lottie',
  urduLyrics: [
    '  جب مجھے بتایا گیا کہ مجھے کینسر ہے تو میں ڈر گئی تھی لیکن علاج اثر کرتا ہے ',
    'میری کیمو تھراپی، سرجری اور ریڈییشن ہوئی۔ یہ ہمیشہ آسان نہیں تھا',
    'میرے بال جھڑ گئے اور میں تھکاوت محسوس کرتی تھی',
    '  لیکن اس سے رسولی ختم ہوئی اور الحمدللہ میری جان بچ گئی ',
  ],
  englishLyrics: [
    'When I was told I had cancer, I was afraid. ',
    'gives answers, not a death sentence. Many people',
    ' believe a biopsy spreads cancer—that is a myth!',
    'It is a safe way to get the right treatment started.',
  ],
);

const audioContent5 = AudioContent(
  title: 'How to Confirm?',
  subtitle: 'Tests and checks to know for sure',
  audioPath: 'assets/audio/biopsy.m4a',
  urduAudioPath: 'assets/audio/how_to_confirm_urdu.m4a', // <-- ADD YOUR URDU FILE
  animationPath: 'assets/images/ultrasound.lottie',
  urduLyrics: [
    '  اگر آپ کو کچھ غیر معمولی لگے تو گھبرائیں نہیں۔ ',
    'بائیوپسی معلوم ہوتی ہے کہ موت کا پروانا نہیں ہے۔',
    '  بہت سے لوگ سمجھتے ہیں کہ بائیوپسی سے کینسر پھیلتا ہے۔',
    '   یہ بالکل غلط ہے۔',
    'یہ صحیح علاج شروع کرنے کا ایک محفوظ طریقہ ہے۔'
  ],
  englishLyrics: [
    'If you find something, don\'t panic. A biopsy ',
    'gives answers, not a death sentence. Many people',
    ' believe a biopsy spreads cancer—that is a myth!',
    'It is a safe way to get the right treatment started.',
  ],
);

const audioContent6 = AudioContent(
  title: 'How to Prevent?',
  subtitle: 'Simple steps to lower the risk',
  audioPath: 'assets/audio/prevent.m4a',
  urduAudioPath: 'assets/audio/how_to_prevent_urdu.m4a', // <-- ADD YOUR URDU FILE
  animationPath: 'assets/images/Bibi_Onboarding_Right.lottie',
  urduLyrics: [
    '  جب مجھے بتایا گیا کہ مجھے کینسر ہے تو میں ڈر گئی تھی لیکن علاج اثر کرتا ہے ',
    'میری کیمو تھراپی، سرجری اور ریڈییشن ہوئی۔ یہ ہمیشہ آسان نہیں تھا',
    'میرے بال جھڑ گئے اور میں تھکاوت محسوس کرتی تھی',
    '  لیکن اس سے رسولی ختم ہوئی اور الحمدللہ میری جان بچ گئی ',
  ],
  englishLyrics: [
    'Healthy eating and staying active can reduce your risk.',
    'Eat more vegetables, fruits, and whole grains.',
    'Avoid oily foods and try to walk daily,',
    'even if it\'s just in your home or a nearby park',
  ],
);

const audioContent7 = AudioContent(
  title: 'How to Support?',
  subtitle: 'Ways to help with care and comfort',
  audioPath: 'assets/audio/support.m4a',
  urduAudioPath: 'assets/audio/support_urdu.m4a', // <-- ADD YOUR URDU FILE
  animationPath: 'assets/images/Bibi_Onboarding_Right.lottie',
  urduLyrics: [
   
    ' اچھی غزہ اور متحرک رہنا خطرے کو کم کر سکتا ہے۔ ',
    '  سبزیوں، پھلوں اور دالوں کا استعمال زیادہ کریں۔   ',
    ' ٹلی ہوئی چیزوں سے پرحیث کریں اور روزانہ سیر کی عادت ڈالیں،',
    'چاہے وہ گھر میں ہو یا کسی بھی قریبی پارٹ میں۔'
  ],
  englishLyrics: [
    'If someone you know is fighting cancer, be there for her.',
    'You don’t need big words—a smile, a cup of tea, or just listening is enough.',
    'Together, we can give hope and the strength to heal.',
    'Share this app with every woman you love.',
  ],
);