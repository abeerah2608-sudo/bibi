import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart' as dotlottie;

import '../models/dynamic_page_models.dart';
import '../services/remote_asset_service.dart';
import '../utils/text_parsing_utils.dart';

// ============================================================================
// POSITIONING RENDERER
// ============================================================================

/// Handles positioning and alignment of widgets
class PositioningRenderer {
  /// Wraps a widget with positioning (alignment, margin, padding)
  static Widget applyPositioning({
    required Widget child,
    required BuildContext context,
    PositionModel? position,
    TextStyleToken? styleToken,
  }) {
    Widget result = child;

    // Apply padding if specified
    if (position?.padding != null) {
      result = Padding(
        padding: position!.padding!.toFlutterEdgeInsets(),
        child: result,
      );
    }

    // Apply margin if specified
    if (position?.margin != null) {
      result = Padding(
        padding: position!.margin!.toFlutterEdgeInsets(),
        child: result,
      );
    }

    // Apply alignment if specified
    if (position?.alignment != null) {
      final alignment = AlignmentModel(alignment: position!.alignment!).toFlutterAlignment();
      result = Align(
        alignment: alignment,
        child: result,
      );
    }

    return result;
  }
}

// ============================================================================
// COMPONENT RENDERER
// ============================================================================

/// Renders individual components based on their type
class ComponentRenderer {
  final AssetRegistry assetRegistry;
  final StyleTokens styleTokens;
  final String currentLocale;

  ComponentRenderer({
    required this.assetRegistry,
    required this.styleTokens,
    required this.currentLocale,
  });

  /// Main render method for components
  Widget render(
    ComponentModel component,
    BuildContext context,
  ) 
  
  {
      debugPrint("🧩 COMPONENT TYPE: ${component.type}");
    switch (component.type.toLowerCase()) {
      case 'text':
        return _renderText(component, context);
      case 'image':
        return _renderImage(component, context);
      case 'lottie':
      case 'animation':
        return _renderLottie(component, context);
      case 'button':
        return _renderButton(component, context);
      case 'card':
        return _renderCard(component, context);
      case 'collection':
      case 'list':
      case 'grid':
        return _renderCollection(component, context);
      case 'spacer':
        return _renderSpacer(component, context);
      default:
        return SizedBox(
          child: Center(
            child: Text('Unknown component type: ${component.type}'),
          ),
        );
    }
  }

  // ========================================================================
  // TEXT COMPONENT
  // ========================================================================

  Widget _renderText(ComponentModel component, BuildContext context) {
    final content = component.content;

    // Extract text content
    String displayText = '';
    if (content['textKey'] is String) {
      // Simple text key
      displayText = content['textKey'] as String;
    } else if (content is Map && content.containsKey('textKey')) {
      // Text content object
      final textContent = TextContent(
        textKey: content['textKey'] as String?,
        translations: Map<String, String>.from(
          (content['translations'] as Map<String, dynamic>?) ?? {},
        ),
      );
      displayText = textContent.getText(currentLocale);
    }

    // Apply text parsing (bold, etc.)
    if (component.behavior?.supportsBoldParsing == true) {
      // Will be handled in TextParsingUtils
    }

    // Get style
    TextStyle textStyle = const TextStyle();
    if (component.styleRef != null) {
      final styleToken = styleTokens.getTextStyle(component.styleRef!);
      if (styleToken != null) {
        textStyle = styleToken.toFlutterTextStyle();
      }
    }

    // Apply overrides if present
    if (content['style'] is Map<String, dynamic>) {
      final overrides = content['style'] as Map<String, dynamic>;
      textStyle = _applyStyleOverrides(textStyle, overrides);
    }

    // Create text widget
    Widget textWidget;
    if (component.behavior?.supportsBoldParsing == true) {
      textWidget = TextParsingUtils.parseBold(displayText);
    } else {
      textWidget = Text(
        displayText,
        style: textStyle,
        textAlign: _parseTextAlign(component.styleRef != null
            ? styleTokens.getTextStyle(component.styleRef!)?.textAlign
            : null),
      );
    }

    return PositioningRenderer.applyPositioning(
      child: textWidget,
      context: context,
      position: component.position,
      styleToken: component.styleRef != null ? styleTokens.getTextStyle(component.styleRef!) : null,
    );
  }

