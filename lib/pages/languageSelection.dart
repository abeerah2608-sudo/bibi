import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/bloc_exports.dart';
import '../services/remote_asset_service.dart';
import 'onboarding_flow_dynamic.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? _selectedLanguage;
  bool _showWarning = false;
  Map<String, dynamic>? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConfig();
  }

  Future<void> _fetchConfig() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('language_selection')
          .doc('language_selection1')
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _config = _deepConvert(doc.data()!);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ LanguageSelectionPage: failed to fetch config: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _deepConvert(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      if (value is Map) return MapEntry(key.toString(), _deepConvert(value));
      if (value is List) return MapEntry(key.toString(), _deepConvertList(value));
      return MapEntry(key.toString(), value);
    });
  }

  List<dynamic> _deepConvertList(List<dynamic> list) {
    return list.map((value) {
      if (value is Map) return _deepConvert(value);
      if (value is List) return _deepConvertList(value);
      return value;
    }).toList();
  }

  String _t(String key, {String fallback = ''}) {
    if (_config == null) return fallback;
    final translations = _config!['translations'] as Map<String, dynamic>?;
    if (translations == null) return fallback;
    final entry = translations[key];
    if (entry is Map<String, dynamic>) {
      return (entry['English'] ?? fallback).toString();
    }
    return entry?.toString() ?? fallback;
  }

  Color _color(String key, Color fallback) {
    final colors = _config?['colors'] as Map<String, dynamic>?;
    final val = colors?[key]?.toString();
    if (val == null || val.isEmpty) return fallback;
    try {
      return Color(int.parse(val.replaceFirst('#', '0xff')));
    } catch (_) {
      return fallback;
    }
  }

  double _layout(String key, double fallback) {
    final layout = _config?['layout'] as Map<String, dynamic>?;
    final val = layout?[key];
    if (val is num) return val.toDouble();
    return fallback;
  }

  double _textSize(String key, double fallback) {
    final textStyle = _config?['textStyle'] as Map<String, dynamic>?;
    final val = textStyle?[key];
    if (val is num) return val.toDouble();
    return fallback;
  }

  List<Map<String, dynamic>> get _languageOptions {
    final options = _config?['languageOptions'] as List<dynamic>?;
    if (options == null) {
      return [
        {'displayName': 'English', 'value': 'English', 'order': 1},
        {'displayName': 'اردو', 'value': 'اردو', 'order': 2},
        {'displayName': 'Roman Urdu', 'value': 'Roman Urdu', 'order': 3},
      ];
    }
    final list = options.whereType<Map<String, dynamic>>().toList();
    list.sort((a, b) => ((a['order'] as num?) ?? 0).compareTo((b['order'] as num?) ?? 0));
    return list;
  }

  void _handleContinue() {
    if (_selectedLanguage == null) {
      setState(() => _showWarning = true);
      return;
    }
    context.read<LanguageBloc>().add(SelectLanguageEvent(_selectedLanguage!));
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const OnboardingFlowDynamic()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          color: const Color(0xFFFFF4F4),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFE86A8D)),
          ),
        ),
      );
    }

    final bgColor = _color('backgroundColor', const Color(0xFFFFF4F4));
    final titleColor = _color('titleColor', const Color(0xFF8B5E3C));
    final selectedBorder = _color('selectedBorderColor', const Color(0xFFE85B99));
    final unselectedBorder = _color('unselectedBorderColor', const Color(0xFFE8D5DC));
    final optionBg = _color('optionBackgroundColor', const Color(0xFFFFF4F8));
    final buttonBg = _color('buttonBackgroundColor', const Color(0xFFE86A8D));
    final buttonText = _color('buttonTextColor', Colors.white);
    final warningBg = _color('warningBackgroundColor', const Color(0xFFFFEBEE));
    final warningBorder = _color('warningBorderColor', const Color(0xFFE86A8D));
    final warningText = _color('warningTextColor', const Color(0xFFE86A8D));

    final logoHeight = _layout('logoHeight', 150);
    final logoWidth = _layout('logoWidth', 150);
    final borderRadius = _layout('borderRadius', 18);
    final buttonBorderRadius = _layout('buttonBorderRadius', 24);
    final warningBorderRadius = _layout('warningBorderRadius', 12);
    final selectedRadioBorder = _layout('selectedRadioButtonBorderWidth', 6);
    final unselectedRadioBorder = _layout('unselectedRadioButtonBorderWidth', 2);
    final radioSize = _layout('radioButtonSize', 24);

    final logoUrl = _config?['logoImage']?.toString() ?? '';

    return Scaffold(
      body: Container(
        color: bgColor,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  if (logoUrl.isNotEmpty)
                    Image.network(
                      RemoteAssetService.convertGsUrlToHttps(logoUrl),
                      height: logoHeight.h,
                      width: logoWidth.w,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/Bibi_Logo_Vector 1.png',
                        height: logoHeight.h,
                        width: logoWidth.w,
                      ),
                    )
                  else
                    Image.asset(
                      'assets/images/Bibi_Logo_Vector 1.png',
                      height: logoHeight.h,
                      width: logoWidth.w,
                    ),

                  SizedBox(height: 24.h),

                  Text(
                    _t('title', fallback: 'Choose Language'),
                    style: TextStyle(
                      fontSize: _textSize('titleFontSize', 24).sp,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _t('subtitle', fallback: 'Select the language you prefer'),
                    style: TextStyle(
                      fontSize: _textSize('subtitleFontSize', 12).sp,
                      color: titleColor.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Warning
                  if (_showWarning)
                    Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: warningBg,
                        borderRadius: BorderRadius.circular(warningBorderRadius.r),
                        border: Border.all(
                          color: warningBorder,
                          width: _layout('warningBorderWidth', 1.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: warningBorder, size: 24.sp),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              _t('warningMessage', fallback: 'Please select a language to continue'),
                              style: TextStyle(
                                fontSize: _textSize('warningFontSize', 13).sp,
                                fontWeight: FontWeight.w600,
                                color: warningText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Language options
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _languageOptions.map((option) {
                      final value = option['value']?.toString() ?? '';
                      final displayName = option['displayName']?.toString() ?? value;
                      final isSelected = _selectedLanguage == value;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedLanguage = isSelected ? null : value;
                            _showWarning = false;
                          }),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? selectedBorder : unselectedBorder,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(borderRadius.r),
                              color: optionBg,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: _textSize('optionFontSize', 16).sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF333333),
                                  ),
                                ),
                                Container(
                                  width: radioSize.w,
                                  height: radioSize.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? selectedBorder : unselectedBorder,
                                      width: isSelected ? selectedRadioBorder : unselectedRadioBorder,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 100.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonBg,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonBorderRadius.r),
                        ),
                      ),
                      child: Text(
                        _t('continueButton', fallback: 'Continue'),
                        style: TextStyle(
                          fontSize: _textSize('buttonFontSize', 16).sp,
                          fontWeight: FontWeight.w600,
                          color: buttonText,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    _t('settingsNote', fallback: 'You can change this later in settings'),
                    style: TextStyle(
                      fontSize: _textSize('settingsNoteFontSize', 11).sp,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
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