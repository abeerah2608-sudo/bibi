import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dashboard.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final Future<Map<String, dynamic>?> _configFuture;
  String _currentLanguage = 'English'; // Default language

  @override
  void initState() {
    super.initState();
    _configFuture = _loadConfig();
  }

  Future<Map<String, dynamic>?> _loadConfig() async {
    try {
      // Fetch main privacy policy config
      final snapshot = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('privacy_policy')
          .get();
      
      if (!snapshot.exists) return null;
      
      final config = snapshot.data();
      if (config == null) return null;
      
      // Fetch sections subcollection
      final sectionsSnapshot = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('privacy_policy')
          .collection('sections')
          .get();
      
      // Add sections to config
      final sections = <Map<String, dynamic>>[];
      for (var doc in sectionsSnapshot.docs) {
        final sectionData = doc.data();
        sectionData['id'] = doc.id; // Ensure ID is included
        sections.add(sectionData);
      }
      
      // Sort sections by number if available
      sections.sort((a, b) {
        final aNum = a['number'];
        final bNum = b['number'];
        if (aNum is int && bNum is int) return aNum.compareTo(bNum);
        if (aNum is String && bNum is String) {
          final aParsed = int.tryParse(aNum) ?? 0;
          final bParsed = int.tryParse(bNum) ?? 0;
          return aParsed.compareTo(bParsed);
        }
        return 0;
      });
      
      config['sections'] = sections;
      return config;
    } catch (e) {
      debugPrint('Error loading privacy policy config: $e');
      return null;
    }
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  double _double(dynamic value, [double fallback = 0.0]) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  Color _color(dynamic value, Color fallback) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return fallback;
    try {
      return Color(int.parse(text.replaceFirst('#', '0xff')));
    } catch (_) {
      return fallback;
    }
  }

  FontWeight _weight(dynamic value, {FontWeight fallback = FontWeight.w400}) {
    switch (value?.toString().toLowerCase()) {
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
      case 'normal':
        return FontWeight.w400;
      case 'w500':
      case 'medium':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
      case 'bold':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      default:
        return fallback;
    }
  }

  TextAlign _align(dynamic value, {TextAlign fallback = TextAlign.left}) {
    switch (value?.toString().toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      case 'start':
        return TextAlign.start;
      case 'end':
        return TextAlign.end;
      default:
        return fallback;
    }
  }

  String _translate(dynamic translations) {
    if (translations is String) return translations;
    if (translations is Map) {
      final map = _map(translations);
      return map[_currentLanguage]?.toString() ?? 
             map['English']?.toString() ?? 
             '';
    }
    return '';
  }

  Widget _bullet(String shape, Color color, double size) {
    if (shape.toLowerCase() == 'square') {
      return Container(width: size, height: size, color: color);
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _bodyText(Map<String, dynamic> styles, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: _double(styles['bodyFontSize'], 12.5).sp,
        color: _color(styles['bodyColor'], const Color(0xFF444444)),
        height: _double(styles['bodyLineHeight'], 1.6),
      ),
    );
  }

  Widget _bulletList(Map<String, dynamic> styles, List<dynamic> items) {
    final bulletColor = _color(styles['bulletColor'], const Color(0xFF444444));
    final bulletShape = styles['bulletShape']?.toString() ?? 'circle';
    final bulletSize = _double(styles['bulletSize'], 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 5.h, right: 8.w),
                    child: _bullet(bulletShape, bulletColor, bulletSize),
                  ),
                  Expanded(
                    child: Text(
                      _translate(item),
                      style: TextStyle(
                        fontSize: _double(styles['bodyFontSize'], 12.5).sp,
                        color: _color(styles['bodyColor'], const Color(0xFF444444)),
                        height: _double(styles['bodyLineHeight'], 1.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _renderSection(Map<String, dynamic> section, Map<String, dynamic> textStyles) {
    final type = section['type']?.toString() ?? 'text';
    final title = _translate(section['title']);
    final number = section['number'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              '$number. $title',
              style: TextStyle(
                fontSize: _double(textStyles['bodyFontSize'], 12.5).sp + 2,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE8677A),
                height: 1.4,
              ),
            ),
          ),
        
        // Body text if present
        if (section['body'] != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _bodyText(textStyles, _translate(section['body'])),
          ),

        // Render based on type
        if (type == 'bullets' && section['items'] != null)
          _bulletList(textStyles, section['items'] as List),
        
        if (type == 'table')
          _renderTable(section['table']),
        
        if (type == 'mixed')
          _renderMixedSection(section, textStyles),
        
        if (type == 'qa_cards')
          _renderQACards(section),
        
        if (type == 'contact')
          _renderContactInfo(section),

        // Render subsections if present
        if (section['subsections'] != null)
          ...(section['subsections'] as List).map((subsection) => 
            Padding(
              padding: EdgeInsets.only(top: 12.h, left: 16.w),
              child: _renderSection(_map(subsection), textStyles),
            ),
          ),

        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _renderTable(dynamic tableData) {
    if (tableData == null) return const SizedBox.shrink();
    
    final table = _map(tableData);
    final columns = _map(table['columns']);
    final rows = table['rows'] as List? ?? [];
    
    final columnHeaders = columns[_currentLanguage] as List? ?? 
                         columns['English'] as List? ?? 
                         [];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.1),
            1: FlexColumnWidth(0.6),
            2: FlexColumnWidth(1.8),
          },
          border: TableBorder(
            horizontalInside: BorderSide(color: const Color(0xFFDDDDDD), width: 1),
          ),
          children: [
            // Header row
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFFFE4EC)),
              children: columnHeaders.map((header) => _cell(header.toString(), header: true)).toList(),
            ),
            // Data rows
            ...rows.asMap().entries.map((entry) {
              final row = _map(entry.value);
              final isEven = entry.key % 2 == 0;
              
              return TableRow(
                decoration: BoxDecoration(
                  color: isEven ? const Color(0xFFFFF6F7) : Colors.white,
                ),
                children: [
                  _cell(_translate(row['dataType'])),
                  _cell(_translate(row['collected'])),
                  _cell(_translate(row['purpose'])),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _renderMixedSection(Map<String, dynamic> section, Map<String, dynamic> textStyles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section['items'] != null)
          _bulletList(textStyles, section['items'] as List),
        
        if (section['note'] != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              _translate(section['note']),
              style: TextStyle(
                fontSize: _double(textStyles['bodyFontSize'], 12.5).sp,
                color: const Color(0xFFE8677A),
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
            ),
          ),
      ],
    );
  }

  Widget _renderQACards(Map<String, dynamic> section) {
    final items = section['items'] as List? ?? [];
    final cardStyle = _map(section['cardStyle']);
    
    return Column(
      children: items.map((item) {
        final qa = _map(item);
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(_double(cardStyle['padding'], 16).w),
          decoration: BoxDecoration(
            color: _color(cardStyle['backgroundColor'], const Color(0xFFFCE4EC)),
            borderRadius: BorderRadius.circular(_double(cardStyle['borderRadius'], 12).r),
            border: Border.all(
              color: _color(cardStyle['selectedBorderColor'], const Color(0xFFE86A8D)),
              width: _double(cardStyle['selectedBorderWidth'], 2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _translate(qa['question']),
                style: TextStyle(
                  fontSize: _double(cardStyle['questionFontSize'], 14).sp,
                  fontWeight: _weight(cardStyle['questionFontWeight'], fallback: FontWeight.w600),
                  color: _color(cardStyle['questionColor'], const Color(0xFF5D3A3A)),
                ),
              ),
              SizedBox(height: _double(cardStyle['spacing'], 12).h),
              Text(
                _translate(qa['answer']),
                style: TextStyle(
                  fontSize: _double(cardStyle['answerFontSize'], 13).sp,
                  color: _color(cardStyle['answerColor'], const Color(0xFF7A5050)),
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _renderContactInfo(Map<String, dynamic> section) {
    final fields = _map(section['fields']);
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F7),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE8677A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fields.entries.map((entry) {
          final field = _map(entry.value);
          final label = _translate(field['label']);
          final value = _translate(field['value']);
          
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF333333)),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: value),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _cell(String text, {bool header = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFF333333),
          fontWeight: header ? FontWeight.w600 : FontWeight.w400,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> config) {
    final appBarConfig = _map(config['appBarConfig']);
    final headerSection = _map(config['headerSection']);
    final platformCard = _map(config['platformCard']);
    final shieldIcon = _map(config['shieldIcon']);
    final disclaimerBanner = _map(config['disclaimerBanner']);
    final textStyles = _map(config['textStyles']);
    final sections = config['sections'] as List? ?? [];
    final footer = _map(config['footer']);

    final backgroundColor = _color(config['backgroundColor'], Colors.white);
    final appBarBackground = _color(appBarConfig['backgroundColor'], const Color(0xFFE8677A));
    final appBarTitle = _translate(appBarConfig['title']);
    final appBarTitleColor = _color(appBarConfig['titleColor'], Colors.white);
    final appBarTitleSize = _double(appBarConfig['titleFontSize'], 18).sp;
    final appBarTitleWeight = _weight(appBarConfig['titleFontWeight'], fallback: FontWeight.w600);
    final backIconColor = _color(appBarConfig['backIconColor'], Colors.white);
    final backIconSize = _double(appBarConfig['backIconSize'], 22).sp;
    final appBarElevation = _double(appBarConfig['elevation'], 0);
    final centerTitle = appBarConfig['centerTitle'] != false;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBackground,
        elevation: appBarElevation,
        centerTitle: centerTitle,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: backIconColor, size: backIconSize),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            }
          },
        ),
        title: Text(
          appBarTitle,
          style: TextStyle(
            color: appBarTitleColor,
            fontSize: appBarTitleSize,
            fontWeight: appBarTitleWeight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section (if configured)
            if (headerSection.isNotEmpty) _buildHeaderSection(headerSection, platformCard, shieldIcon),
            
            // Disclaimer banner (if configured)
            if (disclaimerBanner.isNotEmpty) _buildDisclaimerBanner(disclaimerBanner),
            
            // Dynamic sections from Firebase
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...sections.map((section) => _renderSection(_map(section), textStyles)),
                  
                  // Continue to Dashboard button
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8677A),
                        minimumSize: Size(double.infinity, 48.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DashboardScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Continue to Dashboard",
                        style: TextStyle(fontSize: 14.sp, color: Colors.white),
                      ),
                    ),
                  ),
                  
                  // Footer
                  if (footer.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Text(
                        _translate(footer['message']),
                        textAlign: _align(footer['textAlign'], fallback: TextAlign.center),
                        style: TextStyle(
                          fontSize: _double(footer['fontSize'], 14).sp,
                          fontWeight: _weight(footer['fontWeight'], fallback: FontWeight.w600),
                          color: _color(footer['color'], const Color(0xFFE8677A)),
                        ),
                      ),
                    ),
                  
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> headerSection, Map<String, dynamic> platformCard, Map<String, dynamic> shieldIcon) {
    final headerBackground = _color(headerSection['backgroundColor'], const Color(0xFFE8677A));
    final shieldBackground = _color(shieldIcon['backgroundColor'], const Color(0xFFD45068));
    final shieldSize = _double(shieldIcon['containerSize'], 70).w;
    final shieldIconColor = _color(shieldIcon['iconColor'], Colors.white);
    final shieldIconSize = _double(shieldIcon['iconSize'], 32).sp;
    final shieldType = shieldIcon['iconType']?.toString() ?? 'lock';

    final platformBackground = _color(platformCard['backgroundColor'], const Color(0xFFD45068));
    final platformRadius = BorderRadius.circular(_double(platformCard['borderRadius'], 8).r);
    final platformMargin = _double(platformCard['horizontalMargin'], 40).w;
    final platformHorizontalPadding = _double(platformCard['horizontalPadding'], 16).w;
    final platformVerticalPadding = _double(platformCard['verticalPadding'], 10).h;
    final platformTextColor = _color(platformCard['textColor'], Colors.white);
    final platformFontSize = _double(platformCard['fontSize'], 12).sp;
    final platformFontWeight = _weight(platformCard['fontWeight'], fallback: FontWeight.w500);
    final platformTextAlign = _align(platformCard['textAlign'], fallback: TextAlign.center);
    final platformText = platformCard['platformText']?.toString() ?? 'Platform: Android (Google Play Store only)';
    final effectiveDate = platformCard['effectiveDate']?.toString() ?? 'Effective Date: 1 April 2026';

    return Container(
      width: double.infinity,
      color: headerBackground,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        children: [
          Container(
            width: shieldSize,
            height: shieldSize,
            decoration: BoxDecoration(
              color: shieldBackground,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                shieldType == 'lock' ? Icons.lock : Icons.shield,
                color: shieldIconColor,
                size: shieldIconSize,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: platformMargin),
            padding: EdgeInsets.symmetric(
              horizontal: platformHorizontalPadding,
              vertical: platformVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: platformBackground,
              borderRadius: platformRadius,
            ),
            child: Column(
              children: [
                Text(
                  platformText,
                  textAlign: platformTextAlign,
                  style: TextStyle(
                    color: platformTextColor,
                    fontSize: platformFontSize,
                    fontWeight: platformFontWeight,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  effectiveDate,
                  textAlign: platformTextAlign,
                  style: TextStyle(
                    color: platformTextColor,
                    fontSize: platformFontSize,
                    fontWeight: platformFontWeight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerBanner(Map<String, dynamic> disclaimerBanner) {
    final disclaimerBackground = _color(disclaimerBanner['backgroundColor'], const Color(0xFFFFF0F2));
    final disclaimerBorderColor = _color(disclaimerBanner['borderColor'], const Color(0xFFE8677A));
    final disclaimerBorderRadius = BorderRadius.circular(_double(disclaimerBanner['borderRadius'], 8).r);
    final disclaimerBorderWidth = _double(disclaimerBanner['borderWidth'], 1.2);
    final disclaimerMargin = _double(disclaimerBanner['margin'], 16).w;
    final disclaimerHorizontalPadding = _double(disclaimerBanner['horizontalPadding'], 14).w;
    final disclaimerVerticalPadding = _double(disclaimerBanner['verticalPadding'], 12).h;
    final disclaimerText = disclaimerBanner['text']?.toString() ??
        'BIBI – Breast Cancer Awareness App is an educational awareness app and not a medical diagnosis or treatment service.';
    final disclaimerTextColor = _color(disclaimerBanner['textColor'], const Color(0xFF333333));
    final disclaimerFontSize = _double(disclaimerBanner['fontSize'], 12).sp;
    final disclaimerTextAlign = _align(disclaimerBanner['textAlign'], fallback: TextAlign.center);
    final disclaimerLineHeight = _double(disclaimerBanner['lineHeight'], 1.5);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(disclaimerMargin),
      padding: EdgeInsets.symmetric(
        horizontal: disclaimerHorizontalPadding,
        vertical: disclaimerVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: disclaimerBackground,
        border: Border.all(color: disclaimerBorderColor, width: disclaimerBorderWidth),
        borderRadius: disclaimerBorderRadius,
      ),
      child: Text(
        disclaimerText,
        textAlign: disclaimerTextAlign,
        style: TextStyle(
          fontSize: disclaimerFontSize,
          color: disclaimerTextColor,
          height: disclaimerLineHeight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _configFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFF4F4),
            body: SafeArea(
              child: Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFFE8677A),
                  strokeWidth: 2.5.w,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _fallback('Unable to load privacy policy.');
        }

        final config = snapshot.data;
        if (config == null || config.isEmpty) {
          return _fallback('Privacy policy configuration is missing.');
        }

        return _buildPage(config);
      },
    );
  }

  Widget _fallback(String message) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8677A),
        centerTitle: true,
        title: const Text('Privacy Policy'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF444444)),
          ),
        ),
      ),
    );
  }
}