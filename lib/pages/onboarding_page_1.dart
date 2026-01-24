import 'package:flutter/material.dart';
import '../services/language_strings.dart';
import 'onboarding_page_2.dart';

class OnboardingPage1 extends StatelessWidget {
  final String language;

  const OnboardingPage1({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final title = LanguageStrings.getTranslation(language, 'assalam_o_alaikum');
    final isUrdu = language == 'اردو';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
           color: Color(0xFFFFF4F4),
        ),
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
                  // Image aligned to left edge, slightly above center
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset(0, -40),
                      child: Image.asset(
                        'assets/images/ms_bibi.png',
                        height: 450,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Text on top of image, in blank space
                  Positioned(
                    top: 150,
                    left: MediaQuery.of(context).size.width * 0.5 + 16,
                    right: 16,
                    child: Directionality(
                      textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Edu',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8B5E3C),
                        ),
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
          builder: (context) => OnboardingPage2(language: language),
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFE86A8D),
      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20 ),
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
