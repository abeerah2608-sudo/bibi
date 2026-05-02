# Firebase-Driven UI System: Complete Architecture Guide

## Overview

The Bibi app has been refactored to support a fully dynamic, Firebase-driven UI system. This eliminates hardcoded page layouts and enables dynamic content updates without app releases.

### Key Features

- ✅ Dynamic page rendering from JSON/Firebase
- ✅ Intelligent fallback chain: Firebase → Local JSON → Cache
- ✅ Component-based architecture (Text, Image, Lottie, etc.)
- ✅ Centralized asset and style management
- ✅ Multi-language support (i18n)
- ✅ Audio integration with per-locale support
- ✅ Responsive positioning system
- ✅ Performance optimizations (caching, lazy loading)
- ✅ Backward compatible offline support

---

## Architecture Layers

### 1. **Data Models** (`lib/models/dynamic_page_models.dart`)

Complete data structure for the new schema:

```dart
PageConfiguration
├── AssetRegistry (images, audio, animations)
├── StyleTokens (reusable text styles)
└── List<PageModel>
    ├── PageModel
    │   ├── layout (LayoutModel)
    │   ├── List<ComponentModel>
    │   │   ├── ComponentModel.content
    │   │   ├── ComponentModel.position (PositionModel)
    │   │   ├── ComponentModel.styleRef
    │   │   └── ComponentModel.behavior
    │   ├── audio (AudioModel)
    │   └── background (BackgroundModel)
```

### 2. **Rendering Engine** (`lib/services/component_renderer.dart`, `page_renderer.dart`)

**ComponentRenderer**: Maps component types to widgets
- `text` → Text widget with styling
- `image` → CachedNetworkImage
- `lottie` → Lottie animation
- `button` → ElevatedButton
- `card` → Card layout
- `collection` → GridView/ListView

**LayoutRenderer**: Maps layout types to containers
- `column` → Column
- `row` → Row
- `layers` → Stack
- `grid` → GridView

**PositioningRenderer**: Applies alignment, margin, padding

### 3. **Content Service** (`lib/services/dynamic_content_service.dart`)

Intelligent content loading with multiple fallbacks:

```
Request → Memory Cache → Firebase → Local JSON → SharedPreferences Cache
```

### 4. **Page Renderer** (`lib/services/page_renderer.dart`)

High-level renderers:
- `PageRenderer`: Basic page rendering
- `PageConfigurationRenderer`: Configuration-based rendering
- `OnboardingPageRenderer`: Onboarding-specific (audio, navigation)
- `DashboardPageRenderer`: Dashboard-specific

---

## Firestore Schema Examples

### Collection: `page_configs`

```firestore
page_configs
├── onboardingFlow (document)
│   ├── schemaVersion: "2.0.0"
│   ├── metadata: {}
│   ├── assets: {}
│   ├── styleTokens: {}
│   └── pages: [...]
│
├── dashboard (document)
│   └── [same structure]
```

### Collection: `onboarding_pages`

```firestore
onboarding_pages
├── page_1
│   ├── id: "page_1"
│   ├── order: 0
│   ├── layout: {type: "layers", alignment: "center"}
│   ├── components: [...]
│   └── audio: {English: "gs://...", اردو: "gs://..."}
│
├── page_2
│   └── [similar structure]
```

### Collection: `quiz_pages`

```firestore
quiz_pages
├── quiz_page_1
├── quiz_page_2
└── [same structure as onboarding_pages]
```

---

## Local JSON Schema

### File: `assets/jsons/onboardingFlow.json`

