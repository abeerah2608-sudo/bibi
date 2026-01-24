import 'package:flutter/material.dart';
import '../services/language_strings.dart';
import 'onboarding_page_2.dart'; 
import 'onboarding_page_4.dart'; 

class OnboardingPage3 extends StatelessWidget {
  final String language;

  const OnboardingPage3({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final title = LanguageStrings.getTranslation(language, 'breast_cancer');

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
                  // Image aligned to left edge
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset(0, -40), // slightly higher
                      child: Image.asset(
                        'assets/images/ms_bibi.png',
                        height: 450,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Text on right side
                  Positioned(
                    top: 150,
                    left: MediaQuery.of(context).size.width * 0.5 + 16, // start around middle
                    right: 16, // small right margin
                    child: parseBold(title),
                  ),

                  // Previous button (bottom-left)
                  Positioned(
                    bottom: 24,
                    left: 24,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OnboardingPage2(language: language),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // white background
                        side: BorderSide(color: Color(0xFFE86A8D), width: 2), // pink outline
                        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(0xFFE86A8D), // pink arrow
                        size: 24,
                      ),
                    ),
                  ),

                  // Next button (bottom-right)
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OnboardingPage4(language: language),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE86A8D), // pink filled
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
}
Widget parseBold(String text) {
  final regex = RegExp(r'\[b\](.*?)\[/b\]', dotAll: true, unicode: true);
  final spans = <TextSpan>[];
  int currentIndex = 0;

  for (final match in regex.allMatches(text)) {
    // Normal text before bold
    if (match.start > currentIndex) {
      spans.add(TextSpan(
        text: text.substring(currentIndex, match.start),
        style: TextStyle(
          fontSize: 24,
          height: 1.2,
          fontWeight: FontWeight.w500,
          fontFamily: 'Edu',
          color: Color(0xFF8B5E3C),
        ),
      ));
      spans.add(const TextSpan(text: '\n')); 
    }

    // Bold text
    spans.add(TextSpan(
      text: match.group(1),
      style: TextStyle(
        fontSize: 30,
        height: 1.5, // line height for bold
        fontWeight: FontWeight.w700,
        fontFamily: 'Edu',
        color: Color(0xFF8B5E3C),
      ),
    ));

    currentIndex = match.end;
  }

  // Any remaining text after last bold
  if (currentIndex < text.length) {
    spans.add(const TextSpan(text: '\n'));
    spans.add(TextSpan(
      text: text.substring(currentIndex),
      style: TextStyle(
        fontSize: 32,
        height: 1.2,
        fontWeight: FontWeight.w500,
        fontFamily: 'Edu',
        color: Color(0xFF8B5E3C),
      ),
    ));
  }

  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(children: spans),
  );
}
