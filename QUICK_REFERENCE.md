# Firebase-Driven UI System - Quick Reference Card

## 🎯 Core Classes

### Models
```dart
PageConfiguration        // Root: assets, styles, pages
├── AssetRegistry       // images, audio, animations
├── StyleTokens         // reusable text styles
└── List<PageModel>
    ├── layout          // Column, Row, Stack, Grid
    ├── components      // Text, Image, Lottie, etc.
    ├── audio           // Multi-language URLs
    └── background      // Color, gradient, image
```

### Services
```dart
DynamicContentService   // Load configs (Firebase > JSON > Cache)
ComponentRenderer       // Render components (Text, Image, Lottie)
LayoutRenderer          // Render layouts (Column, Row, Stack)
PageRenderer            // Render full pages
OnboardingPageRenderer  // Render onboarding flows
```

---

## 🔄 Loading Data

### Load Configuration (Assets + Styles + Pages)
```dart
final service = DynamicContentService();
final config = await service.loadPageConfiguration(
  configName: 'onboardingFlow',
  forceRefresh: false,  // use cache
);
```

### Load Single Page
```dart
final page = await service.loadPage(
  pageId: 'page_1',
  firebaseCollection: 'onboarding_pages',
  localJsonFile: 'onboardingFlow',
);
```

### Load Multiple Pages
```dart
final pages = await service.loadPages(
  pageIds: ['page_1', 'page_2', 'page_3'],
  firebaseCollection: 'onboarding_pages',
  localJsonFile: 'onboardingFlow',
);
```

---

## 🎨 Rendering Pages

### Basic Rendering
```dart
PageRenderer.render(
  pageModel: pageModel,
  assetRegistry: config.assetRegistry,
  styleTokens: config.styleTokens,
  currentLocale: 'English',
  context: context,
)
```

### Onboarding with Navigation
```dart
OnboardingPageRenderer.renderOnboardingPage(
  configuration: config,
  pageId: 'page_1',
  currentLocale: 'English',
  context: context,
  onPageComplete: (pageId) => navigateNext(),
  onPreviousPage: (pageId) => navigatePrev(),
  onPlayAudio: (url) => playAudio(url),
  onSkipFlow: () => complete(),
)
```

### Dashboard
```dart
DashboardPageRenderer.renderDashboard(
  configuration: config,
  currentLocale: 'English',
  context: context,
)
```

---

## 📋 JSON Structure (Minimal Example)

```json
{
  "schemaVersion": "2.0.0",
  "assets": {
    "images": {"logo": "gs://..."},
    "audio": {"intro": "gs://..."},
    "animations": {"splash": "gs://..."}
  },
  "styleTokens": {
    "textStyles": {
      "heading": {
        "fontSize": 24,
        "fontWeight": "w700",
        "color": "#000000"
      }
    }
  },
  "pages": [
    {
      "id": "page_1",
      "order": 0,
      "background": {"color": "#FFFFFF"},
      "layout": {"type": "column", "gap": 16},
      "components": [
        {
          "id": "title",
          "type": "text",
          "content": {
            "translations": {"English": "Hello World"}
          },
          "styleRef": "heading"
        }
      ]
    }
  ]
}
```

---

## 🧩 Component Types

| Type | Properties | Notes |
|------|-----------|-------|
| **text** | content, styleRef, position | Supports [b]bold[/b] parsing |
| **image** | assetKey, size, position | Caches network images |
| **lottie** | assetKey, behavior, layoutHints | Supports scale & translate |
| **button** | label, action | Action handled externally |
| **card** | content, cardStyle | Container for content |
| **collection** | items, viewType | Grid or List rendering |
| **spacer** | width, height | Flexible spacing |

---

## 📍 Positioning

### Alignment Values
```
center
center_left, center_right
top_left, top_center, top_right
bottom_left, bottom_center, bottom_right
```

### Position Example
```json
"position": {
  "alignment": "center_right",
  "padding": {"horizontal": 16, "vertical": 8},
  "margin": {"top": 16},
  "width": 200,
  "height": 100
}
```

