# Migration Guide: From Hardcoded to Firebase-Driven Pages

This guide walks through converting existing hardcoded onboarding pages to the new Firebase-driven dynamic system.

---

## Overview: The Conversion Process

### Old System (Hardcoded)
```
┌─────────────────────┐
│  onboarding_page_5  │ (StatefulWidget)
├─────────────────────┤
│ • Manual Firebase    │
│ • Hardcoded layouts  │
│ • Inline styling     │
│ • Duplicate code     │
└─────────────────────┘
```

### New System (JSON-Driven)
```
┌──────────────────────────────┐
│  Firebase / Local JSON       │
├──────────────────────────────┤
│ page_configs/onboardingFlow  │
│ {assets, styles, pages}      │
└──────────────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  DynamicContentService       │
├──────────────────────────────┤
│ • Firebase > JSON > Cache    │
│ • Intelligent fallback       │
│ • Caching built-in          │
└──────────────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  PageConfiguration Model     │
├──────────────────────────────┤
│ • Parsed schema             │
│ • Type-safe data            │
│ • Reusable components       │
└──────────────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  Renderers                   │
├──────────────────────────────┤
│ • ComponentRenderer          │
│ • LayoutRenderer            │
│ • PageRenderer              │
└──────────────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  Flutter Widgets             │
├──────────────────────────────┤
│ • Text, Image, Lottie       │
│ • Column, Row, Stack        │
│ • Dynamically built         │
└──────────────────────────────┘
```

---

## Step-by-Step Migration

### Step 1: Define Your Page in JSON

**Location**: `assets/jsons/onboardingFlow.json`

Take your existing hardcoded page and convert it to JSON format:

#### Before (Hardcoded Page Code)
```dart
class OnboardingPage5 extends StatefulWidget {
  @override
  State<OnboardingPage5> createState() => _OnboardingPage5State();
}

class _OnboardingPage5State extends State<OnboardingPage5> {
  List<OnboardingPageData> _pages = [];
  int _currentPageIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    try {
      _pages = await context.read<OnboardingBloc>().getPages();
      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) return const SizedBox();
    
    final page = _pages[_currentPageIndex];
    
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // Lottie animation positioned left
            Positioned(
              left: MediaQuery.of(context).size.width * 0.05,
              top: MediaQuery.of(context).size.height * 0.1,
              child: Lottie.asset(
                'assets/images/Bibi_Onboarding_Leftt.lottie',
                width: 200.0.w,
                height: 200.0.h,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
              ),
            ),
            // Text centered right
            Positioned(
              right: 20,
              top: MediaQuery.of(context).size.height * 0.35,
              child: Text(
                page.translations['English'] ?? '',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF8B5E3C),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### After (JSON Definition)
```json
{
  "id": "page_5",
  "order": 4,
  "type": "screen",
  "background": {
    "color": "#FFFFFF"
  },
  "audio": {
    "English": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_5.mp3",
    "اردو": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_5_urdu.mp3"
  },
  "layout": {
    "type": "layers",
    "alignment": "center"
  },
  "components": [
    {
      "id": "animation",
      "type": "lottie",
      "assetKey": "Bibi_Onboarding_Leftt.lottie",
      "size": {
        "width": 200,
        "height": 200
      },
      "behavior": {
        "autoplay": true,
        "loop": true
      },
      "layoutHints": {
        "scale": 3.7,
        "translate": {
          "xPercent": 0.75,
          "yPercent": -0.10
        }
      },
      "position": {
        "alignment": "center_left"
      }
    },
    {
      "id": "text",
      "type": "text",
      "content": {
        "textKey": "life",
        "translations": {
          "English": "life is beautiful \n and health is wealth",
          "اردو": "زندگی خوبصورت ہے\nاور صحت ہی دولت ہے",
          "Roman Urdu": "Zindagi khoobsurat hai aur sehat sab kuch hai"
        }
      },
      "styleRef": "overlay",
      "position": {
        "alignment": "center_right"
      },
      "behavior": {
        "supportsBoldParsing": false
      }
    }
  ]
}
```

---

### Step 2: Define Styles in styleTokens

Extract common styles from hardcoded pages:

#### Before (Inline Styles in Every Page)
```dart
TextStyle(
  fontSize: 28.sp,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF8B5E3C),
),
TextStyle(
  fontSize: 14.sp,
  fontWeight: FontWeight.w400,
  color: const Color(0xFF666666),
),
// ... repeated in 10+ places
```

#### After (Define Once, Use Everywhere)
```json
"styleTokens": {
  "textStyles": {
    "overlay": {
      "fontSize": 28,
      "fontWeight": "w800",
      "fontFamily": "Inter",
      "color": "#8B5E3C",
      "textAlign": "center"
    },
    "body_text": {
      "fontSize": 14,
      "fontWeight": "w400",
      "color": "#666666"
    },
    "small_caption": {
      "fontSize": 12,
      "fontWeight": "w500",
      "color": "#999999"
    }
  }
}
```

---

### Step 3: Centralize Assets

#### Before (Hardcoded URLs)
```dart
Lottie.asset(
  'assets/images/Bibi_Onboarding_Leftt.lottie',
  width: 200.0.w,
),
// Audio URL hardcoded in bloc
'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_5.mp3',
```

#### After (Asset Registry)
```json
"assets": {
  "animations": {
    "Bibi_Onboarding_Leftt.lottie": "gs://bibi-app-d41a0.firebasestorage.app/animations/Bibi_Onboarding_Leftt.lottie"
  },
  "audio": {
    "onboarding_5_en": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_5.mp3",
    "onboarding_5_ur": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_5_urdu.mp3"
  }
}
```

Then reference by key:
```json
"components": [{
  "type": "lottie",
  "assetKey": "Bibi_Onboarding_Leftt.lottie"
}]
```

---

### Step 4: Update Page Widget Implementation

Replace the hardcoded page with a dynamic renderer:

#### Before (Individual Page File)
```dart
// File: lib/pages/onboarding_page_5.dart
class OnboardingPage5 extends StatefulWidget {
  @override
  State<OnboardingPage5> createState() => _OnboardingPage5State();
}