```json
{
  "schemaVersion": "2.0.0",
  "metadata": {
    "version": "2.0.0",
    "sourceFile": "onboardingFlow.json",
    "convertedOn": "2026-04-30",
    "notes": "Component-based pages"
  },
  "assets": {
    "animations": {
      "Bibi_Onboarding_Leftt.lottie": "gs://bibi-app-d41a0.firebasestorage.app/animations/Bibi_Onboarding_Leftt.lottie"
    },
    "audio": {
      "onboarding_1.mp3": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_1.mp3",
      "onboarding_1_urdu.mp3": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_1_urdu.mp3"
    },
    "images": {}
  },
  "styleTokens": {
    "textStyles": {
      "overlay": {
        "fontSize": 28,
        "fontWeight": "w800",
        "fontFamily": "Inter",
        "color": "#8B5E3C",
        "textAlign": "center"
      }
    }
  },
  "pages": [
    {
      "id": "page_1",
      "order": 0,
      "background": {"color": "#FFFFFF"},
      "audio": {
        "English": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_1.mp3",
        "اردو": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_1_urdu.mp3"
      },
      "layout": {"type": "layers", "alignment": "center"},
      "components": [
        {
          "id": "anim",
          "type": "lottie",
          "assetKey": "Bibi_Onboarding_Leftt.lottie",
          "behavior": {
            "autoplay": true,
            "loop": true
          },
          "layoutHints": {
            "scale": 3.7,
            "translate": {
              "xPercent": 0.75,
              "yPercent": -0.10
            },
            "preferredAlignment": "center_left"
          },
          "position": {"alignment": "center_left"}
        },
        {
          "id": "text",
          "type": "text",
          "content": {
            "textKey": "assalam_o_alaikum",
            "translations": {
              "English": "Assalam-o-Alaikum!",
              "اردو": "السلام علیکم!"
            }
          },
          "styleRef": "overlay",
          "position": {"alignment": "center_right"},
          "behavior": {
            "supportsBoldParsing": true
          }
        }
      ]
    }
  ]
}
```

---

## Component Types & Properties

### Text Component

```dart
ComponentModel(
  id: "text_1",
  type: "text",
  content: {
    "textKey": "my_key",
    "translations": {
      "English": "Hello [b]World[/b]",
      "اردو": "السلام عليكم"
    },
    "fallbackText": "Default text"
  },
  styleRef: "body_text", // References styleTokens.textStyles.body_text
  position: PositionModel(
    alignment: "center",
    padding: EdgeInsetsModel(vertical: 16)
  ),
  behavior: ComponentBehavior(
    supportsBoldParsing: true
  )
)
```

### Lottie Component

```dart
ComponentModel(
  id: "lottie_1",
  type: "lottie",
  content: {
    "assetKey": "animation_name"
  },
  size: SizeModel(width: 200, height: 200),
  layoutHints: LottieLayoutHints(
    scale: 2.0,
    translate: {"xPercent": 0.5, "yPercent": -0.1},
    preferredAlignment: "center_left"
  ),
  behavior: ComponentBehavior(
    autoplay: true,
    loop: true
  )
)
```

### Image Component

```dart
ComponentModel(
  id: "image_1",
  type: "image",
  content: {
    "assetKey": "logo_image"
  },
  size: SizeModel(width: 100, height: 100),
  position: PositionModel(alignment: "top_left")
)
```

### Button Component

```dart
ComponentModel(
  id: "button_1",
  type: "button",
  content: {
    "label": "Click Me",
    "action": "navigate_to_next_page"
  },
  position: PositionModel(alignment: "bottom_center")
)
```

---

## Style Tokens (Reusable Styles)

Define once, use everywhere:

```json
"styleTokens": {
  "textStyles": {
    "heading_1": {
      "fontSize": 32,
      "fontWeight": "w800",
      "color": "#8B5E3C",
      "fontFamily": "Inter"
    },
    "body_text": {
      "fontSize": 14,
      "fontWeight": "w400",
      "color": "#333333",
      "height": 1.5
    },
    "small_caption": {
      "fontSize": 12,
      "fontWeight": "w500",
      "color": "#666666"
    }
  }
}
```

Reference in components:

```json
{
  "type": "text",
  "content": {...},
  "styleRef": "heading_1"  // Applies heading_1 style
}
```

Override if needed:

```json
{
  "type": "text",
  "content": {...},
  "styleRef": "heading_1",
  "content": {
    "style": {
      "color": "#FF0000"  // Override color
    }
  }
}
```

---

## Asset Management

### Asset Keys (Not URLs)

In components, use asset keys, not direct URLs:

❌ **Wrong:**
```json
{
  "type": "image",
  "content": {
    "imageUrl": "gs://bucket/image.png"
  }
}
```

✅ **Correct:**
```json
{
  "type": "image",
  "content": {
    "assetKey": "my_image_name"
  }
}
```

Central registry resolves the key:

