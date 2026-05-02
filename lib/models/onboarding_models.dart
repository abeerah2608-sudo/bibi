import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
Map<String, dynamic> _deepStringMap(Map<dynamic, dynamic> map) {
  return map.map((key, value) {
    if (value is Map) return MapEntry(key.toString(), _deepStringMap(value));
    if (value is List) return MapEntry(key.toString(), _deepStringList(value));
    return MapEntry(key.toString(), value);
  });
}

List<dynamic> _deepStringList(List<dynamic> list) {
  return list.map((value) {
    if (value is Map) return _deepStringMap(value);
    if (value is List) return _deepStringList(value);
    return value;
  }).toList();
}
/// Model for animation configuration
class AnimationConfig extends Equatable {
  final double scale;
  final double translateXPercent;
  final double translateYPercent;
  final String alignment;

  const AnimationConfig({
    required this.scale,
    required this.translateXPercent,
    required this.translateYPercent,
    required this.alignment,
  });

  factory AnimationConfig.fromJson(Map<String, dynamic> json) {
    double parseScale(dynamic v) {
      if (v == null) return 1.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.trim()) ?? 1.0;
      return 1.0;
    }

    return AnimationConfig(
      scale: parseScale(json['scale']),
      translateXPercent: (json['translateXPercent'] as num?)?.toDouble() ?? 0.0,
      translateYPercent: (json['translateYPercent'] as num?)?.toDouble() ?? 0.0,
      alignment: json['alignment'] as String? ?? 'center',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scale': scale,
      'translateXPercent': translateXPercent,
      'translateYPercent': translateYPercent,
      'alignment': alignment,
    };
  }

  Alignment getAlignment() {
  switch (alignment.toLowerCase()) {
    case 'centerleft':
    case 'center_left':        // ← Firestore uses this
      return Alignment.centerLeft;
    case 'centerright':
    case 'center_right':
      return Alignment.centerRight;
    case 'topcenter':
    case 'top_center':
      return Alignment.topCenter;
    case 'bottomcenter':
    case 'bottom_center':
      return Alignment.bottomCenter;
    default:
      return Alignment.center;
  }
}

  @override
  List<Object?> get props => [scale, translateXPercent, translateYPercent, alignment];
}

/// Model for text style configuration
class TextStyleConfig extends Equatable {
  final String? color;
  final double? fontSize;
  final String? fontWeight;
  final String? textAlign;
  final String? titleColor;
  final String? titleFontFamily;
  final double? titleFontSize;
  final String? titleFontWeight;
  final String? titleTextAlign;
  final double? titleHorizontalPadding;
  final double? subtitleFontSize;
  final double? bottomTitleFontSize;
  final String? labelColor;
  final String? labelFontFamily;
  final double? labelFontSize;
  final String? labelFontWeight;
  final double? labelLineHeight;
  final String? labelTextAlign;

  const TextStyleConfig({
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.titleColor,
    this.titleFontFamily,
    this.titleFontSize,
    this.titleFontWeight,
    this.titleTextAlign,
    this.titleHorizontalPadding,
    this.subtitleFontSize,
    this.bottomTitleFontSize,
    this.labelColor,
    this.labelFontFamily,
    this.labelFontSize,
    this.labelFontWeight,
    this.labelLineHeight,
    this.labelTextAlign,
  });

