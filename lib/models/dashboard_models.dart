// models/dashboard_models.dart

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Model for tab configuration
class TabConfig extends Equatable {
  final String id;
  final String labelKey;
  final Map<String, String> translations;

  const TabConfig({
    required this.id,
    required this.labelKey,
    required this.translations,
  });

  factory TabConfig.fromJson(Map<String, dynamic> json) {
    return TabConfig(
      id: json['id'] as String? ?? '',
      labelKey: json['labelKey'] as String? ?? '',
      translations: Map<String, String>.from(
        (json['translations'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  @override
  List<Object?> get props => [id, labelKey, translations];
}

/// Model for video card data from Firebase
class VideoCardFirebaseData extends Equatable {
  final String id;
  final String accentColor;
  final String audioContentId;
  final String videoUrl;
  final String duration;
  final String englishAudio;
  final String urduAudio;
  final String favoriteId;
  final String subtitleKey;
  final String thumbnail;
  final String titleKey;
  final Map<String, String> titleTranslations;
  final Map<String, String> subtitleTranslations;

  const VideoCardFirebaseData({
    required this.id,
    required this.accentColor,
    required this.audioContentId,
    this.videoUrl = '',
    required this.duration,
    required this.englishAudio,
    required this.urduAudio,
    required this.favoriteId,
    required this.subtitleKey,
    required this.thumbnail,
    required this.titleKey,
    required this.titleTranslations,
    required this.subtitleTranslations,
  });

  factory VideoCardFirebaseData.fromJson(Map<String, dynamic> json) {
    final translations = (json['translations'] as Map<String, dynamic>?) ?? {};
    
    return VideoCardFirebaseData(
      id: json['id'] as String? ?? '',
      accentColor: json['accentColor'] as String? ?? '#E91E8C',
      audioContentId: json['audioContentId'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      duration: json['duration'] as String? ?? '0:00',
      englishAudio: json['englishAudio'] as String? ?? '',
      urduAudio: json['urduAudio'] as String? ?? '',
      favoriteId: json['favoriteId'] as String? ?? '',
      subtitleKey: json['subtitleKey'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      titleKey: json['titleKey'] as String? ?? '',
      titleTranslations: Map<String, String>.from(
        (translations['title'] as Map<String, dynamic>?) ?? {},
      ),
      subtitleTranslations: Map<String, String>.from(
        (translations['subtitle'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        accentColor,
        audioContentId,
        videoUrl,
        duration,
        englishAudio,
        urduAudio,
        favoriteId,
        subtitleKey,
        thumbnail,
        titleKey,
        titleTranslations,
        subtitleTranslations,
      ];
}

/// Model for quiz card configuration
class QuizCardConfig extends Equatable {
  final int quizId;
  final int totalQuestions;
  final String subtitleKey;
  final String titleKey;
  final Map<String, String> titleTranslations;
  final Map<String, String> subtitleTranslations;
  final Map<String, String> getStartedTranslations;
  final Map<String, String> questionsAnsweredTranslations;
  final Map<String, String> quizCompleteTranslations;

  const QuizCardConfig({
    required this.quizId,
    required this.totalQuestions,
    required this.subtitleKey,
    required this.titleKey,
    required this.titleTranslations,
    required this.subtitleTranslations,
    required this.getStartedTranslations,
    required this.questionsAnsweredTranslations,
    required this.quizCompleteTranslations,
  });

  factory QuizCardConfig.fromJson(Map<String, dynamic> json) {
    final translations = (json['translations'] as Map<String, dynamic>?) ?? {};

    return QuizCardConfig(
      quizId: json['quizId'] as int? ?? 1,
      totalQuestions: json['totalQuestions'] as int? ?? 5,
      subtitleKey: json['subtitleKey'] as String? ?? '',
      titleKey: json['titleKey'] as String? ?? '',
      titleTranslations: Map<String, String>.from(
        (translations['self_examine_card_title'] as Map<String, dynamic>?) ?? {},
      ),
      subtitleTranslations: Map<String, String>.from(
        (translations['self_examine_subtitle'] as Map<String, dynamic>?) ?? {},
      ),
      getStartedTranslations: Map<String, String>.from(
        (translations['get_started'] as Map<String, dynamic>?) ?? {},
      ),
      questionsAnsweredTranslations: Map<String, String>.from(
        (translations['questions_answered'] as Map<String, dynamic>?) ?? {},
      ),
      quizCompleteTranslations: Map<String, String>.from(
        (translations['quiz_complete'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  @override
  List<Object?> get props => [
        quizId,
        totalQuestions,
        subtitleKey,
        titleKey,
        titleTranslations,
        subtitleTranslations,
        getStartedTranslations,
        questionsAnsweredTranslations,
        quizCompleteTranslations,
      ];
}

/// Model for welcome banner configuration
class WelcomeBannerConfig extends Equatable {
  final String backgroundColor;
  final String careTextKey;
  final String emoji;
  final String greetingKey;
  final Map<String, String> greetingTranslations;
  final Map<String, String> careTextTranslations;

  const WelcomeBannerConfig({
    required this.backgroundColor,
    required this.careTextKey,
    required this.emoji,
    required this.greetingKey,
    required this.greetingTranslations,
    required this.careTextTranslations,
  });

  factory WelcomeBannerConfig.fromJson(Map<String, dynamic> json) {
    final translations = (json['translations'] as Map<String, dynamic>?) ?? {};

    return WelcomeBannerConfig(
      backgroundColor: json['backgroundColor'] as String? ?? '#FFF4F4',
      careTextKey: json['careTextKey'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '👋',
      greetingKey: json['greetingKey'] as String? ?? '',
      greetingTranslations: Map<String, String>.from(
        (translations['good_morning'] as Map<String, dynamic>?) ?? {},
      ),
      careTextTranslations: Map<String, String>.from(
        (translations['breast_care'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  @override
  List<Object?> get props => [
        backgroundColor,
        careTextKey,
        emoji,
        greetingKey,
        greetingTranslations,
        careTextTranslations,
      ];
}

/// Model for language dialog configuration
class LanguageDialogConfig extends Equatable {
  final String backgroundColor;
  final int borderRadius;
  final List<LanguageOption> languages;
  final Map<String, String> chooseLangTranslations;
  final Map<String, String> selectLangTranslations;

  const LanguageDialogConfig({
    required this.backgroundColor,
    required this.borderRadius,
    required this.languages,
    required this.chooseLangTranslations,
    required this.selectLangTranslations,
  });

  factory LanguageDialogConfig.fromJson(Map<String, dynamic> json) {
    final translations = (json['translations'] as Map<String, dynamic>?) ?? {};
    final languagesList = (json['languages'] as List<dynamic>?) ?? [];

    return LanguageDialogConfig(
      backgroundColor: json['backgroundColor'] as String? ?? '#FFF8F8',
      borderRadius: json['borderRadius'] as int? ?? 24,
      languages: languagesList
          .map((lang) => LanguageOption.fromJson(lang as Map<String, dynamic>))
          .toList(),
      chooseLangTranslations: Map<String, String>.from(
        (translations['choose_language'] as Map<String, dynamic>?) ?? {},
      ),
      selectLangTranslations: Map<String, String>.from(
        (translations['select_language_preference'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  @override
  List<Object?> get props => [
        backgroundColor,
        borderRadius,
        languages,
        chooseLangTranslations,
        selectLangTranslations,
      ];
}

class LanguageOption extends Equatable {
  final String id;
  final String label;
  final String sublabel;

  const LanguageOption({
    required this.id,
    required this.label,
    required this.sublabel,
  });

  factory LanguageOption.fromJson(Map<String, dynamic> json) {
    return LanguageOption(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      sublabel: json['sublabel'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, label, sublabel];
}

/// Main dashboard configuration model
class DashboardConfig extends Equatable {
  final String backgroundColor;
  final String id;
  final String logoUrl;
  final WelcomeBannerConfig welcomeBanner;
  final QuizCardConfig quizCard;
  final List<TabConfig> tabs;
  final Map<String, List<VideoCardFirebaseData>> videoCards;
  final LanguageDialogConfig languageDialog;

  const DashboardConfig({
    required this.backgroundColor,
    required this.id,
    required this.logoUrl,
    required this.welcomeBanner,
    required this.quizCard,
    required this.tabs,
    required this.videoCards,
    required this.languageDialog,
  });

  factory DashboardConfig.fromJson(Map<String, dynamic> json) {
    debugPrint('🔥 PARSING DASHBOARD CONFIG');
    debugPrint('🔥 Raw JSON keys: ${json.keys.toList()}');
    
    // Extract the dashboard object - EVERYTHING is under 'dashboard' key
    final dashboardData = (json['dashboard'] as Map<String, dynamic>?) ?? {};
    debugPrint('🔥 Dashboard keys: ${dashboardData.keys.toList()}');
    
    // Parse asset mapping from root level
    final assetMapping = (json['assetMapping'] as Map<String, dynamic>?) ?? {};
    final images = (assetMapping['images'] as Map<String, dynamic>?) ?? {};
    
    // Also check logo from dashboard.logo
    String logoUrl = images['Bibi_Logo_Vector_1.png'] as String? ?? '';
    if (logoUrl.isEmpty && dashboardData['logo'] != null) {
      logoUrl = dashboardData['logo']['asset'] as String? ?? '';
    }
    debugPrint('🔥 Logo URL: $logoUrl');

    // Parse dashboard properties
    final backgroundColor = dashboardData['backgroundColor'] as String? ?? '#FFF4F4';
    final id = dashboardData['id'] as String? ?? 'dashboard_main';
    
    // Parse welcome banner from dashboard.welcomeBanner
    final welcomeBannerJson = (dashboardData['welcomeBanner'] as Map<String, dynamic>?) ?? {};
    debugPrint('🔥 WelcomeBanner keys: ${welcomeBannerJson.keys.toList()}');
    final welcomeBanner = WelcomeBannerConfig.fromJson(welcomeBannerJson);

    // Parse quiz card from dashboard.quizCard
    final quizCardJson = (dashboardData['quizCard'] as Map<String, dynamic>?) ?? {};
    debugPrint('🔥 QuizCard keys: ${quizCardJson.keys.toList()}');
    final quizCard = QuizCardConfig.fromJson(quizCardJson);

    // Parse tab bar from dashboard.tabBar
    final tabBarJson = (dashboardData['tabBar'] as Map<String, dynamic>?) ?? {};
    debugPrint('🔥 TabBar keys: ${tabBarJson.keys.toList()}');
    final tabsList = (tabBarJson['tabs'] as List<dynamic>?) ?? [];
    debugPrint('🔥 Tabs count: ${tabsList.length}');
    final tabs = tabsList
        .map((tab) => TabConfig.fromJson(tab as Map<String, dynamic>))
        .toList();

    // Parse video cards from dashboard.videoCards
    final videoCardsData = (dashboardData['videoCards'] as Map<String, dynamic>?) ?? {};
    debugPrint('🔥 VideoCards categories: ${videoCardsData.keys.toList()}');
    
    final Map<String, List<VideoCardFirebaseData>> videoCards = {};

    videoCardsData.forEach((category, cardsList) {
      debugPrint('🔥 Processing category: $category');
      if (cardsList is List) {
        debugPrint('🔥   Cards in $category: ${cardsList.length}');
        videoCards[category] = cardsList
            .map((card) {
              final videoCard = VideoCardFirebaseData.fromJson(card as Map<String, dynamic>);
              debugPrint('🔥     Card: ${videoCard.id}');
              debugPrint('🔥       Title translations: ${videoCard.titleTranslations}');
              debugPrint('🔥       Subtitle translations: ${videoCard.subtitleTranslations}');
              return videoCard;
            })
            .toList();
      }
    });

    // Parse language dialog from dashboard.languageDialog
    final languageDialogJson = (dashboardData['languageDialog'] as Map<String, dynamic>?) ?? {};
    debugPrint('🔥 LanguageDialog keys: ${languageDialogJson.keys.toList()}');
    final languageDialog = LanguageDialogConfig.fromJson(languageDialogJson);

    debugPrint('✅ Dashboard config parsed successfully:');
    debugPrint('   - Background: $backgroundColor');
    debugPrint('   - ${tabs.length} tabs: ${tabs.map((t) => t.id).toList()}');
    debugPrint('   - ${videoCards.keys.length} categories: ${videoCards.keys.toList()}');
    debugPrint('   - Total video cards: ${videoCards.values.fold(0, (sum, list) => sum + list.length)}');

    return DashboardConfig(
      backgroundColor: backgroundColor,
      id: id,
      logoUrl: logoUrl,
      welcomeBanner: welcomeBanner,
      quizCard: quizCard,
      tabs: tabs,
      videoCards: videoCards,
      languageDialog: languageDialog,
    );
  }

  @override
  List<Object?> get props => [
        backgroundColor,
        id,
        logoUrl,
        welcomeBanner,
        quizCard,
        tabs,
        videoCards,
        languageDialog,
      ];
}