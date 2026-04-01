import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';

class AudioPlayerPage extends StatefulWidget {
  final String title;
  final String subtitle;

  const AudioPlayerPage({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isPlaying = false;
  double _position = 0.0;
  double _duration = 245.0; // 2:45 in seconds

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatTime(double seconds) {
    int minutes = seconds.toInt() ~/ 60;
    int secs = seconds.toInt() % 60;
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String currentLanguage = 'English';
        if (state is LanguageSelected) {
          currentLanguage = state.language;
        }

        final lyrics = currentLanguage == 'English'
            ? '''Our bodies are made up of tiny cells. Sometimes, these breast cells in the breast start growing abnormally and out of control. That is what breast cancer is.

In Pakistan, 1 in 9 women may face it in their lifetime, but here's the good news:

If we catch it early, it's curable. Early detection is very important!'''
            : currentLanguage == 'اردو'
                ? '''ہمارے جسم چھوٹی چھوٹی خلیوں سے بنے ہوتے ہیں۔ کبھی کبھار، بریسٹ میں بریسٹ کی خلیں غیر معمولی انداز میں بڑھنے لگتی ہیں۔ یہ بریسٹ کینسر ہے۔

پاکستان میں، ہر 9 میں سے 1 خاتون کو اپنی زندگی میں اس کا سامنا ہو سکتا ہے، لیکن یہاں اچھی خبر ہے:

اگر ہم اسے جلدی پکڑیں، تو یہ قابل علاج ہے۔ جلد تشخیص بہت اہم ہے!'''
                : '''Our bodies are made up of tiny cells. Sometimes, these breast cells in the breast start growing abnormally and out of control. That is what breast cancer is.

In Pakistan, 1 in 9 women may face it in their lifetime, but here's the good news:

If we catch it early, it's curable. Early detection is very important!''';

        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            return false;
          },
          child: Scaffold(
            body: SafeArea(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  // Play Screen
                  _buildPlayScreen(currentLanguage),
                  // Lyrics Screen
                  _buildLyricsScreen(lyrics, currentLanguage),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayScreen(String language) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF5A6C2).withOpacity(0.3),
            const Color(0xFFFFB6D9).withOpacity(0.3),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back,
                      color: Color(0xFF8B5E3C), size: 24),
                ),
                const Text(
                  'NOW LEARNING',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE86A8D),
                    letterSpacing: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.favorite_border,
                      color: Color(0xFFE86A8D), size: 24),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular display (album art placeholder)
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFE8F0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Decorative circles
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFC8DC).withOpacity(0.5),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFB2C7),
                        ),
                        child: const Icon(Icons.play_circle_fill,
                            color: Colors.white, size: 50),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Title and subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Time display
                Text(
                  '${_formatTime(_position)} / ${_formatTime(_duration)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Slider
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8.0,
                    ),
                  ),
                  child: Slider(
                    value: _position,
                    min: 0,
                    max: _duration,
                    activeColor: const Color(0xFFE86A8D),
                    inactiveColor: const Color(0xFFFFD5E0),
                    onChanged: (value) {
                      setState(() => _position = value);
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Play controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _position = (_position - 15).clamp(0.0, _duration);
                        setState(() {});
                      },
                      child: const Icon(Icons.fast_rewind,
                          color: Color(0xFFE86A8D), size: 36),
                    ),
                    const SizedBox(width: 48),
                    GestureDetector(
                      onTap: () {
                        setState(() => _isPlaying = !_isPlaying);
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE86A8D),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE86A8D)
                                  .withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                    GestureDetector(
                      onTap: () {
                        _position = (_position + 15).clamp(0.0, _duration);
                        setState(() {});
                      },
                      child: const Icon(Icons.fast_forward,
                          color: Color(0xFFE86A8D), size: 36),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Page indicators and lyrics button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE86A8D),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFD5E0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'LYRICS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsScreen(String lyrics, String language) {
    return Container(
      color: const Color(0xFFFFF8F8),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.arrow_back,
                      color: Color(0xFF8B5E3C), size: 24),
                ),
                const Text(
                  'NOW LEARNING',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE86A8D),
                    letterSpacing: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.favorite,
                      color: Color(0xFFE86A8D), size: 24),
                ),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE86A8D),
              ),
            ),
          ),

          // Lyrics
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                lyrics,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFBBBBBB),
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          // Bottom controls
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
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
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE86A8D),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFE86A8D).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
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
}