---

## 🎨 Styling

### Define Style Token
```json
"styleTokens": {
  "textStyles": {
    "heading": {
      "fontSize": 24,
      "fontWeight": "w700",
      "color": "#000000",
      "fontFamily": "Inter",
      "textAlign": "center"
    }
  }
}
```

### Reference Style
```json
{
  "type": "text",
  "styleRef": "heading"
}
```

### Override Style
```json
{
  "type": "text",
  "styleRef": "heading",
  "content": {
    "style": {
      "color": "#FF0000"  // Override color
    }
  }
}
```

---

## 🎬 Layouts

### Column
```json
{
  "layout": {
    "type": "column",
    "gap": 16,
    "padding": {"all": 20},
    "mainAxisAlignment": "center",
    "crossAxisAlignment": "center"
  }
}
```

### Row
```json
{
  "layout": {
    "type": "row",
    "gap": 8,
    "mainAxisAlignment": "space_between"
  }
}
```

### Stack/Layers
```json
{
  "layout": {
    "type": "layers",
    "alignment": "center"
  }
}
```

### Grid
```json
{
  "layout": {
    "type": "grid",
    "gap": 8,
    "crossAxisCount": 2
  }
}
```

---

## 🔊 Audio Management

### Single Language
```json
"audio": {
  "English": "gs://bucket/audio.mp3"
}
```

### Multi-Language
```json
"audio": {
  "English": "gs://bucket/audio_en.mp3",
  "اردو": "gs://bucket/audio_ur.mp3",
  "Roman Urdu": "gs://bucket/audio_ru.mp3"
}
```

### Access by Locale
```dart
final url = pageModel.audio?.getAudioUrl('English');
```

---

## 🖼️ Asset Management

### Define Assets
```json
"assets": {
  "images": {
    "logo": "gs://bucket/logo.png",
    "background": "gs://bucket/bg.jpg"
  },
  "animations": {
    "splash": "gs://bucket/splash.lottie"
  },
  "audio": {
    "intro": "gs://bucket/intro.mp3"
  }
}
```

### Reference Assets
```json
{
  "type": "image",
  "assetKey": "logo"
}

{
  "type": "lottie",
  "assetKey": "splash"
}
```

### Resolve Asset
```dart
final url = assetRegistry.resolveAsset('logo', 'image');
```

---

## 💾 Caching

### Memory Cache
```dart
// Checked automatically - fastest
final config = await service.loadPageConfiguration(
  configName: 'onboarding',
  forceRefresh: false,  // Use memory cache
);
```

### Force Fresh Load
```dart
final config = await service.loadPageConfiguration(
  configName: 'onboarding',
  forceRefresh: true,   // Always fetch from Firebase
);
```

### View Cache Stats
```dart
final stats = service.getCacheStats();
print('Configs: ${stats['configCacheSize']}');
print('Pages: ${stats['pageCacheSize']}');
```

### Clear Cache
```dart
await service.clearAllCaches();      // Memory + Disk
service.clearMemoryCache();           // Memory only
```

---

## 🔍 Accessing Pages

### Get by ID
```dart
final page = config.getPageById('page_1');
```

### Get by Order
```dart
final page = config.getPageByOrder(0);
```

### Get Next/Previous
```dart
final nextPage = PageConfigurationRenderer.getNextPage(
  config, 
  'page_1'
);

final prevPage = PageConfigurationRenderer.getPreviousPage(
  config,
  'page_1'
);
```

### Get All Page IDs
```dart
final ids = PageConfigurationRenderer.getPageIds(config);
// ['page_1', 'page_2', 'page_3', ...]
```

---

## 🛠️ Initialization

### In main()
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  final service = DynamicContentService();
  await service.initialize();
  
  runApp(const MyApp());
}
```

### In StatefulWidget
```dart
@override
void initState() {
  super.initState();
  _loadConfig();
}

