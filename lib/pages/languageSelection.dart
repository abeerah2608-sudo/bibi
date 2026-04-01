import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import 'onboarding_page_1.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color : Color(0xFFFFF4F4),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // BIBI Logo
                  Image.asset(
                    'assets/images/Bibi_Logo_Vector 1.png',
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(height: 24),
                  // Title
                  Text(
                    'Choose Language',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5E3C),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Select the language you prefer',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xB38B5E3C),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Language Selection Options
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // English Option
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLanguage = _selectedLanguage == 'English' ? null : 'English';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedLanguage == 'English'
                                  ? Color(0xFFE85B99)
                                  : Color(0xFFE8D5DC),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            color: Color(0xFFFFF4F8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'English',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: _selectedLanguage == 'English'
                                        ? Color(0xFFE85B99)
                                        : Color(0xFFE8D5DC),
                                    width: _selectedLanguage == 'English' ? 6 : 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Urdu Option
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLanguage = _selectedLanguage == 'اردو' ? null : 'اردو';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedLanguage == 'اردو'
                                  ? Color(0xFFE85B99)
                                  : Color(0xFFE8D5DC),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            color: Color(0xFFFFF4F8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'اردو',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: _selectedLanguage == 'اردو'
                                        ? Color(0xFFE85B99)
                                        : Color(0xFFE8D5DC),
                                    width: _selectedLanguage == 'اردو' ? 6 : 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Roman Urdu Option
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLanguage = _selectedLanguage == 'Roman Urdu' ? null : 'Roman Urdu';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedLanguage == 'Roman Urdu'
                                  ? Color(0xFFE85B99)
                                  : Color(0xFFE8D5DC),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            color: Color(0xFFFFF4F8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Roman Urdu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: _selectedLanguage == 'Roman Urdu'
                                        ? Color(0xFFE85B99)
                                        : Color(0xFFE8D5DC),
  width: _selectedLanguage == 'Roman Urdu' ? 6 : 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 100),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedLanguage != null) {
                          context.read<LanguageBloc>().add(
                                SelectLanguageEvent(_selectedLanguage!),
                              );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const OnboardingPage1(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE86A8D),

                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Security Note
                  Text(
                    'You can change this later in settings',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B5E3C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
