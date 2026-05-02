import 'package:flutter/material.dart';

// ============================================================================
// ROOT CONFIGURATION MODEL
// ============================================================================

class DynamicPageConfig {
  final String schemaVersion;
  final ConfigMetadata metadata;
  final AssetRegistry assets;
  final StyleTokens styleTokens;
  final List<PageModel> pages;

  DynamicPageConfig({
    required this.schemaVersion,
    required this.metadata,
    required this.assets,
    required this.styleTokens,
    required this.pages,
  });
  PageModel? getPageById(String id) {
  try {
    return pages.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}
AssetRegistry get assetRegistry => assets;

  factory DynamicPageConfig.fromJson(Map<String, dynamic> json) {
    return DynamicPageConfig(
      schemaVersion: json['schemaVersion'] as String? ?? '2.0.0',
      metadata: ConfigMetadata.fromJson(json['metadata'] as Map<String, dynamic>? ?? {}),
      assets: AssetRegistry.fromJson(json['assets'] as Map<String, dynamic>? ?? {}),
      styleTokens: StyleTokens.fromJson(json['styleTokens'] as Map<String, dynamic>? ?? {}),
      pages: (json['pages'] as List<dynamic>?)
              ?.map((p) => PageModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
    
  }
}

// ============================================================================
// METADATA
// ============================================================================

class ConfigMetadata {
  final String version;
  final String? sourceFile;
  final String? convertedOn;
  final String? notes;

  ConfigMetadata({
    required this.version,
    this.sourceFile,
    this.convertedOn,
    this.notes,
  });

  factory ConfigMetadata.fromJson(Map<String, dynamic> json) {
    return ConfigMetadata(
      version: json['version'] as String? ?? '2.0.0',
      sourceFile: json['sourceFile'] as String?,
      convertedOn: json['convertedOn'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

// ============================================================================
// ASSET REGISTRY
// ============================================================================

class AssetRegistry {
  final Map<String, String> animations;
  final Map<String, String> images;
  final Map<String, String> audio;

  AssetRegistry({
    Map<String, String>? animations,
    Map<String, String>? images,
    Map<String, String>? audio,
  })  : animations = animations ?? {},
        images = images ?? {},
        audio = audio ?? {};

  factory AssetRegistry.fromJson(Map<String, dynamic> json) {
    return AssetRegistry(
      animations: Map<String, String>.from(
          (json['animations'] as Map<String, dynamic>?) ?? {}),
      images: Map<String, String>.from(
          (json['images'] as Map<String, dynamic>?) ?? {}),
      audio: Map<String, String>.from(
          (json['audio'] as Map<String, dynamic>?) ?? {}),
    );
  }

  String? resolveAsset(String key, String type) {
    switch (type.toLowerCase()) {
      case 'animation':
      case 'lottie':
        return animations[key];
      case 'image':
      case 'img':
        return images[key];
      case 'audio':
      case 'sound':
        return audio[key];
      default:
        // Try all maps
        return animations[key] ?? images[key] ?? audio[key];
    }
  }
}

// ============================================================================
// STYLE TOKENS
// ============================================================================

class StyleTokens {
  final Map<String, TextStyleToken> textStyles;

  StyleTokens({Map<String, TextStyleToken>? textStyles})
      : textStyles = textStyles ?? {};

  factory StyleTokens.fromJson(Map<String, dynamic> json) {
    final textStylesJson = json['textStyles'] as Map<String, dynamic>? ?? {};
    final textStyles = <String, TextStyleToken>{};

    textStylesJson.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        textStyles[key] = TextStyleToken.fromJson(value);
      }
    });

    return StyleTokens(textStyles: textStyles);
  }

  TextStyleToken? getTextStyle(String key) => textStyles[key];
}

class TextStyleToken {
  final double? fontSize;
  final String? fontWeight;
  final String? fontFamily;
  final String? color;
  final String? textAlign;
  final double? lineHeight;

  TextStyleToken({
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.color,
    this.textAlign,
    this.lineHeight,
  });

  factory TextStyleToken.fromJson(Map<String, dynamic> json) {
    return TextStyleToken(
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      fontWeight: json['fontWeight'] as String?,
      fontFamily: json['fontFamily'] as String?,
      color: json['color'] as String?,
      textAlign: json['textAlign'] as String?,
      lineHeight: (json['lineHeight'] as num?)?.toDouble(),
    );
  }

  TextStyle toFlutterTextStyle() {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: _parseFontWeight(fontWeight),
      fontFamily: fontFamily,
      color: color != null ? _parseColor(color!) : null,
      height: lineHeight,
    );
  }

  FontWeight _parseFontWeight(String? weight) {
    if (weight == null) return FontWeight.normal;
    switch (weight.toLowerCase()) {
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
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  Color _parseColor(String colorStr) {
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.black;
    }
  }
}

// ============================================================================
// PAGE MODEL
// ============================================================================

class PageModel {
  final String id;
  final int? order;
  final String? type;
  final BackgroundModel? background;
  final Map<String, String>? audio;
  final LayoutModel layout;
  final List<ComponentModel> components;
  final TransitionsModel? transitions;

  PageModel({
    required this.id,
    this.order,
    this.type,
    this.background,
    this.audio,
    required this.layout,
    required this.components,
    this.transitions,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: json['id'] as String? ?? 'unknown',
      order: json['order'] as int?,
      type: json['type'] as String?,
      background: json['background'] != null
          ? BackgroundModel.fromJson(json['background'])
          : null,

      audio: json['audio'] != null
          ? Map<String, String>.from(json['audio'])
          : null,

      layout: LayoutModel.fromJson(
        json['layout'] ?? {'type': 'column'},
      ),

      // ✅ FIXED: safe list handling
      components: (json['components'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((c) => ComponentModel.fromJson(c))
              .toList() ??
          [],

      transitions: json['transitions'] != null
          ? TransitionsModel.fromJson(json['transitions'])
          : null,
    );
  }
}
// ============================================================================
// BACKGROUND MODEL
// ============================================================================

class BackgroundModel {
  final String? color;
  final String? type;
  final String? asset;
  final String? fit;

  BackgroundModel({
    this.color,
    this.type,
    this.asset,
    this.fit,
  });

  factory BackgroundModel.fromJson(Map<String, dynamic> json) {
    return BackgroundModel(
      color: json['color'] as String?,
      type: json['type'] as String?,
      asset: json['asset'] as String?,
      fit: json['fit'] as String?,
    );
  }

  Color? getColor() {
    if (color == null) return null;
    try {
      return Color(int.parse(color!.replaceFirst('#', '0xff')));
    } catch (e) {
      return null;
    }
  }
}

// ============================================================================
// LAYOUT MODEL
// ============================================================================

class LayoutModel {
  final String type;
  final String? mainAxisAlignment;
  final String? crossAxisAlignment;
  final String? alignment;
  final EdgeInsetsModel? padding;
  final double? gap;
  final bool? mainAxisExpands;

  LayoutModel({
    required this.type,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.alignment,
    this.padding,
    this.gap,
    this.mainAxisExpands,
  });

  factory LayoutModel.fromJson(Map<String, dynamic> json) {
    return LayoutModel(
      type: json['type'] as String? ?? 'column',
      mainAxisAlignment: json['mainAxisAlignment'] as String?,
      crossAxisAlignment: json['crossAxisAlignment'] as String?,
      alignment: json['alignment'] as String?,
      padding: json['padding'] != null
          ? EdgeInsetsModel.fromJson(json['padding'] as Map<String, dynamic>)
          : null,
      gap: (json['gap'] as num?)?.toDouble(),
      mainAxisExpands: json['mainAxisExpands'] as bool?,
    );
  }
}

// ============================================================================
// COMPONENT MODEL
// ============================================================================

class ComponentModel {
  final String id;
  final String type;
  final String? assetKey;
  final Map<String, dynamic> content;
  final String? styleRef;
  final SizeModel? size;
  final PositionModel? position;
  final BehaviorModel? behavior;
  final LayoutHintsModel? layoutHints;

  ComponentModel({
    required this.id,
    required this.type,
    this.assetKey,
    required this.content,
    this.styleRef,
    this.size,
    this.position,
    this.behavior,
    this.layoutHints,
  });

  factory ComponentModel.fromJson(Map<String, dynamic> json) {
    return ComponentModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'unknown',

      assetKey: json['assetKey'] as String?,

      // ✅ FIXED: SAFE content parsing
      content: json['content'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['content'])
          : {},

      styleRef: json['styleRef'] as String?,

      size: json['size'] != null
          ? SizeModel.fromJson(json['size'])
          : null,

      position: json['position'] != null
          ? PositionModel.fromJson(json['position'])
          : null,

      behavior: json['behavior'] != null
          ? BehaviorModel.fromJson(json['behavior'])
          : null,

      layoutHints: json['layoutHints'] != null
          ? LayoutHintsModel.fromJson(json['layoutHints'])
          : null,
    );
  }
}
// ============================================================================
// SIZE MODEL
// ============================================================================

class SizeModel {
  final double? width;
  final double? height;

  SizeModel({this.width, this.height});

  factory SizeModel.fromJson(Map<String, dynamic> json) {
    return SizeModel(
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
    );
  }
}

// ============================================================================
// POSITION MODEL
// ============================================================================

class PositionModel {
  final String? alignment;
  final EdgeInsetsModel? padding;
  final EdgeInsetsModel? margin;
  final OffsetModel? offset;

  PositionModel({
    this.alignment,
    this.padding,
    this.margin,
    this.offset,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      alignment: json['alignment'] as String?,
      padding: json['padding'] != null
          ? EdgeInsetsModel.fromJson(json['padding'] as Map<String, dynamic>)
          : null,
      margin: json['margin'] != null
          ? EdgeInsetsModel.fromJson(json['margin'] as Map<String, dynamic>)
          : null,
      offset: json['offset'] != null
          ? OffsetModel.fromJson(json['offset'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ============================================================================
// EDGE INSETS MODEL
// ============================================================================

class EdgeInsetsModel {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final double? horizontal;
  final double? vertical;
  final double? all;

  EdgeInsetsModel({
    this.left,
    this.right,
    this.top,
    this.bottom,
    this.horizontal,
    this.vertical,
    this.all,
  });

  factory EdgeInsetsModel.fromJson(Map<String, dynamic> json) {
    return EdgeInsetsModel(
      left: (json['left'] as num?)?.toDouble(),
      right: (json['right'] as num?)?.toDouble(),
      top: (json['top'] as num?)?.toDouble(),
      bottom: (json['bottom'] as num?)?.toDouble(),
      horizontal: (json['horizontal'] as num?)?.toDouble(),
      vertical: (json['vertical'] as num?)?.toDouble(),
      all: (json['all'] as num?)?.toDouble(),
    );
  }

  EdgeInsets toFlutterEdgeInsets() {
    if (all != null) {
      return EdgeInsets.all(all!);
    }
    if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );
    }
    return EdgeInsets.only(
      left: left ?? 0,
      right: right ?? 0,
      top: top ?? 0,
      bottom: bottom ?? 0,
    );
  }
}

// ============================================================================
// OFFSET MODEL
// ============================================================================

class OffsetModel {
  final double? xPx;
  final double? yPx;
  final double? xFraction;
  final double? yFraction;
  final double? rightPx;

  OffsetModel({
    this.xPx,
    this.yPx,
    this.xFraction,
    this.yFraction,
    this.rightPx,
  });

  factory OffsetModel.fromJson(Map<String, dynamic> json) {
    return OffsetModel(
      xPx: (json['xPx'] as num?)?.toDouble(),
      yPx: (json['yPx'] as num?)?.toDouble(),
      xFraction: (json['xFraction'] as num?)?.toDouble(),
      yFraction: (json['yFraction'] as num?)?.toDouble(),
      rightPx: (json['rightPx'] as num?)?.toDouble(),
    );
  }
}

// ============================================================================
// BEHAVIOR MODEL
// ============================================================================

class BehaviorModel {
  final bool? autoplay;
  final bool? loop;
  final double? speed;
  final bool? supportsBoldParsing;
  final ArrowModel? arrow;

  BehaviorModel({
    this.autoplay,
    this.loop,
    this.speed,
    this.supportsBoldParsing,
    this.arrow,
  });

  factory BehaviorModel.fromJson(Map<String, dynamic> json) {
    return BehaviorModel(
      autoplay: json['autoplay'] as bool?,
      loop: json['loop'] as bool?,
      speed: (json['speed'] as num?)?.toDouble(),
      supportsBoldParsing: json['supportsBoldParsing'] as bool?,
      arrow: json['arrow'] != null
          ? ArrowModel.fromJson(json['arrow'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ============================================================================
// ARROW MODEL (for labels with arrows)
// ============================================================================

class ArrowModel {
  final bool enabled;
  final Map<String, double>? startFraction;
  final Map<String, double>? endFraction;
  final Map<String, double>? controlFraction;
  final String? color;
  final double? opacity;
  final double? strokeWidth;

  ArrowModel({
    required this.enabled,
    this.startFraction,
    this.endFraction,
    this.controlFraction,
    this.color,
    this.opacity,
    this.strokeWidth,
  });

  factory ArrowModel.fromJson(Map<String, dynamic> json) {
    return ArrowModel(
      enabled: json['enabled'] as bool? ?? false,
      startFraction: json['startFraction'] != null
          ? Map<String, double>.from(
              (json['startFraction'] as Map<String, dynamic>)
                  .map((k, v) => MapEntry(k, (v as num).toDouble())))
          : null,
      endFraction: json['endFraction'] != null
          ? Map<String, double>.from(
              (json['endFraction'] as Map<String, dynamic>)
                  .map((k, v) => MapEntry(k, (v as num).toDouble())))
          : null,
      controlFraction: json['controlFraction'] != null
          ? Map<String, double>.from(
              (json['controlFraction'] as Map<String, dynamic>)
                  .map((k, v) => MapEntry(k, (v as num).toDouble())))
          : null,
      color: json['color'] as String?,
      opacity: (json['opacity'] as num?)?.toDouble(),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble(),
    );
  }
}

// ============================================================================
// LAYOUT HINTS MODEL
// ============================================================================

class LayoutHintsModel {
  final String? preferredAlignment;
  final double? scale;
  final Map<String, double>? translate;
  final double? widthFraction;
  final double? heightPx;

  LayoutHintsModel({
    this.preferredAlignment,
    this.scale,
    this.translate,
    this.widthFraction,
    this.heightPx,
  });

  factory LayoutHintsModel.fromJson(Map<String, dynamic> json) {
    return LayoutHintsModel(
      preferredAlignment: json['preferredAlignment'] as String?,
      scale: (json['scale'] as num?)?.toDouble(),
      translate: json['translate'] != null
          ? Map<String, double>.from(
              (json['translate'] as Map<String, dynamic>)
                  .map((k, v) => MapEntry(k, (v as num).toDouble())))
          : null,
      widthFraction: (json['widthFraction'] as num?)?.toDouble(),
      heightPx: (json['heightPx'] as num?)?.toDouble(),
    );
  }
}

// ============================================================================
// TRANSITIONS MODEL
// ============================================================================

class TransitionsModel {
  final TransitionModel? enter;
  final TransitionModel? exit;

  TransitionsModel({this.enter, this.exit});

  factory TransitionsModel.fromJson(Map<String, dynamic> json) {
    return TransitionsModel(
      enter: json['enter'] != null
          ? TransitionModel.fromJson(json['enter'] as Map<String, dynamic>)
          : null,
      exit: json['exit'] != null
          ? TransitionModel.fromJson(json['exit'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TransitionModel {
  final String type;
  final int duration;

  TransitionModel({required this.type, required this.duration});

  factory TransitionModel.fromJson(Map<String, dynamic> json) {
    return TransitionModel(
      type: json['type'] as String? ?? 'fade',
      duration: json['duration'] as int? ?? 300,
    );
  }
}

// ============================================================================
// ALIGNMENT MODEL
// ============================================================================

class AlignmentModel {
  final String alignment;

  AlignmentModel({required this.alignment});

  Alignment toFlutterAlignment() {
    switch (alignment.toLowerCase()) {
      case 'top_left':
      case 'topleft':
        return Alignment.topLeft;
      case 'top_center':
      case 'topcenter':
        return Alignment.topCenter;
      case 'top_right':
      case 'topright':
        return Alignment.topRight;
      case 'center_left':
      case 'centerleft':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      case 'center_right':
      case 'centerright':
        return Alignment.centerRight;
      case 'bottom_left':
      case 'bottomleft':
        return Alignment.bottomLeft;
      case 'bottom_center':
      case 'bottomcenter':
        return Alignment.bottomCenter;
      case 'bottom_right':
      case 'bottomright':
        return Alignment.bottomRight;
      case 'overlay_center':
        return Alignment.center;
      default:
        return Alignment.center;
    }
  }
}

// ============================================================================
// TEXT CONTENT MODEL
// ============================================================================

class TextContent {
  final String? textKey;
  final Map<String, String> translations;

  TextContent({
    this.textKey,
    required this.translations,
  });

  String getText(String locale) {
    return translations[locale] ?? textKey ?? '';
  }
}