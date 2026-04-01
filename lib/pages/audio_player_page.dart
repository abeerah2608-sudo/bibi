import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import '../widgets/onboarding_widgets_exports.dart';

class AudioContent {
  final String title;
  final String subtitle;
  final String audioPath;
    final String animationPath;
  final List<String> urduLyrics;
  final List<String> englishLyrics;

  const AudioContent({
    required this.title,
    required this.subtitle,
    required this.audioPath,
    required this.animationPath,
    required this.urduLyrics,
    required this.englishLyrics,
  });

  List<String> getLyrics(String language) {
    if (language == 'English') {
      return englishLyrics;
    } else if (language == 'Urdu') {
      return urduLyrics;
    } else {
      return [];
    }
  }
}

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

  List<String> get _lyricLines =>
      widget.audioContent.getLyrics(_currentLanguage);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _audioPlayer = AudioPlayer();

    _audioPlayer.setAsset(widget.audioContent.audioPath).then((_) {
      final dur = _audioPlayer.duration;
      if (dur != null && mounted) {
        setState(() => _duration = dur.inSeconds.toDouble());
      }
    }).catchError((e) {
      debugPrint('Audio load error: $e');
    });

    _audioPlayer.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() {
        _position = pos.inSeconds.toDouble().clamp(0.0, _duration);
        final maxIndex = _lyricLines.length - 1;
        _currentLyricLineIndex = (_position ~/ 10).clamp(0, maxIndex);
      });
    });

    _audioPlayer.playingStream.listen((playing) {
      if (!mounted) return;
      setState(() => _isPlaying = playing);
    });
  }

  void _seekTo(double value) {
    final clamped = value.clamp(0.0, _duration);
    _audioPlayer.seek(Duration(seconds: clamped.toInt()));
    setState(() {
      _position = clamped;
      final maxIndex = _lyricLines.length - 1;
      _currentLyricLineIndex = (clamped ~/ 10).clamp(0, maxIndex);
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
          _currentLanguage = state.language;
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
  assetPath: widget.audioContent.animationPath, // ← was hardcoded before
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
          // Time labels
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

          // Transport controls
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
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF8B5E3C), size: 16),
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
  audioPath: 'assets/audio/your_audio.mp3',
  animationPath: 'assets/images/Cancer Cell Animation from Bibi Project (1).lottie',
  urduLyrics: [
    'چھاتی کا کینسر کیا ہے؟',
    'یہ ایک بیماری ہے جو چھاتی کے خلیوں میں شروع ہوتی ہے',
    'جب خلیے بے قابو ہو کر بڑھنے لگتے ہیں',
    'تو وہ گانٹھ بناتے ہیں',
  ],
  englishLyrics: [
    'What is breast cancer?',
    'It is a disease that begins in breast cells',
    'When cells grow out of control',
    'They form a lump or tumor',
  ],
);

const audioContent2 = AudioContent(
  title: 'Are you at Risk?',
  subtitle: 'When an abnormality is found',
  audioPath: 'assets/audio/are_you_at_risk.mp3',
  animationPath: 'assets/images/family_tree.lottie',
  urduLyrics: [
    'کیا آپ خطرے میں ہیں؟',
    'خاندانی تاریخ ایک اہم عنصر ہے',
    'عمر کے ساتھ خطرہ بڑھتا ہے',
    'باقاعدہ جانچ ضروری ہے',
  ],
  englishLyrics: [
    'Are you at risk?',
    'Family history is an important factor',
    'Risk increases with age',
    'Regular screening is essential',
  ],
);

const audioContent3 = AudioContent(
  title: 'Preventive Screening',
  subtitle: 'Understanding preventive screening',
  audioPath: 'assets/audio/preventive_screening.mp3',
  animationPath: 'assets/images/mammogram.lottie',
  urduLyrics: [
    'احتیاطی اسکریننگ کیا ہے؟',
    'میموگرام ایک اہم ٹیسٹ ہے',
    'جلد پتہ لگانا زندگی بچا سکتا ہے',
    'سال میں ایک بار جانچ کروائیں',
  ],
  englishLyrics: [
    'What is preventive screening?',
    'A mammogram is an important test',
    'Early detection can save lives',
    'Get checked once a year',
  ],
);

const audioContent4 = AudioContent(
  title: 'How to Treat?',
  subtitle: 'Care options after detection',
  audioPath: 'assets/audio/how_to_treat.mp3',
    animationPath: 'assets/images/Family Tree Animation from Bibi Project (1).lottie',

  urduLyrics: [
    'علاج کے کیا طریقے ہیں؟',
    'سرجری ایک آپشن ہو سکتی ہے',
    'کیموتھراپی بھی ممکن ہے',
    'ڈاکٹر سے مشورہ کریں',
  ],
  englishLyrics: [
    'What are the treatment options?',
    'Surgery may be one option',
    'Chemotherapy is also possible',
    'Consult your doctor',
  ],
);

const audioContent5 = AudioContent(
  title: 'How to Confirm?',
  subtitle: 'Tests and checks to know for sure',
  audioPath: 'assets/audio/how_to_confirm.mp3',
    animationPath: 'assets/images/Family Tree Animation from Bibi Project (1).lottie',

  urduLyrics: [
    'تشخیص کیسے کریں؟',
    'بایوپسی ایک اہم ٹیسٹ ہے',
    'الٹراساؤنڈ بھی مددگار ہے',
    'ڈاکٹر سے رجوع کریں',
  ],
  englishLyrics: [
    'How to confirm a diagnosis?',
    'A biopsy is an important test',
    'Ultrasound can also help',
    'See your doctor promptly',
  ],
);

const audioContent6 = AudioContent(
  title: 'How to Prevent?',
  subtitle: 'Simple steps to lower the risk',
  audioPath: 'assets/audio/how_to_prevent.mp3',
    animationPath: 'assets/images/Family Tree Animation from Bibi Project (1).lottie',

  urduLyrics: [
    'بچاؤ کے طریقے کیا ہیں؟',
    'صحت مند غذا کھائیں',
    'ورزش کو معمول بنائیں',
    'شراب اور سگریٹ سے پرہیز کریں',
  ],
  englishLyrics: [
    'How can you prevent breast cancer?',
    'Eat a healthy balanced diet',
    'Make exercise a daily habit',
    'Avoid alcohol and smoking',
  ],
);

const audioContent7 = AudioContent(
  title: 'How to Support?',
  subtitle: 'Ways to help with care and comfort',
  audioPath: 'assets/audio/how_to_support.mp3',
    animationPath: 'assets/images/Family Tree Animation from Bibi Project (1).lottie',

  urduLyrics: [
    'مدد کیسے کریں؟',
    'مریض کے ساتھ وقت گزاریں',
    'ان کی بات سنیں',
    'طبی اپائنٹمنٹ میں ساتھ جائیں',
  ],
  englishLyrics: [
    'How can you support someone?',
    'Spend quality time with them',
    'Listen and be present',
    'Accompany them to appointments',
  ],
);