class _OnboardingPage5State extends State<OnboardingPage5> {
  // ... all manual implementation
}
```

#### After (Single Dynamic Renderer)
```dart
// File: lib/pages/onboarding_flow_dynamic.dart (now handles ALL pages)
class OnboardingFlowDynamic extends StatefulWidget {
  final String configName; // "onboardingFlow"
  
  const OnboardingFlowDynamic({
    Key? key,
    required this.configName,
  }) : super(key: key);

  @override
  State<OnboardingFlowDynamic> createState() => _OnboardingFlowDynamicState();
}

class _OnboardingFlowDynamicState extends State<OnboardingFlowDynamic> {
  late PageConfiguration _configuration;
  int _currentPageIndex = 0;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    try {
      final contentService = DynamicContentService();
      _configuration = await contentService.loadPageConfiguration(
        configName: widget.configName,
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Failed to load: $e';
        _isLoading = false;
      });
    }
  }

  void _nextPage() {
    if (_currentPageIndex < _configuration.pages.length - 1) {
      setState(() => _currentPageIndex++);
    } else {
      _completeFlow();
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      setState(() => _currentPageIndex--);
    }
  }

  void _completeFlow() {
    // Navigate away or show completion
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _playAudio(String? url) {
    if (url != null) {
      context.read<AudioBloc>().add(PlayAudioEvent(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error.isNotEmpty) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    final currentPage = _configuration.getPageByOrder(_currentPageIndex);
    if (currentPage == null) {
      return const Scaffold(body: Center(child: Text('Page not found')));
    }

    // Use the unified renderer
    return OnboardingPageRenderer.renderOnboardingPage(
      configuration: _configuration,
      pageId: currentPage.id,
      currentLocale: context.read<LanguageBloc>().state.currentLocale,
      context: context,
      onPageComplete: (_) => _nextPage(),
      onPreviousPage: (_) => _previousPage(),
      onPlayAudio: _playAudio,
      onSkipFlow: _completeFlow,
    );
  }
}
```

---

### Step 5: Update Navigation

#### Before (Navigate to Specific Page)
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const OnboardingPage5(),
  ),
);
```

#### After (Navigate to Dynamic Flow)
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const OnboardingFlowDynamic(
      configName: 'onboardingFlow',
    ),
  ),
);
```

---

### Step 6: Update Flutter App File

#### Before (Multiple Page Routes)
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
      routes: {
        '/onboarding_1': (context) => const OnboardingPage1(),
        '/onboarding_2': (context) => const OnboardingPage2(),
        '/onboarding_3': (context) => const OnboardingPage3(),
        '/onboarding_4': (context) => const OnboardingPage4(),
        '/onboarding_5': (context) => const OnboardingPage5(),  // ← Remove
        '/onboarding_6': (context) => const OnboardingPage6(),  // ← Remove
        '/onboarding_7': (context) => const OnboardingPage7(),  // ← Remove
        // ... more hardcoded pages
      },
    );
  }
}
```

