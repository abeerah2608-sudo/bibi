import 'package:flutter/material.dart';
import '../services/language_strings.dart';
import 'onboarding_page_3.dart';
import 'onboarding_page_1.dart';

class OnboardingPage2 extends StatelessWidget {
  final String language;

  const OnboardingPage2({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final title = LanguageStrings.getTranslation(language, 'im_bibi');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFFFF4F4),
        child: Column(
          children: [
            SizedBox(height: 60),

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
                        offset: Offset(0, -40),
                        child: Image.asset(
                          'assets/images/ms_bibi.png',
                          height: 450,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 165,
                    left: 16,
                    right: MediaQuery.of(context).size.width * 0.5 + 16,
                    child: parseBold(title),
                    
                  ),

                  Positioned(
                    bottom: 24,
                    left: 24,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OnboardingPage1(language: language),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Color(0xFFE86A8D), width: 2),
                        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(0xFFE86A8D),
                        size: 24,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OnboardingPage3(language: language),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE86A8D),
                        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Icon(
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

  for (final match in regex.allMatches(text)) {
    if (match.start > currentIndex) {
      spans.add(TextSpan(
        text: text.substring(currentIndex, match.start),
        style: TextStyle(
          fontSize: 32,
          height : 0.2,
          fontWeight: FontWeight.w500,
          fontFamily: 'Edu',
          color: Color(0xFF8B5E3C),
        ),
      ));
      spans.add(const TextSpan(text: '\n')); // line break before bold
    }

    // Bold 
    spans.add(TextSpan(
      text: match.group(1)! + text.substring(match.end),
      style: TextStyle(
        fontSize: 46,
        height: 1.5,
        fontWeight: FontWeight.w700,
        fontFamily: 'Edu',
        color: Color(0xFF8B5E3C),
      ),
    ));

    currentIndex = text.length;
    break; 
  }

  return RichText(
    textAlign: TextAlign.center,
    textDirection: TextDirection.rtl,
    text: TextSpan(children: spans),
  );
}
