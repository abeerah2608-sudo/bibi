// ============================================================================
// DYNAMIC ONBOARDING FLOW PAGE (REFACTORED)
// ============================================================================
// Replace: lib/pages/onboarding_flow_static.dart
// This page loads the entire onboarding flow from JSON/Firebase
// and renders pages dynamically with full navigation support
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/dynamic_page_models.dart';
import '../services/dynamic_content_service.dart';
import '../services/page_renderer.dart';
import '../bloc/language/language_bloc.dart';
import '../bloc/language/language_state.dart';
import '../mixins/onboarding_audio_mixin.dart';

class DynamicOnboardingFlowPage extends StatefulWidget {
  const DynamicOnboardingFlowPage({Key? key}) : super(key: key);

  @override
  State<DynamicOnboardingFlowPage> createState() =>
      _DynamicOnboardingFlowPageState();
}

class _DynamicOnboardingFlowPageState extends State<DynamicOnboardingFlowPage> {
  late DynamicPageConfig _configuration;
  int _currentPageIndex = 0;
  bool _isLoading = true;
  String? _error;

  final _contentService = DynamicContentService();

  @override
  void initState() {
    super.initState();
    _loadOnboardingFlow();
  }

  /// Load the complete onboarding configuration from JSON/Firebase
  Future<void> _loadOnboardingFlow() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load configuration with fallback chain:
      // 1. Memory cache (fastest)
      // 2. Firebase Firestore (fresh)
      // 3. Local JSON (assets/jsons/)
      // 4. Cached data (if available)
      _configuration = await _contentService.loadPageConfiguration(
  collectionName: 'pages',
);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Failed to load onboarding: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_error ?? 'Unknown error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  /// Get current page
  PageModel get _currentPage =>
      _configuration.pages[_currentPageIndex];

  /// Get current page ID
  String get _currentPageId => _currentPage.id;

  /// Check if there's a next page
  bool get _hasNextPage => _currentPageIndex < _configuration.pages.length - 1;

  /// Check if there's a previous page
  bool get _hasPreviousPage => _currentPageIndex > 0;

  /// Navigate to next page
  void _nextPage() {
    if (_hasNextPage) {
      setState(() => _currentPageIndex++);
    }
  }

  /// Navigate to previous page
  void _previousPage() {
    if (_hasPreviousPage) {
      setState(() => _currentPageIndex--);
    }
  }

  /// Skip to next page or complete flow
  void _skipFlow() {
    if (_hasNextPage) {
      _nextPage();
    } else {
      _completeOnboarding();
    }
  }

  /// Handle onboarding completion
  void _completeOnboarding() {
    // Navigate to home or next screen
    if (mounted) {
      // Ensure any active onboarding audio is stopped before leaving flow
      try {
        final active = OnboardingAudioMixin.activePlayer;
        if (active != null) {
          active.stop();
          debugPrint('⏹️ Stopped global onboarding audio before completing flow');
        }
      } catch (e) {
        debugPrint('⚠️ Failed to stop onboarding audio: $e');
      }

      Navigator.of(context).pushNamed('/dashboard');
    }
  }

  /// Handle audio playback (optional)
  void _playAudio(String? audioUrl) {
    if (audioUrl != null) {
      debugPrint('🔊 Playing audio: $audioUrl');
      // TODO: Integrate with AudioBloc or AudioService
      // Example:
      // context.read<AudioBloc>().add(PlayAudioEvent(audioUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    // Show error state
    if (_error != null) {
      return _buildErrorScreen();
    }

    // Get current locale from LanguageBloc
    final languageState = context.read<LanguageBloc>().state;
    final locale = languageState is LanguageSelected 
        ? (languageState as LanguageSelected).language 
        : 'English';

    // Render current page using OnboardingPageRenderer
    return Scaffold(
      body: OnboardingPageRenderer.renderOnboardingPage(
        configuration: _configuration,
        pageId: _currentPageId,
        currentLocale: locale,
        context: context,
        onPageComplete: (_) => _nextPage(),
        onPreviousPage: (_) => _previousPage(),
        onPlayAudio: _playAudio,
        onSkipFlow: _skipFlow,
      ),
      // Optional: Show page indicator
      floatingActionButton: _buildPageIndicator(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Page indicator showing current position
  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _configuration.pages.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == _currentPageIndex
                  ? const Color(0xFF8B5E3C)
                  : const Color(0xFF8B5E3C).withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  /// Loading screen
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6D3), Color(0xFFFDEDDC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF8B5E3C),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Loading onboarding...',
                style: TextStyle(
                  color: Color(0xFF8B5E3C),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Error screen with retry option
  Widget _buildErrorScreen() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6D3), Color(0xFFFDEDDC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFF8B5E3C),
              ),
              const SizedBox(height: 16),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B5E3C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8B5E3C),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadOnboardingFlow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5E3C),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
