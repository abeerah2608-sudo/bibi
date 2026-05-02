import 'package:flutter/material.dart';
import '../models/dynamic_page_models.dart';
import 'component_renderer.dart';

class PageRenderer {
  static Widget render({
    required PageModel pageModel,
    required AssetRegistry assetRegistry,
    required StyleTokens styleTokens,
    required String currentLocale,
    required BuildContext context,
    Map<String, Function(String)>? actionHandlers,
  }) {
    final componentRenderer = ComponentRenderer(
      assetRegistry: assetRegistry,
      styleTokens: styleTokens,
      currentLocale: currentLocale,
    );

    final renderedComponents = <Widget>[];

    debugPrint("🔥 Rendering page: ${pageModel.id}");
    debugPrint("🔥 Components: ${pageModel.components.length}");

    for (final component in pageModel.components) {
      try {
        renderedComponents.add(
          componentRenderer.render(component, context),
        );
      } catch (e) {
        debugPrint("❌ Component failed: ${component.type} → $e");

        renderedComponents.add(
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text("⚠️ Component failed"),
          ),
        );
      }
    }

    return LayoutRenderer.render(
      layout: pageModel.layout,
      children: renderedComponents,
      context: context,
      backgroundColor: pageModel.background?.getColor(),
    );
  }

  static Widget renderScaffold({
    required PageModel pageModel,
    required AssetRegistry assetRegistry,
    required StyleTokens styleTokens,
    required String currentLocale,
    required BuildContext context,
    String? appBarTitle,
    bool showAppBar = false,
  }) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(title: Text(appBarTitle ?? pageModel.id))
          : null,
      body: render(
        pageModel: pageModel,
        assetRegistry: assetRegistry,
        styleTokens: styleTokens,
        currentLocale: currentLocale,
        context: context,
      ),
    );
  }
}class PageConfigurationRenderer {
  static Widget renderPage({
    required DynamicPageConfig configuration,
    required String pageId,
    required String currentLocale,
    required BuildContext context,
  }) {
    final page = configuration.pages
        .where((p) => p.id == pageId)
        .cast<PageModel?>()
        .firstOrNull;

    if (page == null) {
      return Center(child: Text("Page not found: $pageId"));
    }

    return PageRenderer.render(
      pageModel: page,
      assetRegistry: configuration.assets,
      styleTokens: configuration.styleTokens,
      currentLocale: currentLocale,
      context: context,
    );
  }

  static PageModel? getNextPage(
    DynamicPageConfig config,
    String currentId,
  ) {
    final pages = config.pages;
    final index = pages.indexWhere((p) => p.id == currentId);

    if (index == -1 || index + 1 >= pages.length) return null;
    return pages[index + 1];
  }

  static PageModel? getPreviousPage(
    DynamicPageConfig config,
    String currentId,
  ) {
    final pages = config.pages;
    final index = pages.indexWhere((p) => p.id == currentId);

    if (index <= 0) return null;
    return pages[index - 1];
  }
}
/// Specialized renderer for onboarding flows with audio, navigation, etc.
class OnboardingPageRenderer extends PageConfigurationRenderer {
  /// Render an onboarding page with audio support
  static Widget renderOnboardingPage({
    required DynamicPageConfig configuration,
    required String pageId,
    required String currentLocale,
    required BuildContext context,
    required Function(String pageId) onPageComplete,
    required Function(String pageId) onPreviousPage,
    required Function(String? audioUrl) onPlayAudio,
    VoidCallback? onSkipFlow,
  }) {
    final pageModel = configuration.getPageById(pageId);
    if (pageModel == null) {
      return Center(child: Text('Page not found: $pageId'));
    }

    return _buildOnboardingLayout(
      pageModel: pageModel,
      configuration: configuration,
      currentLocale: currentLocale,
      context: context,
      pageId: pageId,
      onPageComplete: onPageComplete,
      onPreviousPage: onPreviousPage,
      onPlayAudio: onPlayAudio,
      onSkipFlow: onSkipFlow,
    );
  }