```json
"assets": {
  "images": {
    "my_image_name": "gs://bucket/image.png"
  },
  "audio": {
    "audio_1": "gs://bucket/audio.mp3"
  },
  "animations": {
    "anim_1": "gs://bucket/animation.lottie"
  }
}
```

### Multi-Language Assets

```json
"audio": {
  "English": "gs://bucket/audio_en.mp3",
  "اردو": "gs://bucket/audio_ur.mp3"
}
```

Access by locale:

```dart
final audioUrl = pageModel.audio?.getAudioUrl('English');
```

---

## Positioning & Alignment

### Alignment String Values

- `center`
- `center_left`, `center_right`
- `top_center`, `top_left`, `top_right`
- `bottom_center`, `bottom_left`, `bottom_right`

### Position Model

```json
"position": {
  "alignment": "center_right",
  "padding": {
    "horizontal": 16,
    "vertical": 8
  },
  "margin": {
    "top": 16,
    "bottom": 16
  },
  "width": 200,
  "height": 100
}
```

### Edge Insets Options

```json
// Option 1: All sides
"padding": {"all": 16}

// Option 2: Symmetric
"margin": {"horizontal": 16, "vertical": 8}

// Option 3: Individual
"padding": {"left": 10, "right": 10, "top": 20, "bottom": 20}
```

---

## Layout Types

### Column Layout

```json
"layout": {
  "type": "column",
  "padding": {"all": 16},
  "gap": 12,
  "mainAxisAlignment": "center",
  "crossAxisAlignment": "center"
}
```

### Row Layout

```json
"layout": {
  "type": "row",
  "gap": 8,
  "mainAxisAlignment": "space_between"
}
```

### Stack/Layers Layout

```json
"layout": {
  "type": "layers",
  "alignment": "center"
}
```

### Grid Layout

```json
"layout": {
  "type": "grid",
  "gap": 8,
  "crossAxisCount": 2
}
```

---

## Usage Examples

### Example 1: Simple Page Rendering

```dart
// Load configuration
final service = DynamicContentService();
final config = await service.loadPageConfiguration(
  configName: 'onboardingFlow'
);

// Get a page
final page = config.getPageById('page_1');

// Render it
PageRenderer.render(
  pageModel: page,
  assetRegistry: config.assetRegistry,
  styleTokens: config.styleTokens,
  currentLocale: 'English',
  context: context,
)
```

### Example 2: Onboarding Flow

```dart
OnboardingPageRenderer.renderOnboardingPage(
  configuration: config,
  pageId: 'page_1',
  currentLocale: 'English',
  context: context,
  onPageComplete: (pageId) => navigateToNextPage(),
  onPreviousPage: (pageId) => navigateToPreviousPage(),
  onPlayAudio: (url) => playAudio(url),
  onSkipFlow: () => completeOnboarding(),
)
```

### Example 3: Dashboard

```dart
DashboardPageRenderer.renderDashboard(
  configuration: dashboardConfig,
  currentLocale: 'English',
  context: context,
)
```

---

## Migration from Hardcoded Pages

### Before (Hardcoded)

```dart
class OnboardingPage5 extends StatefulWidget {
  @override
  State<OnboardingPage5> createState() => _OnboardingPage5State();
}

class _OnboardingPage5State extends State<OnboardingPage5> {
  List<OnboardingPageData> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    // Manual Firebase fetch
    final pages = await FirebaseContentService().getOnboardingPages();
    setState(() {
      _pages = pages;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Manual UI construction with hardcoded layouts
    return Scaffold(
      body: Column(
        children: [
          Image.asset('assets/images/background.png'),
          Lottie.asset('assets/animations/animation.json'),
          Text('Hardcoded text'),
        ],
      ),
    );
  }
}
```

### After (JSON-Driven)

```dart
class OnboardingPageDynamic extends StatefulWidget {
  @override
  State<OnboardingPageDynamic> createState() => _OnboardingPageDynamicState();
}

class _OnboardingPageDynamicState extends State<OnboardingPageDynamic> {
  late PageConfiguration _config;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    final service = DynamicContentService();
    _config = await service.loadPageConfiguration(
      configName: 'onboardingFlow',
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _config.getPageByOrder(_currentPageIndex);
    return OnboardingPageRenderer.renderOnboardingPage(
      configuration: _config,
      pageId: currentPage.id,
      currentLocale: 'English',
      context: context,
      onPageComplete: (_) => setState(() => _currentPageIndex++),
      onPreviousPage: (_) => setState(() => _currentPageIndex--),
      onPlayAudio: (url) => playAudio(url),
    );
  }
}
```

