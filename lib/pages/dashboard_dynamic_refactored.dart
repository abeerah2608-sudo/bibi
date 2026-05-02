// ============================================================================
// DYNAMIC DASHBOARD PAGE (REFACTORED)
// ============================================================================
// Replace: lib/pages/dashboard_page.dart
// This page loads the dashboard configuration from JSON/Firebase
// and renders it dynamically
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/dynamic_page_models.dart';
import '../services/dynamic_content_service.dart';
import '../services/page_renderer.dart';
import '../bloc/language/language_bloc.dart';
import '../bloc/language/language_state.dart';

class DynamicDashboardPage extends StatefulWidget {
  const DynamicDashboardPage({Key? key}) : super(key: key);

  @override
  State<DynamicDashboardPage> createState() => _DynamicDashboardPageState();
}

class _DynamicDashboardPageState extends State<DynamicDashboardPage> {
  late DynamicPageConfig _configuration;
  bool _isLoading = true;
  String? _error;

  final _contentService = DynamicContentService();

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  /// Load dashboard configuration
  Future<void> _loadDashboard() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      _configuration = await _contentService.loadPageConfiguration(
        collectionName: 'pages',
        forceRefresh: false,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Failed to load dashboard: $e';
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

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    // Error state
    if (_error != null) {
      return _buildErrorScreen();
    }

    // Get locale
    final languageState = context.read<LanguageBloc>().state;
    final locale = languageState is LanguageSelected
        ? languageState.language
        : 'English';

    // Get first page (dashboard usually has single page)
    final pageModel = _configuration.pages.isNotEmpty
      ? _configuration.pages[0]
        : _buildEmptyPage();

    // Render dashboard
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF8B5E3C),
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        color: const Color(0xFF8B5E3C),
        child: PageRenderer.render(
          pageModel: pageModel,
          assetRegistry: _configuration.assets ?? AssetRegistry(animations: {}, images: {}, audio: {}),
          styleTokens: _configuration.styleTokens ?? StyleTokens(textStyles: {}),
          currentLocale: locale,
          context: context,
        ),
      ),
    );
  }

  /// Create an empty page model for fallback
  PageModel _buildEmptyPage() {
    return PageModel(
      id: 'empty',
      order: 0,
      layout: LayoutModel(
        type: 'column',
        gap: 16,
        mainAxisAlignment: 'center',
        crossAxisAlignment: 'center',
      ),
      components: [
        ComponentModel(
          id: 'empty_text',
          type: 'text',
          content: {
            'translations': {'English': 'No dashboard content available'}
          },
          position: PositionModel(
            alignment: 'center',
            padding: EdgeInsetsModel(all: 16),
          ),
        ),
      ],
    );
  }

  /// Loading screen
  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF8B5E3C),
        elevation: 0,
        centerTitle: true,
      ),
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
                'Loading dashboard...',
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

  /// Error screen
  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF8B5E3C),
        elevation: 0,
        centerTitle: true,
      ),
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
                'Failed to load dashboard',
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
                onPressed: _loadDashboard,
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
