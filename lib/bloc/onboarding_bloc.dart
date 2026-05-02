import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/onboarding_models.dart';
import 'package:bibi/services/firebase_content_service.dart';
import 'package:flutter/foundation.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final FirebaseContentService _contentService;
  List<OnboardingPageData>? _cachedPages;
  DateTime? _lastFetchTime;
  static const Duration _cacheTtl = Duration(minutes: 5);

  OnboardingBloc({FirebaseContentService? contentService})
      : _contentService = contentService ?? FirebaseContentService(),
        super(const OnboardingInitial()) {
    on<FetchOnboardingFlowEvent>(_onFetchOnboardingFlow);
  }

  Future<void> _onFetchOnboardingFlow(
    FetchOnboardingFlowEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    final now = DateTime.now();
    final hasFreshMemoryCache = _cachedPages != null &&
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < _cacheTtl &&
        _cachedPages!.isNotEmpty;

    if (!event.forceRefresh && hasFreshMemoryCache) {
      debugPrint('⚡ OnboardingBloc: serving onboarding pages from memory cache');
      emit(OnboardingLoaded(pages: _cachedPages!));
      return;
    }

    // Keep current content visible during soft refreshes.
    if (state is! OnboardingLoaded || event.forceRefresh) {
      emit(const OnboardingLoading());
    }

    try {
      final pagesJson = await _contentService.fetchOnboardingFlow(
        forceRefresh: event.forceRefresh,
      );

      if (pagesJson.isEmpty) {
        emit(const OnboardingError(
          message: 'No onboarding pages found in Firebase',
        ));
        return;
      }

      final pages = <OnboardingPageData>[];

      for (final json in pagesJson) {
        try {
          debugPrint("🔥 RAW PAGE: $json");

          final page = OnboardingPageData.fromJson(json);
          debugPrint(
            '➡️ parsed ${page.id}: audio=${page.englishAudio.isNotEmpty}, logo=${page.logoUrl ?? 'none'}, bg=${page.backgroundImageUrl ?? 'none'}, scale=${page.animation.scale}, align=${page.animation.alignment}',
          );

          pages.add(page);
        } catch (pageError) {
          debugPrint('❌ Error parsing page: $pageError');
          continue;
        }
      }

      // ✅ Sort by order
      pages.sort((a, b) => a.order.compareTo(b.order));

      if (pages.isEmpty) {
        emit(const OnboardingError(
          message: 'No valid onboarding pages found after parsing',
        ));
        return;
      }

      debugPrint("✅ FINAL PARSED PAGES: ${pages.length}");
      for (var p in pages) {
        debugPrint("➡️ ${p.id} | order=${p.order} | textKey=${p.textKey}");
      }

      _cachedPages = List<OnboardingPageData>.unmodifiable(pages);
      _lastFetchTime = DateTime.now();

      emit(OnboardingLoaded(pages: pages));
    } catch (e, stack) {
      debugPrint('❌ OnboardingBloc error: $e\n$stack');
      emit(OnboardingError(message: 'Error: $e'));
    }
  }
}