---

## Performance Optimization

### Caching Strategy

```
Request
├── Memory Cache (Fastest)
├── SharedPreferences Cache (Offline)
├── Firebase Firestore (Fresh)
├── Local JSON Asset (Fallback)
└── User Error (Last resort)
```

### Cache Configuration

```dart
// Load with cache (default)
final config = await service.loadPageConfiguration(
  configName: 'onboardingFlow',
  forceRefresh: false,  // Use cache if available
);

// Force refresh
final freshConfig = await service.loadPageConfiguration(
  configName: 'onboardingFlow',
  forceRefresh: true,   // Always fetch from Firebase
);

// Check cache stats
final stats = service.getCacheStats();
print('Cached configs: ${stats['configCacheSize']}');
print('Cached pages: ${stats['pageCacheSize']}');

// Clear cache
await service.clearAllCaches();
```

### Lazy Loading

Only load pages when needed:

```dart
// ❌ Don't do this (loads all pages)
List<PageModel> allPages = config.pages;

// ✅ Do this (load by order)
PageModel? currentPage = config.getPageByOrder(0);
PageModel? nextPage = config.getPageByOrder(1);
```

---

## Error Handling

### Graceful Fallbacks

```dart
try {
  final config = await service.loadPageConfiguration(
    configName: 'onboardingFlow',
  );
  // Success path
} catch (e) {
  // Fallback already handled internally
  // This only thrown if ALL sources fail
  print('Failed to load config: $e');
  showErrorDialog('Unable to load content');
}
```

### Check Source

```dart
// The service automatically tries:
// 1. Firebase (if online)
// 2. Local JSON (always available)
// 3. Cache (if not expired)

// If all fail, exception is thrown
```

---

## Testing

### Unit Tests

```dart
test('Load configuration from local JSON', () async {
  final service = DynamicContentService();
  final config = await service.loadPageConfiguration(
    configName: 'onboardingFlow',
  );
  expect(config.pages.length, greaterThan(0));
});

test('Get page by ID', () async {
  final service = DynamicContentService();
  final config = await service.loadPageConfiguration(
    configName: 'onboardingFlow',
  );
  final page = config.getPageById('page_1');
  expect(page, isNotNull);
  expect(page?.id, equals('page_1'));
});
```

### Integration Tests

```dart
testWidgets('Render onboarding page', (tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  
  await tester.pumpAndSettle();
  expect(find.byType(Text), findsWidgets);
});
```

---

## Troubleshooting

### Configuration not loading

1. Check Firebase connection: `await Firebase.initializeApp()`
2. Verify Firestore document exists: `page_configs/{configName}`
3. Check local JSON exists: `assets/jsons/{configName}.json`
4. Review logs: `print()` statements in `dynamic_content_service.dart`

### Components not rendering

1. Verify component `type` matches renderer cases
2. Check `assetKey` exists in `assets` registry
3. Validate `styleRef` exists in `styleTokens`
4. Review console for detailed error messages

### Audio not playing

1. Confirm `AudioModel` has correct locale key
2. Verify audio URL is accessible (convert `gs://` to HTTPS)
3. Check audio service is properly initialized
4. Test with direct URL first, then asset key

### Layout issues

1. Ensure `layout.type` is valid: "column", "row", "layers", "grid"
2. Check component `position` uses valid alignment strings
3. Verify padding/margin values are positive numbers
4. Test with explicit `width`/`height` if needed

---

## Next Steps

1. ✅ Create JSON files in `assets/jsons/`
2. ✅ Set up Firestore collections
3. ✅ Update existing pages to use renderers
4. ✅ Implement audio playback integration
5. ✅ Set up navigation/action handlers
6. ✅ Test offline mode
7. ✅ Monitor Firebase quota
8. ✅ Document custom components

---

**Version**: 2.0.0  
**Last Updated**: 2026-04-30  
**Schema**: `schemaVersion: "2.0.0"`