  factory TextStyleConfig.fromJson(Map<String, dynamic> json) {
    return TextStyleConfig(
      color: json['color'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      fontWeight: json['fontWeight'] as String?,
      textAlign: json['textAlign'] as String?,
      titleColor: json['titleColor'] as String?,
      titleFontFamily: json['titleFontFamily'] as String?,
      titleFontSize: (json['titleFontSize'] as num?)?.toDouble(),
      titleFontWeight: json['titleFontWeight'] as String?,
      titleTextAlign: json['titleTextAlign'] as String?,
      titleHorizontalPadding: (json['titleHorizontalPadding'] as num?)?.toDouble(),
      subtitleFontSize: (json['subtitleFontSize'] as num?)?.toDouble(),
      bottomTitleFontSize: (json['bottomTitleFontSize'] as num?)?.toDouble(),
      labelColor: json['labelColor'] as String?,
      labelFontFamily: json['labelFontFamily'] as String?,
      labelFontSize: (json['labelFontSize'] as num?)?.toDouble(),
      labelFontWeight: json['labelFontWeight'] as String?,
      labelLineHeight: (json['labelLineHeight'] as num?)?.toDouble(),
      labelTextAlign: json['labelTextAlign'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'fontSize': fontSize,
      'fontWeight': fontWeight,
      'textAlign': textAlign,
      'titleColor': titleColor,
      'titleFontFamily': titleFontFamily,
      'titleFontSize': titleFontSize,
      'titleFontWeight': titleFontWeight,
      'titleTextAlign': titleTextAlign,
      'titleHorizontalPadding': titleHorizontalPadding,
      'subtitleFontSize': subtitleFontSize,
      'bottomTitleFontSize': bottomTitleFontSize,
      'labelColor': labelColor,
      'labelFontFamily': labelFontFamily,
      'labelFontSize': labelFontSize,
      'labelFontWeight': labelFontWeight,
      'labelLineHeight': labelLineHeight,
      'labelTextAlign': labelTextAlign,
    };
  }

  @override
  List<Object?> get props => [
        color,
        fontSize,
        fontWeight,
        textAlign,
        titleColor,
        titleFontFamily,
        titleFontSize,
        titleFontWeight,
        titleTextAlign,
        titleHorizontalPadding,
        subtitleFontSize,
        bottomTitleFontSize,
        labelColor,
        labelFontFamily,
        labelFontSize,
        labelFontWeight,
        labelLineHeight,
        labelTextAlign,
      ];
}

class VideoCardConfig extends Equatable {
  final String? cardBackgroundColor;
  final String? duration;
  final String? favoriteId;
  final String? thumbnailImage;
  final String? videoUrl;

  const VideoCardConfig({
    this.cardBackgroundColor,
    this.duration,
    this.favoriteId,
    this.thumbnailImage,
    this.videoUrl,
  });

  factory VideoCardConfig.fromJson(Map<String, dynamic> json) {
    return VideoCardConfig(
      cardBackgroundColor: json['cardBackgroundColor'] as String?,
      duration: json['duration'] as String?,
      favoriteId: json['favoriteId'] as String?,
      thumbnailImage: json['thumbnailImage'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardBackgroundColor': cardBackgroundColor,
      'duration': duration,
      'favoriteId': favoriteId,
      'thumbnailImage': thumbnailImage,
      'videoUrl': videoUrl,
    };
  }

  @override
  List<Object?> get props => [
        cardBackgroundColor,
        duration,
        favoriteId,
        thumbnailImage,
        videoUrl,
      ];
}

class FoodItemConfig extends Equatable {
  final String id;
  final String asset;
  final String labelKey;
  final String position;
  final String circleColor;
  final double circleDiameter;
  final Map<String, String> translations;

  const FoodItemConfig({
    required this.id,
    required this.asset,
    required this.labelKey,
    required this.position,
    required this.circleColor,
    required this.circleDiameter,
    required this.translations,
  });

  factory FoodItemConfig.fromJson(Map<String, dynamic> json) {
    return FoodItemConfig(
      id: json['id'] as String? ?? '',
      asset: json['asset'] as String? ?? '',
      labelKey: json['labelKey'] as String? ?? '',
      position: json['position'] as String? ?? '',
      circleColor: json['circleColor'] as String? ?? '#F68AA8',
      circleDiameter: (json['circleDiameter'] as num?)?.toDouble() ?? 104,
      translations: Map<String, String>.from(
        (json['translations'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  @override
  List<Object?> get props => [id, asset, labelKey, position, circleColor, circleDiameter, translations];
}

/// Model for onboarding page data
class OnboardingPageData extends Equatable {
  final String id;
  final int order;
  final String textKey;
  final Map<String, String> translations;
  final Map<String, dynamic> rawData;
  final String? subtitleKey;
  final Map<String, String> titleTranslations;
  final Map<String, String> subtitleTranslations;
  final Map<String, String> watchNowTranslations;
  final String englishAudio;
  final String urduAudio;
  final String animationPath;
  final AnimationConfig animation;
  final String pageType;
  final TextStyleConfig textStyle;
  final String? layout;
  final bool repeat;
  final String? logoUrl;
  final String? backgroundImageUrl;
  final List<FoodItemConfig> foodItems;
  final String? backgroundColor;
  final VideoCardConfig? videoCard;

  const OnboardingPageData({
    required this.id,
    required this.order,
    required this.textKey,
    required this.translations,
    this.rawData = const {},
    this.subtitleKey,
    this.titleTranslations = const {},
    this.subtitleTranslations = const {},
    this.watchNowTranslations = const {},
    required this.englishAudio,
    required this.urduAudio,
    required this.animationPath,
    required this.animation,
    this.pageType = 'default',
    TextStyleConfig? textStyle,
    this.layout,
    this.repeat = true,
    this.logoUrl,
    this.backgroundImageUrl,
    this.foodItems = const [],
    this.backgroundColor,
    this.videoCard,
  }) : textStyle = textStyle ?? const TextStyleConfig();

factory OnboardingPageData.fromJson(Map<String, dynamic> json) {
  
  String? readString(dynamic value) {
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['asset'] as String? ??
          value['url'] as String? ??
          value['path'] as String?;
    }
    return null;
  }

  Map<String, String> readStringMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value.map((key, dynamicValue) => MapEntry(key, dynamicValue?.toString() ?? ''));
    }
    return const {};
  }

  final id = json['id'] as String? ?? '';
  final animationPath = json['animationPath'] as String? ?? '';
  final pageType = json['pageType'] as String? ?? '';
  final rawTranslations = (json['translations'] as Map<String, dynamic>?) ?? {};
  final hasNestedTranslations = rawTranslations.values.any((value) => value is Map);

  debugPrint("🧩 PARSED PAGE -> id: $id");
  debugPrint("🧩 animationPath: $animationPath");
  debugPrint("🧩 pageType: $pageType");

  // ✅ ADD THIS DEBUG LOGGING
  if (id == 'page_10') {
    debugPrint("🎥 PAGE_10 DEBUG:");
    debugPrint("  rawTranslations keys: ${rawTranslations.keys}");
    debugPrint("  hasNestedTranslations: $hasNestedTranslations");
    debugPrint("  title map: ${rawTranslations['title']}");
    debugPrint("  subtitle map: ${rawTranslations['subtitle']}");
    debugPrint("  watchNow map: ${rawTranslations['watchNow']}");
    
    final titleMap = readStringMap(rawTranslations['title']);
    final subtitleMap = readStringMap(rawTranslations['subtitle']);
    final watchNowMap = readStringMap(rawTranslations['watchNow']);
    
    debugPrint("  parsed titleTranslations: $titleMap");
    debugPrint("  parsed subtitleTranslations: $subtitleMap");
    debugPrint("  parsed watchNowTranslations: $watchNowMap");
    
    debugPrint("  videoCard raw: ${json['videoCard']}");
  }

  Map<String, dynamic> animationJson =
      (json['animation'] as Map<String, dynamic>?) ??
      (json['animationConfig'] as Map<String, dynamic>?) ??
      {};

  final audioJson = (json['audio'] as Map<String, dynamic>?) ?? {};
  
  return OnboardingPageData(
    id: json['id'] as String? ?? '',
    order: json['order'] as int? ?? 0,
    textKey: json['textKey'] as String? ?? '',
rawData: _deepStringMap(json),
    translations: hasNestedTranslations
        ? const {}
        : Map<String, String>.from(rawTranslations.map(
            (key, value) => MapEntry(key, value.toString()),
          )),
    subtitleKey: json['subtitleKey'] as String?,
    titleTranslations: readStringMap(rawTranslations['title']),
    subtitleTranslations: readStringMap(rawTranslations['subtitle']),
    watchNowTranslations: readStringMap(rawTranslations['watchNow']),
    englishAudio: json['englishAudio'] as String? ??
        audioJson['englishAudio'] as String? ??
        audioJson['English'] as String? ??
        '',
    urduAudio: json['urduAudio'] as String? ??
        audioJson['urduAudio'] as String? ??
        audioJson['Urdu'] as String? ??
        audioJson['اردو'] as String? ??
        '',
    animationPath: json['animationPath'] as String? ?? '',
    animation: AnimationConfig.fromJson(animationJson),
    pageType: json['pageType'] as String? ?? 'default',
    textStyle: TextStyleConfig.fromJson(
      (json['textStyle'] as Map<String, dynamic>?) ?? {},
    ),
    layout: readString(json['layout']) ??
        readString((json['animationConfig'] as Map<String, dynamic>?)?['layout']),
    repeat: ((json['animationConfig'] as Map<String, dynamic>?)?['repeat'] as bool?) ?? true,
    logoUrl: readString(json['logoUrl']) ??
        readString(json['logoPath']) ??
        readString(json['logo']),
    backgroundImageUrl: readString(json['backgroundImageUrl']) ??
        readString(json['backgroundImagePath']) ??
        readString(json['backgroundImage']) ??
        readString(json['backgroundUrl']),
    foodItems: (json['foodItems'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(FoodItemConfig.fromJson)
            .toList() ??
        const [],
    backgroundColor: readString(json['backgroundColor']),
    videoCard: (json['videoCard'] as Map<String, dynamic>?) == null
        ? null
        : VideoCardConfig.fromJson(json['videoCard'] as Map<String, dynamic>),
  );
}
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'textKey': textKey,
      'rawData': rawData,
      'translations': translations,
      'subtitleKey': subtitleKey,
      'titleTranslations': titleTranslations,
      'subtitleTranslations': subtitleTranslations,
      'watchNowTranslations': watchNowTranslations,
      'englishAudio': englishAudio,
      'urduAudio': urduAudio,
      'animationPath': animationPath,
      'animation': animation.toJson(),
      'pageType': pageType,
      'textStyle': textStyle.toJson(),
      'layout': layout,
      'repeat': repeat,
      'logoUrl': logoUrl,
      'backgroundImageUrl': backgroundImageUrl,
      'foodItems': foodItems.map((e) => {
        'id': e.id,
        'asset': e.asset,
        'labelKey': e.labelKey,
        'position': e.position,
        'circleColor': e.circleColor,
        'circleDiameter': e.circleDiameter,
        'translations': e.translations,
      }).toList(),
      'backgroundColor': backgroundColor,
      'videoCard': videoCard?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        order,
        textKey,
        rawData,
        translations,
        subtitleKey,
        titleTranslations,
        subtitleTranslations,
        watchNowTranslations,
        englishAudio,
        urduAudio,
        animationPath,
        animation,
        pageType,
        textStyle,
          logoUrl,
          backgroundImageUrl,
          foodItems,
          backgroundColor,
          videoCard,
        layout,
        repeat,
      ];
}

/// Model for onboarding flow configuration
class OnboardingFlowConfig extends Equatable {
  final List<OnboardingPageData> onboardingPages;

  const OnboardingFlowConfig({
    required this.onboardingPages,
  });

  factory OnboardingFlowConfig.fromJson(Map<String, dynamic> json) {

    final List<dynamic> pagesJson = json['onboarding_pages'] as List<dynamic>? ?? [];
    final pages = pagesJson
        .map((page) => OnboardingPageData.fromJson(page as Map<String, dynamic>))
        .toList();

    // Sort by order
    debugPrint("🔥 FIRESTORE RAW PAGE ID: ${json['id']}");
debugPrint("🔥 FIRESTORE ANIMATION PATH: ${json['animationPath']}");
debugPrint("🔥 PAGE TYPE: ${json['pageType']}");
    pages.sort((a, b) => a.order.compareTo(b.order));

    return OnboardingFlowConfig(onboardingPages: pages);
  }

  Map<String, dynamic> toJson() {
    return {
      'onboarding_pages': onboardingPages.map((p) => p.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [onboardingPages];
}