#### After (Single Dynamic Route)
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
      routes: {
        // All pages now use the same route
        '/onboarding': (context) => const OnboardingFlowDynamic(
          configName: 'onboardingFlow',
        ),
        '/dashboard': (context) => const DashboardScreen(),
        '/quiz': (context) => const QuizScreen(),
        // ... other routes
      },
    );
  }
}
```

---

## Complete File Changes

### Files to Create
- ✅ `lib/models/dynamic_page_models.dart` (New)
- ✅ `lib/services/component_renderer.dart` (New)
- ✅ `lib/services/page_renderer.dart` (New)
- ✅ `lib/services/dynamic_content_service.dart` (New)

### Files to Modify
- [ ] `lib/main.dart` - Update routes
- [ ] `lib/pages/onboarding_flow_dynamic.dart` - Update to use new system (if exists)
- [ ] `lib/bloc/onboarding_bloc.dart` - Keep for state management if needed

### Files to Remove (Eventually)
- [ ] `lib/pages/onboarding_page_5.dart`
- [ ] `lib/pages/onboarding_page_6.dart`
- [ ] `lib/pages/onboarding_page_7.dart`
- [ ] `lib/pages/onboarding_page_8.dart`
- [ ] `lib/pages/onboarding_page_9.dart`
- [ ] `lib/pages/onboarding_page_10.dart`
- [ ] `lib/pages/onboarding_page_11.dart`
- [ ] Duplicate code in other page files

### Files to Keep/Update
- ✅ `lib/services/firebase_content_service.dart` - Keep for backward compatibility
- ✅ `lib/services/remote_asset_service.dart` - Already being used
- ✅ `lib/bloc/onboarding_bloc.dart` - Can simplify but keep for state
- ✅ `assets/jsons/*.json` - Use as fallback

---

## Testing Checklist

### Before Migration
- [ ] All hardcoded pages render correctly
- [ ] Audio plays correctly
- [ ] Navigation works
- [ ] Offline mode works

### During Migration
- [ ] JSON structure validates
- [ ] Models parse correctly
- [ ] Local JSON loads
- [ ] Firebase document created
- [ ] Renderers work with sample data
- [ ] Asset URLs resolve

### After Migration
- [ ] Page renders identically to old version
- [ ] Audio plays automatically
- [ ] Navigation (next/prev) works
- [ ] Offline fallback works
- [ ] Cache is used on second load
- [ ] Force refresh updates content
- [ ] Language switching works
- [ ] All pages load successfully

---

## Rollback Plan

If issues occur, revert changes:

```bash
# Keep new system in parallel, add flag to switch
final useDynamicPages = true; // Change to false to use old system

if (useDynamicPages) {
  return OnboardingFlowDynamic();
} else {
  return OnboardingPage5(); // Old hardcoded page
}
```

---

## Performance Comparison

### Before (Hardcoded)
- Build time: Compile all pages into binary
- App size: ~5MB+ (all UIs hardcoded)
- Update: Requires new app release
- Loading: Instant (already in memory)

### After (JSON-Driven)
- Build time: Faster (less code in binary)
- App size: ~2-3MB (UIs in JSON)
- Update: Instantly via Firebase
- Loading: ~500ms network + cache

---

## Common Issues & Solutions

### Issue: Pages not loading
**Solution**: Check DynamicContentService initialization
```dart
@override
void initState() {
  super.initState();
  _initService();
}

Future<void> _initService() async {
  final service = DynamicContentService();
  await service.initialize(); // Critical!
}
```

### Issue: Assets not found
**Solution**: Verify asset keys in registry match component references
```json
// Registry
"assets": {
  "animations": {
    "my_animation": "gs://..."  // ← Key must match
  }
}

// Component
{
  "assetKey": "my_animation"  // ← Must match exactly
}
```

### Issue: Styles not applying
**Solution**: Ensure styleRef exists and is spelled correctly
```json
// Defined
"styleTokens": {
  "textStyles": {
    "overlay": {...}  // ← Style name
  }
}

// Referenced
{
  "styleRef": "overlay"  // ← Must match exactly
}
```

### Issue: Audio not playing
**Solution**: Verify audio URL and language key
```json
"audio": {
  "English": "gs://...",     // ← Language must match
  "اردو": "gs://..."
}
```

---

## Gradual Migration Strategy

### Phase 1: Prepare (Week 1)
- [ ] Create JSON files
- [ ] Set up Firestore collections
- [ ] Implement new renderers
- [ ] Test with sample data

### Phase 2: Pilot (Week 2)
- [ ] Deploy new system in parallel
- [ ] Test all pages thoroughly
- [ ] Get user feedback
- [ ] Fix issues

### Phase 3: Migrate (Week 3)
- [ ] Update all page routes
- [ ] Remove hardcoded pages one by one
- [ ] Update tests
- [ ] Release new version

### Phase 4: Cleanup (Week 4)
- [ ] Remove old code
- [ ] Delete old page files
- [ ] Update documentation
- [ ] Monitor for issues

---

## Documentation Updates

Update these docs with new system info:
- [ ] README.md
- [ ] CONTRIBUTING.md
- [ ] Architecture.md (new)
- [ ] Developer guide (new)

---

**Version**: 2.0.0  
**Estimated Time**: 2-4 weeks for complete migration  
**Difficulty**: Medium