  TextAlign _parseTextAlign(String? align) {
    switch (align?.toLowerCase()) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'center':
        return TextAlign.center;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.start;
    }
  }

  TextStyle _applyStyleOverrides(TextStyle baseStyle, Map<String, dynamic> overrides) {
    FontWeight? fontWeight;
    if (overrides['fontWeight'] is String) {
      fontWeight = _parseFontWeight(overrides['fontWeight'] as String);
    }

    Color? color;
    if (overrides['color'] is String) {
      try {
        color = Color(int.parse((overrides['color'] as String).replaceFirst('#', '0xff')));
      } catch (e) {
        color = null;
      }
    }

    return baseStyle.copyWith(
      fontSize: (overrides['fontSize'] as num?)?.toDouble(),
      fontWeight: fontWeight,
      color: color,
      fontFamily: overrides['fontFamily'] as String?,
    );
  }

  FontWeight _parseFontWeight(String weight) {
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

  // ========================================================================
  // IMAGE COMPONENT
  // ========================================================================

  Widget _renderImage(ComponentModel component, BuildContext context) {
    final assetKey = component.content['assetKey'] as String?;
    final imageUrl = component.content['imageUrl'] as String?;

    String? url;
    if (assetKey != null) {
      url = assetRegistry.resolveAsset(assetKey, 'image');
    } else {
      url = imageUrl;
    }

    if (url == null) {
      return SizedBox(
        width: component.size?.width ?? 100,
        height: component.size?.height ?? 100,
        child: const Center(
          child: Icon(Icons.image_not_supported),
        ),
      );
    }

    // Build image widget
    Widget imageWidget;
    if (url.startsWith('gs://')) {
      // Firebase Storage URL - convert to HTTPS
      url = RemoteAssetService.convertGsUrlToHttps(url);
      debugPrint("🎬 LOTTIE FINAL URL: $url");
      imageWidget = CachedNetworkImage(
        imageUrl: url,
        width: component.size?.width,
        height: component.size?.height,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else if (url.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        imageUrl: url,
        width: component.size?.width,
        height: component.size?.height,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else {
      // Local asset
      imageWidget = Image.asset(
        url,
        width: component.size?.width,
        height: component.size?.height,
        fit: BoxFit.contain,
      );
    }

    return PositioningRenderer.applyPositioning(
      child: imageWidget,
      context: context,
      position: component.position,
    );
  }

  // ========================================================================
  // LOTTIE COMPONENT
  // ========================================================================
Widget _renderLottie(ComponentModel component, BuildContext context) {
  debugPrint("🎬 ENTERED LOTTIE RENDER");
  debugPrint("🎯 layoutHints: scale=${component.layoutHints?.scale} translate=${component.layoutHints?.translate} alignment=${component.position?.alignment}");

  final assetKey = component.assetKey ?? component.content['assetKey'] as String?;
  final lottieUrl = component.content['lottieUrl'] as String?;

  String? url;
  if (assetKey != null) {
    url = assetRegistry.resolveAsset(assetKey, 'lottie');
  } else {
    url = lottieUrl;
  }

  if (url == null) {
    return const SizedBox(width: 200, height: 200, child: Icon(Icons.animation));
  }

  if (url.startsWith('gs://')) {
    url = RemoteAssetService.convertGsUrlToHttps(url);
  }

  debugPrint("🎬 LOTTIE FINAL URL: $url");
  debugPrint("🎬 URL check — isDotLottie: ${url.toLowerCase().contains('.lottie')} | url: $url");

  // Read layoutHints — these drive scale/translate/alignment like OnboardingAnimation
  final hints = component.layoutHints;
  final double scale = hints?.scale ?? 1.0;
  final double translateX = hints?.translate?['xPercent'] ?? 0.0;
  final double translateY = hints?.translate?['yPercent'] ?? 0.0;
  final String alignmentStr = component.position?.alignment ?? hints?.preferredAlignment ?? 'center';
  final Alignment alignment = AlignmentModel(alignment: alignmentStr).toFlutterAlignment();
  final bool repeat = component.behavior?.loop ?? true;

  final double screenWidth = MediaQuery.of(context).size.width;
  final double screenHeight = MediaQuery.of(context).size.height;
  final double baseW = screenWidth * 0.5;
  final double baseH = screenHeight * 0.6;

  Widget lottieWidget;

  if (url.toLowerCase().contains('.lottie')) {
    lottieWidget = DotLottieLoader.fromNetwork(
      url,
      frameBuilder: (ctx, dotLottie) {
        if (dotLottie == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (dotLottie.animations.isEmpty) {
          debugPrint("❌ DotLottie: no animations found");
          return const Icon(Icons.error);
        }
        return Lottie.memory(
          dotLottie.animations.values.first,
          width: baseW,
          height: baseH,
          fit: BoxFit.contain,
          repeat: repeat,
          animate: true,
          imageProviderFactory: (asset) {
            if (dotLottie.images.containsKey(asset.fileName)) {
              return MemoryImage(dotLottie.images[asset.fileName]!);
            }
            return null;
          },
        );
      },
      errorBuilder: (ctx, err, stack) {
        debugPrint("❌ DotLottie error: $err");
        return const Icon(Icons.error);
      },
    );
  } else {
    lottieWidget = Lottie.network(
      url,
      width: baseW,
      height: baseH,
      fit: BoxFit.contain,
      repeat: repeat,
      animate: true,
      errorBuilder: (ctx, err, stack) {
        debugPrint("❌ Lottie JSON error: $err");
        return const Icon(Icons.error);
      },
    );
  }

  // Mirror exactly what OnboardingAnimation does
  return RepaintBoundary(
    child: Transform.translate(
      offset: Offset(
        screenWidth * translateX,
        screenHeight * translateY,
      ),
      child: Transform.scale(
        scale: scale,
        child: Align(
          alignment: alignment,
          child: SizedBox(
            width: baseW,
            height: baseH,
            child: lottieWidget,
          ),
        ),
      ),
    ),
  );
}
  // ========================================================================
  // BUTTON COMPONENT
  // ========================================================================


  Widget _renderButton(ComponentModel component, BuildContext context) {
    final label = component.content['label'] as String? ?? 'Button';
    final action = component.content['action'] as String?;

    return PositioningRenderer.applyPositioning(
      child: ElevatedButton(
        onPressed: action != null ? () => _handleAction(action, context) : null,
        child: Text(label),
      ),
      context: context,
      position: component.position,
    );
  }

  // ========================================================================
  // CARD COMPONENT
  // ========================================================================

  Widget _renderCard(ComponentModel component, BuildContext context) {
    final cardContent = component.content['content'] as Map<String, dynamic>?;
    final cardStyle = component.content['cardStyle'] as Map<String, dynamic>?;

    // Simple card with content
    return PositioningRenderer.applyPositioning(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(cardContent?['text'] as String? ?? 'Card content'),
        ),
      ),
      context: context,
      position: component.position,
    );
  }

  // ========================================================================
  // COLLECTION COMPONENT
  // ========================================================================

  Widget _renderCollection(ComponentModel component, BuildContext context) {
    final items = component.content['items'] as List<dynamic>? ?? [];
    final viewType = component.content['viewType'] as String? ?? 'list'; // list, grid

    if (viewType == 'grid') {
      return GridView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          return Card(
            child: Center(
              child: Text('Item ${index + 1}'),
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item ${index + 1}'),
          );
        },
      );
    }
  }

  // ========================================================================
  // SPACER COMPONENT
  // ========================================================================

  Widget _renderSpacer(ComponentModel component, BuildContext context) {
    return SizedBox(
      width: component.size?.width ?? (component.content['width'] as num?)?.toDouble() ?? 0,
      height: component.size?.height ?? (component.content['height'] as num?)?.toDouble() ?? 0,
    );
  }

  // ========================================================================
  // ACTION HANDLER
  // ========================================================================

  void _handleAction(String action, BuildContext context) {
    // Implement navigation and other actions
    // This will be handled by the calling widget with navigation context
  }
}

// ============================================================================
// LAYOUT RENDERER
// ============================================================================

/// Renders layout containers (Column, Row, Stack)
class LayoutRenderer {
  /// Renders a layout with its components
  static Widget render({
    required LayoutModel layout,
    required List<Widget> children,
    required BuildContext context,
    Color? backgroundColor,
  }) {
    // Apply padding first
    Widget layoutWidget;

    switch (layout.type.toLowerCase()) {
      case 'column':
        layoutWidget = Column(
          mainAxisAlignment: _parseMainAxisAlignment(layout.mainAxisAlignment),
          crossAxisAlignment: _parseCrossAxisAlignment(layout.crossAxisAlignment),
          mainAxisSize:
              (layout.mainAxisExpands ?? false) ? MainAxisSize.max : MainAxisSize.min,
          children: children,
        );
        break;

      case 'row':
        layoutWidget = Row(
          mainAxisAlignment: _parseMainAxisAlignment(layout.mainAxisAlignment),
          crossAxisAlignment: _parseCrossAxisAlignment(layout.crossAxisAlignment),
          mainAxisSize:
              (layout.mainAxisExpands ?? false) ? MainAxisSize.max : MainAxisSize.min,
          children: children,
        );
        break;

      case 'layers':
      case 'stack':
        layoutWidget = Stack(
          alignment: layout.alignment != null
              ? AlignmentModel(alignment: layout.alignment!).toFlutterAlignment()
              : Alignment.center,
          children: children,
        );
        break;

      case 'grid':
        layoutWidget = GridView.count(
          shrinkWrap: true,
          crossAxisCount: layout.gap?.toInt() ?? 2,
          mainAxisSpacing: layout.gap ?? 8,
          crossAxisSpacing: layout.gap ?? 8,
          children: children,
        );
        break;

      default:
        layoutWidget = Column(children: children);
    }

    // Apply padding if specified
    if (layout.padding != null) {
      layoutWidget = Padding(
        padding: layout.padding!.toFlutterEdgeInsets(),
        child: layoutWidget,
      );
    }

    // Apply background color if specified
    if (backgroundColor != null) {
      layoutWidget = Container(
        color: backgroundColor,
        child: layoutWidget,
      );
    }

    return layoutWidget;
  }

  static MainAxisAlignment _parseMainAxisAlignment(String? alignment) {
    switch (alignment?.toLowerCase()) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spacearound':
      case 'space_around':
        return MainAxisAlignment.spaceAround;
      case 'spacebetween':
      case 'space_between':
        return MainAxisAlignment.spaceBetween;
      case 'spaceevenly':
      case 'space_evenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment _parseCrossAxisAlignment(String? alignment) {
    switch (alignment?.toLowerCase()) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        return CrossAxisAlignment.center;
    }
  }
}
