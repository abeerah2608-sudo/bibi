/// Comprehensive guide to migrate onboarding and dashboard pages
/// to dynamically fetch content from Firebase
/// 
/// Created: 2026-04-28
/// 
/// ## Overview
/// This guide explains how to use the new Firebase-based content system
/// to dynamically load onboarding pages and dashboard configuration.
/// 
/// ## Components Created
/// 
/// 1. **FirebaseContentService** (`services/firebase_content_service.dart`)
///    - Fetches onboarding flow and dashboard configuration from Firestore
///    - Provides streaming endpoints for real-time updates
///    - Handles errors and logging
/// 
/// 2. **Data Models**
///    - `models/onboarding_models.dart`: OnboardingFlowConfig, OnboardingPageData, AnimationConfig
///    - `models/dashboard_models.dart`: DashboardConfig and related models
/// 
/// 3. **BLoC State Management**
///    - `bloc/onboarding_bloc.dart`: Manages onboarding flow state
///    - `bloc/dashboard_bloc.dart`: Manages dashboard configuration state
/// 
/// 4. **UI Pages**
///    - `pages/onboarding_flow_dynamic.dart`: Firebase-powered onboarding
///    - Dashboard can be refactored similarly
/// 
/// ## Firebase Firestore Structure
/// 
/// Collection: `content`
/// 
/// Document: `onboarding_flow`
/// ```json
/// {
///   "onboarding_pages": [
///     {
///       "id": "page_1",
///       "order": 0,
///       "textKey": "assalam_o_alaikum",
///       "translations": {
///         "English": "Assalam-o-Alaikum!",
///         "اردو": "السلام علیکم!",
///         "Roman Urdu": "Assalam-o-Alaikum!"
///       },
///       "englishAudio": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_1.mp3",
///       "urduAudio": "gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_1_urdu.mp3",
///       "animationPath": "gs://bibi-app-d41a0.firebasestorage.app/animations/Bibi_Onboarding_Leftt.lottie",
///       "animation": {
///         "scale": 3.7,
///         "translateXPercent": 0.75,
///         "translateYPercent": -0.10,
///         "alignment": "centerLeft"
///       }
///     }
///   ]
/// }
/// ```
/// 
/// Document: `dashboard_config`
/// Follows the structure in `assets/jsons/dashboard.json`
/// 
/// ## How to Use
/// 
/// ### Step 1: Update BLoC Providers in main.dart
/// ```dart
/// MultiBlocProvider(
///   providers: [
///     BlocProvider(create: (context) => LanguageBloc()),
///     BlocProvider(create: (context) => OnboardingBloc()),
///     BlocProvider(create: (context) => DashboardBloc()),
///     BlocProvider(create: (_) => FavoritesBloc()),
///   ],
///   child: // ... rest of app
/// )
/// ```
/// 
/// ### Step 2: Replace Onboarding Navigation
/// In `pages/splashScreen.dart`, replace:
/// ```dart
/// OnboardingFlow()  // Old hardcoded version
/// ```
/// With:
/// ```dart
/// OnboardingFlowDynamic()  // New Firebase-powered version
/// ```
/// 
/// ### Step 3: Stream Updates (Optional)
/// To get real-time updates when content changes on Firebase:
/// 
/// ```dart
/// final contentService = FirebaseContentService();
/// contentService.onboardingFlowStream().listen((config) {
///   // Handle updated onboarding flow
/// });
/// ```
/// 
/// ## Advantages
/// 
/// 1. **Dynamic Content**: Update onboarding/dashboard without app updates
/// 2. **A/B Testing**: Serve different content to different users
/// 3. **Real-time Updates**: Changes reflect immediately via streams
/// 4. **Multilingual**: Translations stored in Firebase
/// 5. **Reduced APK Size**: No static assets in app bundle
/// 6. **Remote Configuration**: Manage content from Firebase Console
/// 
/// ## Migration Steps
/// 
/// ### For Onboarding Pages:
/// 1. ✅ Created `FirebaseContentService`
/// 2. ✅ Created `OnboardingFlowConfig` and `OnboardingPageData` models
/// 3. ✅ Created `OnboardingBloc` for state management
/// 4. ✅ Created `OnboardingFlowDynamic` page
/// 5. TODO: Update navigation in splash screen or language selection
/// 6. TODO: Upload JSON to Firestore `content/onboarding_flow`
/// 
/// ### For Dashboard:
/// 1. ✅ Created `DashboardConfig` model
/// 2. ✅ Created `DashboardBloc` for state management
/// 3. TODO: Create `DashboardDynamic` page (similar to `OnboardingFlowDynamic`)
/// 4. TODO: Update dashboard imports and setup
/// 5. TODO: Upload JSON to Firestore `content/dashboard_config`
/// 
/// ## Testing
/// 
/// 1. Ensure Firebase is initialized properly
/// 2. Firestore security rules allow reading from `content` collection
/// 3. Test both onboarding and dashboard with real Firebase data
/// 4. Test real-time updates by modifying Firestore documents
/// 
/// ## Error Handling
/// 
/// The system includes:
/// - Loading states
/// - Error states with retry buttons
/// - Fallback to local assets if Firebase fails
/// - Comprehensive debugging logs
/// 
/// ## Environment Variables
/// 
/// Firebase configuration is in `lib/firebase_options.dart`
/// Projects configured:
/// - Android: bibi-e2d47
/// - iOS: bibi-e2d47
/// - Web: bibi-e2d47
/// 
/// ## Performance Considerations
/// 
/// 1. **Caching**: Documents are cached by Firestore SDK
/// 2. **Lazy Loading**: Content loaded only when needed
/// 3. **Stream Optimization**: Only subscribe to streams when needed
/// 4. **Network**: Firestore handles offline mode automatically
/// 
/// ## Troubleshooting
/// 
/// ### Issue: "Failed to fetch onboarding flow from Firebase"
/// - Check Firestore collection structure
/// - Verify document IDs match ('onboarding_flow', 'dashboard_config')
/// - Check security rules allow reading
/// 
/// ### Issue: Audio/Images not loading
/// - Verify Firebase Storage URLs in JSON
/// - Check Storage security rules
/// - Ensure URLs are publicly accessible
/// 
/// ### Issue: Old data displaying
/// - Clear app cache
/// - Check Firestore has latest data
/// - Verify real-time streams working
/// 
/// ## Future Enhancements
/// 
/// 1. Content versioning system
/// 2. Progressive rollout of updates
/// 3. Content analytics (view count, completion rate)
/// 4. A/B testing framework
/// 5. Content scheduling
/// 6. User-specific content variants
/// 
/// ## Support Files
/// 
/// - `lib/services/firebase_content_service.dart` - Main service
/// - `lib/models/onboarding_models.dart` - Onboarding data models
/// - `lib/models/dashboard_models.dart` - Dashboard data models
/// - `lib/bloc/onboarding_*.dart` - Onboarding BLoC files
/// - `lib/bloc/dashboard_*.dart` - Dashboard BLoC files
/// - `lib/pages/onboarding_flow_dynamic.dart` - Dynamic onboarding page

