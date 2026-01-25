import 'package:flutter/material.dart';
import '../services/language_strings.dart';
import '../utils/smooth_page_route.dart';
import 'onboarding_page_3.dart';

class OnboardingPage4 extends StatelessWidget {
  final String language;

  const OnboardingPage4({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final title = LanguageStrings.getTranslation(language, 'life');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFFFF4F4),
        child: Column(
          children: [
            const SizedBox(height: 60),

            Image.asset(
              'assets/images/Bibi_Logo_Vector 1.png',
              height: 100,
              width: 100,
            ),

            Expanded(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0),
                      child: Transform.translate(
                        offset: const Offset(0, -40),
                        child: Image.asset(
                          'assets/images/ms_bibi.png',
                          height: 450,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 120,
                    left: 1,
                    right: MediaQuery.of(context).size.width * 0.5 + 16,
                    child: parseBold(title),
                  ),

                  Positioned(
                    bottom: 24,
                    left: 24,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          SmoothPageRoute(
                            page: OnboardingPage3(language: language),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFE86A8D), width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFE86A8D),
                        size: 24,
                      ),
                    ),
                  ),

                  // NEXT → disabled for now
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: ElevatedButton(
                      onPressed: null, // disabled
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: const Color(0xFFE86A8D).withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}Widget parseBold(String text) {
  final regex = RegExp(r'\[b\](.*?)\[/b\]', dotAll: true, unicode: true);
  final spans = <TextSpan>[];
  int currentIndex = 0;

  // Detect Urdu (Arabic script)
  final isUrdu = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  final isRoman = !isUrdu && RegExp(r'[a-zA-Z]').hasMatch(text);

  // Font sizes
  final normalFontSize = isUrdu ? 22.0 : (isRoman ? 17.0 : 24.0);
  final boldFontSize = isUrdu ? 26.0 : (isRoman ? 20.0 : 30.0);

  for (final match in regex.allMatches(text)) {
    // Normal text before bold
    if (match.start > currentIndex) {
      spans.add(TextSpan(
        text: text.substring(currentIndex, match.start),
        style: TextStyle(
          fontSize: normalFontSize,
          height: 1.2,
          fontWeight: FontWeight.w500,
          fontFamily: 'Edu',
          color: Color(0xFF8B5E3C),
        ),
      ));
    }

    // Bold text
    spans.add(TextSpan(
      text: match.group(1),
      style: TextStyle(
        fontSize: boldFontSize,
        height: 1.5,
        fontWeight: FontWeight.w700,
        fontFamily: 'Edu',
        color: Color(0xFF8B5E3C),
      ),
    ));

    currentIndex = match.end;
  }

  // Any remaining text after last bold
  if (currentIndex < text.length) {
    spans.add(TextSpan(
      text: text.substring(currentIndex),
      style: TextStyle(
        fontSize: normalFontSize,
        height: 1.2,
        fontWeight: FontWeight.w500,
        fontFamily: 'Edu',
        color: Color(0xFF8B5E3C),
      ),
    ));
  }

  return RichText(
    textAlign: TextAlign.center,
    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
    text: TextSpan(children: spans),
  );
}