Future<void> _loadConfig() async {
  final service = DynamicContentService();
  _config = await service.loadPageConfiguration(
    configName: 'onboardingFlow',
  );
  setState(() {});
}
```

---

## ⚠️ Common Patterns

### Load & Render
```dart
// Load
final config = await service.loadPageConfiguration(
  configName: 'onboarding',
);

// Render
OnboardingPageRenderer.renderOnboardingPage(
  configuration: config,
  pageId: config.pages.first.id,
  currentLocale: 'English',
  context: context,
  // ... callbacks
);
```

### Handle Multiple Pages
```dart
int _currentIndex = 0;

void _nextPage() {
  final next = PageConfigurationRenderer.getNextPage(
    _config,
    _config.getPageByOrder(_currentIndex)!.id,
  );
  if (next != null) {
    setState(() => _currentIndex++);
  }
}
```

### Locale Management
```dart
final locale = context.read<LanguageBloc>().state.currentLocale;
// 'English', 'اردو', 'Roman Urdu', etc.

final config = await service.loadPageConfiguration(
  configName: 'onboarding',
);

OnboardingPageRenderer.renderOnboardingPage(
  configuration: config,
  pageId: 'page_1',
  currentLocale: locale,  // Use BLoC state
  context: context,
  // ...
);
```

---

## 🚀 Performance Tips

| Tip | Benefit |
|-----|---------|
| Use `forceRefresh: false` | Leverages memory cache (50ms vs 500ms) |
| Load configs once | Cache in state/BLoC |
| Lazy load pages | Only load current + next page |
| Pre-cache on app start | Smoother UX during navigation |
| Test offline mode | Verify JSON fallback works |
| Monitor Firebase quota | Avoid unexpected costs |

---

## 🐛 Debugging

### Enable Logging
```dart
// DynamicContentService prints errors automatically
// Check console for detailed logs
```

### Check Config Loaded
```dart
print('Pages: ${config.pages.length}');
print('Assets: ${config.assetRegistry}');
print('Styles: ${config.styleTokens.textStyles.keys}');
```

### Test Component Rendering
```dart
final renderer = ComponentRenderer(
  assetRegistry: config.assetRegistry,
  styleTokens: config.styleTokens,
  currentLocale: 'English',
);

final widget = renderer.render(component, context);
```

### Check Asset Resolution
```dart
final imageUrl = config.assetRegistry.resolveAsset('logo', 'image');
print('Image URL: $imageUrl');
```

---

## 📦 File Locations

```
lib/
├── models/dynamic_page_models.dart     (All models)
├── services/
│   ├── component_renderer.dart         (Component → Widget)
│   ├── page_renderer.dart              (Page → Widget)
│   └── dynamic_content_service.dart    (Load configs)
├── pages/onboarding_flow_dynamic.dart  (Example usage)
└── bloc/onboarding_bloc.dart           (State management)

assets/
└── jsons/
    ├── onboardingFlow.json             (Config file)
    ├── dashboard.json                  (Config file)
    └── [other configs]
```

---

## ✅ Checklist: Create New Page

- [ ] Create JSON in `assets/jsons/{name}.json`
- [ ] Add to Firestore `page_configs` collection (optional)
- [ ] Define assets in `assets` section
- [ ] Define styles in `styleTokens`
- [ ] Define pages array with components
- [ ] Test JSON validity
- [ ] Load with `DynamicContentService`
- [ ] Render with appropriate renderer
- [ ] Test offline (local JSON)
- [ ] Test online (Firebase)

---

## 🔗 Quick Links

- **Models**: `lib/models/dynamic_page_models.dart`
- **Renderers**: `lib/services/component_renderer.dart`, `page_renderer.dart`
- **Service**: `lib/services/dynamic_content_service.dart`
- **Full Guide**: `FIREBASE_DRIVEN_UI_GUIDE.md`
- **Firestore Setup**: `FIRESTORE_SCHEMA_SETUP.md`
- **Migration**: `MIGRATION_GUIDE.md`

---

**Version**: 2.0.0 | **Status**: Production-Ready | **Last Updated**: 2026-04-30

For detailed information, refer to the complete documentation in the root directory.