  // ========================================================================
  // INTERNAL LAYOUT BUILDERS
  // ========================================================================

  /// Build the complete onboarding layout with navigation
  static Widget _buildOnboardingLayout({
    required PageModel pageModel,
    required DynamicPageConfig configuration,
    required String currentLocale,
    required BuildContext context,
    required String pageId,
    required Function(String pageId) onPageComplete,
    required Function(String pageId) onPreviousPage,
    required Function(String? audioUrl) onPlayAudio,
    VoidCallback? onSkipFlow,
  }) {
    // Auto-play audio if available
    if (pageModel.audio != null) {
      final audioMap = pageModel.audio;

final audioUrl =
    audioMap?[currentLocale] ??
    audioMap?['English'] ??
    audioMap?.values.firstOrNull;
      if (audioUrl != null) {
        // Delay to allow widget to build first
        Future.delayed(const Duration(milliseconds: 500), () {
          onPlayAudio(audioUrl);
        });
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onPreviousPage(pageId);
      },
      child: Stack(
        children: [
          // Main page content
          PageRenderer.render(
            pageModel: pageModel,
            assetRegistry: configuration.assets ??
                AssetRegistry(animations: {}, images: {}, audio: {}),
            styleTokens:
                configuration.styleTokens ?? StyleTokens(textStyles: {}),
            currentLocale: currentLocale,
            context: context,
          ),

          // Navigation controls
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: _buildNavigationControls(
              configuration: configuration,
              currentPageId: pageId,
              onNext: onPageComplete,
              onPrevious: onPreviousPage,
              onSkip: onSkipFlow,
            ),
          ),
        ],
      ),
    );
  }

  /// Build navigation controls (prev/next buttons)
  static Widget _buildNavigationControls({
    required DynamicPageConfig configuration,
    required String currentPageId,
    required Function(String pageId) onNext,
    required Function(String pageId) onPrevious,
    VoidCallback? onSkip,
  }) {
    final currentPage = configuration.getPageById(currentPageId);
    final nextPage =
        PageConfigurationRenderer.getNextPage(configuration, currentPageId);
    final prevPage =
        PageConfigurationRenderer.getPreviousPage(configuration, currentPageId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          if (prevPage != null)
            ElevatedButton(
              onPressed: () => onPrevious(currentPageId),
              child: const Text('← Back'),
            )
          else
            const SizedBox.shrink(),

          // Page indicator
          Text(
              '${(currentPage?.order ?? 0) + 1}/${configuration.pages.length}'),

          // Skip button or Next/Complete button
          if (onSkip != null &&
              (currentPage?.order ?? 0) < configuration.pages.length - 1)
            TextButton(
              onPressed: onSkip,
              child: const Text('Skip'),
            )
          else if (nextPage != null)
            ElevatedButton(
              onPressed: () => onNext(nextPage.id),
              child: const Text('Next →'),
            )
          else
            ElevatedButton(
              onPressed: () => onNext(currentPageId),
              child: const Text('Complete'),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// DASHBOARD RENDERER (Specific Implementation)
// ============================================================================

/// Specialized renderer for dashboard pages
class DashboardPageRenderer extends PageConfigurationRenderer {
  /// Render a dashboard page with tab support
  static Widget renderDashboard({
    required DynamicPageConfig configuration,
    required String currentLocale,
    required BuildContext context,
  }) {
    final mainPage = configuration.getPageById('dashboard_main');
    if (mainPage == null) {
      return const Scaffold(
        body: Center(child: Text('Dashboard not found')),
      );
    }

    return Scaffold(
      body: PageRenderer.render(
        pageModel: mainPage,
        assetRegistry: configuration.assets ??
            AssetRegistry(animations: {}, images: {}, audio: {}),
        styleTokens: configuration.styleTokens ?? StyleTokens(textStyles: {}),
        currentLocale: currentLocale,
        context: context,
      ),
    );
  }
}