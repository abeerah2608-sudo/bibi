import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Model for quiz configuration from Firebase
class QuizConfig extends Equatable {
  final String id;
  final String version;
  final int quizId;
  final int totalQuestions;
  final String backgroundColor;
  final TopHeaderConfig topHeaderConfig;
  final BackButtonConfig backButton;
  final LogoConfig logo;
  final QuestionCardConfig questionCard;
  final ProgressCircleConfig progressCircle;
  final QuestionTextConfig questionText;
  final List<QuestionData> questions;
  final AnswerButtonsConfig answerButtons;
  final NavigationButtonsConfig navigationButtons;

  const QuizConfig({
    required this.id,
    required this.version,
    required this.quizId,
    required this.totalQuestions,
    required this.backgroundColor,
    required this.topHeaderConfig,
    required this.backButton,
    required this.logo,
    required this.questionCard,
    required this.progressCircle,
    required this.questionText,
    required this.questions,
    required this.answerButtons,
    required this.navigationButtons,
  });

  factory QuizConfig.fromJson(Map<String, dynamic> json) {
    final quiz = (json['quiz'] as Map<String, dynamic>?) ?? json;
    
    return QuizConfig(
      id: quiz['id'] as String? ?? '',
      version: quiz['version'] as String? ?? '1.0.0',
      quizId: quiz['quizId'] as int? ?? 1,
      totalQuestions: quiz['totalQuestions'] as int? ?? 5,
      backgroundColor: quiz['backgroundColor'] as String? ?? '#FCEEF3',
      topHeaderConfig: TopHeaderConfig.fromJson(
        (quiz['topHeaderConfig'] as Map<String, dynamic>?) ?? {},
      ),
      backButton: BackButtonConfig.fromJson(
        (quiz['backButton'] as Map<String, dynamic>?) ?? {},
      ),
      logo: LogoConfig.fromJson(
        (quiz['logo'] as Map<String, dynamic>?) ?? {},
      ),
      questionCard: QuestionCardConfig.fromJson(
        (quiz['questionCard'] as Map<String, dynamic>?) ?? {},
      ),
      progressCircle: ProgressCircleConfig.fromJson(
        (quiz['progressCircle'] as Map<String, dynamic>?) ?? {},
      ),
      questionText: QuestionTextConfig.fromJson(
        (quiz['questionText'] as Map<String, dynamic>?) ?? {},
      ),
      questions: ((quiz['questions'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map((q) => QuestionData.fromJson(q))
          .toList(),
      answerButtons: AnswerButtonsConfig.fromJson(
        (quiz['answerButtons'] as Map<String, dynamic>?) ?? {},
      ),
      navigationButtons: NavigationButtonsConfig.fromJson(
        (quiz['navigationButtons'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  @override
  List<Object?> get props => [
    id, version, quizId, totalQuestions, backgroundColor,
    topHeaderConfig, backButton, logo, questionCard, progressCircle,
    questionText, questions, answerButtons, navigationButtons
  ];
}

/// Question data model
class QuestionData extends Equatable {
  final int number;
  final String textKey;
  final Map<String, String> translations;
  final List<AnswerOption> options;
  final String correctOption;
  final Map<String, String> explanation;

  const QuestionData({
    required this.number,
    required this.textKey,
    required this.translations,
    required this.options,
    required this.correctOption,
    required this.explanation,
  });

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      number: json['number'] as int? ?? 0,
      textKey: json['textKey'] as String? ?? '',
      translations: Map<String, String>.from(
        (json['translations'] as Map<String, dynamic>?) ?? {},
      ),
      options: ((json['options'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map((o) => AnswerOption.fromJson(o))
          .toList(),
      correctOption: json['correctOption'] as String? ?? '',
      explanation: Map<String, String>.from(
        (json['explanation'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  @override
  List<Object?> get props =>
      [number, textKey, translations, options, correctOption, explanation];
}

/// Answer option model
class AnswerOption extends Equatable {
  final String label;
  final Map<String, String> translations;

  const AnswerOption({
    required this.label,
    required this.translations,
  });

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      label: json['label'] as String? ?? '',
      translations: Map<String, String>.from(
        (json['translations'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  @override
  List<Object?> get props => [label, translations];
}

/// Top header configuration
class TopHeaderConfig extends Equatable {
  final String clipperType;
  final double height;
  final String backgroundColor;
  final List<BubbleConfig> bubbles;

  const TopHeaderConfig({
    required this.clipperType,
    required this.height,
    required this.backgroundColor,
    required this.bubbles,
  });

  factory TopHeaderConfig.fromJson(Map<String, dynamic> json) {
    return TopHeaderConfig(
      clipperType: json['clipperType'] as String? ?? 'curved_bottom',
      height: (json['height'] as num?)?.toDouble() ?? 230,
      backgroundColor: json['backgroundColor'] as String? ?? '#FFA6BD',
      bubbles: ((json['bubbles'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map((b) => BubbleConfig.fromJson(b))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [clipperType, height, backgroundColor, bubbles];
}

/// Bubble configuration
class BubbleConfig extends Equatable {
  final double x;
  final double y;
  final double radius;
  final double opacity;

  const BubbleConfig({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
  });

  factory BubbleConfig.fromJson(Map<String, dynamic> json) {
    return BubbleConfig(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      radius: (json['radius'] as num?)?.toDouble() ?? 40,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 0.12,
    );
  }

  @override
  List<Object?> get props => [x, y, radius, opacity];
}

/// Back button configuration
class BackButtonConfig extends Equatable {
  final double top;
  final double left;
  final double size;
  final String backgroundColor;
  final String iconColor;
  final double iconSize;
  final String shape;

  const BackButtonConfig({
    required this.top,
    required this.left,
    required this.size,
    required this.backgroundColor,
    required this.iconColor,
    required this.iconSize,
    required this.shape,
  });

  factory BackButtonConfig.fromJson(Map<String, dynamic> json) {
    return BackButtonConfig(
      top: (json['top'] as num?)?.toDouble() ?? 48,
      left: (json['left'] as num?)?.toDouble() ?? 20,
      size: (json['size'] as num?)?.toDouble() ?? 36,
      backgroundColor: json['backgroundColor'] as String? ?? '#59FFFFFF',
      iconColor: json['iconColor'] as String? ?? '#FFFFFF',
      iconSize: (json['iconSize'] as num?)?.toDouble() ?? 18,
      shape: json['shape'] as String? ?? 'circle',
    );
  }

  @override
  List<Object?> get props =>
      [top, left, size, backgroundColor, iconColor, iconSize, shape];
}

/// Logo configuration
class LogoConfig extends Equatable {
  final String asset;
  final double height;
  final double width;
  final double top;
  final double right;

  const LogoConfig({
    required this.asset,
    required this.height,
    required this.width,
    required this.top,
    required this.right,
  });

  factory LogoConfig.fromJson(Map<String, dynamic> json) {
    return LogoConfig(
      asset: json['asset'] as String? ?? '',
      height: (json['height'] as num?)?.toDouble() ?? 44,
      width: (json['width'] as num?)?.toDouble() ?? 44,
      top: (json['top'] as num?)?.toDouble() ?? 50,
      right: (json['right'] as num?)?.toDouble() ?? 22,
    );
  }

  @override
  List<Object?> get props => [asset, height, width, top, right];
}

/// Question card configuration
class QuestionCardConfig extends Equatable {
  final String backgroundColor;
  final double borderRadius;
  final double topMargin;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final String shadowColor;
  final double shadowBlurRadius;

  const QuestionCardConfig({
    required this.backgroundColor,
    required this.borderRadius,
    required this.topMargin,
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.shadowColor,
    required this.shadowBlurRadius,
  });

  factory QuestionCardConfig.fromJson(Map<String, dynamic> json) {
    return QuestionCardConfig(
      backgroundColor: json['backgroundColor'] as String? ?? '#FFFFFF',
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 28,
      topMargin: (json['topMargin'] as num?)?.toDouble() ?? 44,
      horizontalPadding: (json['horizontalPadding'] as num?)?.toDouble() ?? 28,
      topPadding: (json['topPadding'] as num?)?.toDouble() ?? 52,
      bottomPadding: (json['bottomPadding'] as num?)?.toDouble() ?? 32,
      shadowColor: json['shadowColor'] as String? ?? '#40FFA6BD',
      shadowBlurRadius: (json['shadowBlurRadius'] as num?)?.toDouble() ?? 20,
    );
  }

  @override
  List<Object?> get props => [
    backgroundColor,
    borderRadius,
    topMargin,
    horizontalPadding,
    topPadding,
    bottomPadding,
    shadowColor,
    shadowBlurRadius,
  ];
}

/// Progress circle configuration
class ProgressCircleConfig extends Equatable {
  final double size;
  final String trackColor;
  final String arcColor;
  final double strokeWidth;
  final double labelFontSize;
  final String labelFontWeight;
  final String labelColor;
  final String position;

  const ProgressCircleConfig({
    required this.size,
    required this.trackColor,
    required this.arcColor,
    required this.strokeWidth,
    required this.labelFontSize,
    required this.labelFontWeight,
    required this.labelColor,
    required this.position,
  });

  factory ProgressCircleConfig.fromJson(Map<String, dynamic> json) {
    return ProgressCircleConfig(
      size: (json['size'] as num?)?.toDouble() ?? 80,
      trackColor: json['trackColor'] as String? ?? '#FFD6E5',
      arcColor: json['arcColor'] as String? ?? '#E86A8D',
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 4.5,
      labelFontSize: (json['labelFontSize'] as num?)?.toDouble() ?? 26,
      labelFontWeight: json['labelFontWeight'] as String? ?? 'bold',
      labelColor: json['labelColor'] as String? ?? '#E86A8D',
      position: json['position'] as String? ?? 'floating_top',
    );
  }

  @override
  List<Object?> get props => [
    size,
    trackColor,
    arcColor,
    strokeWidth,
    labelFontSize,
    labelFontWeight,
    labelColor,
    position,
  ];
}

/// Question text configuration
class QuestionTextConfig extends Equatable {
  final String numberPrefix;
  final String numberSuffix;
  final String numberColor;
  final double numberFontSize;
  final String numberFontWeight;
  final double questionFontSize;
  final String questionColor;
  final String questionFontWeight;
  final String textAlign;
  final double spacing;

  const QuestionTextConfig({
    required this.numberPrefix,
    required this.numberSuffix,
    required this.numberColor,
    required this.numberFontSize,
    required this.numberFontWeight,
    required this.questionFontSize,
    required this.questionColor,
    required this.questionFontWeight,
    required this.textAlign,
    required this.spacing,
  });

  factory QuestionTextConfig.fromJson(Map<String, dynamic> json) {
    return QuestionTextConfig(
      numberPrefix: json['numberPrefix'] as String? ?? 'Question ',
      numberSuffix: json['numberSuffix'] as String? ?? '/5',
      numberColor: json['numberColor'] as String? ?? '#E86A8D',
      numberFontSize: (json['numberFontSize'] as num?)?.toDouble() ?? 14,
      numberFontWeight: json['numberFontWeight'] as String? ?? 'w600',
      questionFontSize: (json['questionFontSize'] as num?)?.toDouble() ?? 17,
      questionColor: json['questionColor'] as String? ?? '#5D3A3A',
      questionFontWeight: json['questionFontWeight'] as String? ?? 'w600',
      textAlign: json['textAlign'] as String? ?? 'center',
      spacing: (json['spacing'] as num?)?.toDouble() ?? 20,
    );
  }

  @override
  List<Object?> get props => [
    numberPrefix,
    numberSuffix,
    numberColor,
    numberFontSize,
    numberFontWeight,
    questionFontSize,
    questionColor,
    questionFontWeight,
    textAlign,
    spacing,
  ];
}

/// Answer buttons configuration
class AnswerButtonsConfig extends Equatable {
  final double spacing;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;
  final String selectedBackgroundColor;
  final String unselectedBackgroundColor;
  final String selectedBorderColor;
  final String unselectedBorderColor;
  final double borderWidth;
  final String shadowColor;
  final double shadowBlurRadius;
  final Map<String, double> shadowOffset;
  final double labelCircleSize;
  final String selectedLabelBackground;
  final String unselectedLabelBackground;
  final String selectedLabelColor;
  final String unselectedLabelColor;
  final double labelFontSize;
  final String labelFontWeight;
  final double textFontSize;
  final String textFontWeight;
  final String selectedTextColor;
  final String unselectedTextColor;
  final List<AnswerButtonOption> options;

  const AnswerButtonsConfig({
    required this.spacing,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.borderRadius,
    required this.selectedBackgroundColor,
    required this.unselectedBackgroundColor,
    required this.selectedBorderColor,
    required this.unselectedBorderColor,
    required this.borderWidth,
    required this.shadowColor,
    required this.shadowBlurRadius,
    required this.shadowOffset,
    required this.labelCircleSize,
    required this.selectedLabelBackground,
    required this.unselectedLabelBackground,
    required this.selectedLabelColor,
    required this.unselectedLabelColor,
    required this.labelFontSize,
    required this.labelFontWeight,
    required this.textFontSize,
    required this.textFontWeight,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.options,
  });

  factory AnswerButtonsConfig.fromJson(Map<String, dynamic> json) {
    return AnswerButtonsConfig(
      spacing: (json['spacing'] as num?)?.toDouble() ?? 12,
      horizontalPadding: (json['horizontalPadding'] as num?)?.toDouble() ?? 16,
      verticalPadding: (json['verticalPadding'] as num?)?.toDouble() ?? 14,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 18,
      selectedBackgroundColor: json['selectedBackgroundColor'] as String? ??
          '#FCE4EC',
      unselectedBackgroundColor: json['unselectedBackgroundColor'] as String? ??
          '#FFFFFF',
      selectedBorderColor: json['selectedBorderColor'] as String? ?? '#E86A8D',
      unselectedBorderColor: json['unselectedBorderColor'] as String? ??
          '#EECDD7',
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1.5,
      shadowColor: json['shadowColor'] as String? ?? '#0FE86A8D',
      shadowBlurRadius: (json['shadowBlurRadius'] as num?)?.toDouble() ?? 10,
      shadowOffset: Map<String, double>.from(
        ((json['shadowOffset'] as Map<String, dynamic>?) ?? {})
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      ),
      labelCircleSize: (json['labelCircleSize'] as num?)?.toDouble() ?? 32,
      selectedLabelBackground: json['selectedLabelBackground'] as String? ??
          '#E86A8D',
      unselectedLabelBackground: json['unselectedLabelBackground'] as String? ??
          '#FCEEF3',
      selectedLabelColor: json['selectedLabelColor'] as String? ?? '#FFFFFF',
      unselectedLabelColor: json['unselectedLabelColor'] as String? ??
          '#E86A8D',
      labelFontSize: (json['labelFontSize'] as num?)?.toDouble() ?? 13,
      labelFontWeight: json['labelFontWeight'] as String? ?? 'bold',
      textFontSize: (json['textFontSize'] as num?)?.toDouble() ?? 16,
      textFontWeight: json['textFontWeight'] as String? ?? 'w500',
      selectedTextColor: json['selectedTextColor'] as String? ?? '#E86A8D',
      unselectedTextColor: json['unselectedTextColor'] as String? ?? '#5D3A3A',
      options: ((json['options'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map((o) => AnswerButtonOption.fromJson(o))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    spacing,
    horizontalPadding,
    verticalPadding,
    borderRadius,
    selectedBackgroundColor,
    unselectedBackgroundColor,
    selectedBorderColor,
    unselectedBorderColor,
    borderWidth,
    shadowColor,
    shadowBlurRadius,
    shadowOffset,
    labelCircleSize,
    selectedLabelBackground,
    unselectedLabelBackground,
    selectedLabelColor,
    unselectedLabelColor,
    labelFontSize,
    labelFontWeight,
    textFontSize,
    textFontWeight,
    selectedTextColor,
    unselectedTextColor,
    options,
  ];
}

/// Answer button option
class AnswerButtonOption extends Equatable {
  final String label;
  final String text;

  const AnswerButtonOption({
    required this.label,
    required this.text,
  });

  factory AnswerButtonOption.fromJson(Map<String, dynamic> json) {
    return AnswerButtonOption(
      label: json['label'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [label, text];
}

/// Navigation buttons configuration
class NavigationButtonsConfig extends Equatable {
  final String backgroundColor;
  final String foregroundColor;
  final Map<String, double> minimumSize;
  final String backIcon;
  final String nextIcon;
  final double iconSize;

  const NavigationButtonsConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.minimumSize,
    required this.backIcon,
    required this.nextIcon,
    required this.iconSize,
  });

  factory NavigationButtonsConfig.fromJson(Map<String, dynamic> json) {
    return NavigationButtonsConfig(
      backgroundColor: json['backgroundColor'] as String? ?? '#E86A8D',
      foregroundColor: json['foregroundColor'] as String? ?? '#FFFFFF',
      minimumSize: Map<String, double>.from(
        ((json['minimumSize'] as Map<String, dynamic>?) ?? {})
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      ),
      backIcon: json['backIcon'] as String? ?? 'arrow_back',
      nextIcon: json['nextIcon'] as String? ?? 'arrow_forward',
      iconSize: (json['iconSize'] as num?)?.toDouble() ?? 20,
    );
  }

  @override
  List<Object?> get props => [
    backgroundColor,
    foregroundColor,
    minimumSize,
    backIcon,
    nextIcon,
    iconSize,
  ];
}

/// Quiz completion configuration
class QuizCompletionConfig extends Equatable {
  final String id;
  final String version;
  final String backgroundColor;
  final TopHeaderConfig topHeaderConfig;
  final BackButtonConfig backButton;
  final CompletionCircleConfig completionCircle;
  final StatsCardConfig statsCard;
  final StatRowConfig statRow;
  final Map<String, String> messages;
  final double messageFontSize;
  final String messageFontWeight;
  final String messageColor;
  final double messageLineHeight;
  final String messageTextAlign;
  final GiftIconConfig giftIcon;
  final RetakeButtonConfig retakeButton;
  final DashboardButtonConfig dashboardButton;

  const QuizCompletionConfig({
    required this.id,
    required this.version,
    required this.backgroundColor,
    required this.topHeaderConfig,
    required this.backButton,
    required this.completionCircle,
    required this.statsCard,
    required this.statRow,
    required this.messages,
    required this.messageFontSize,
    required this.messageFontWeight,
    required this.messageColor,
    required this.messageLineHeight,
    required this.messageTextAlign,
    required this.giftIcon,
    required this.retakeButton,
    required this.dashboardButton,
  });

  factory QuizCompletionConfig.fromJson(Map<String, dynamic> json) {
    final completion =
        (json['quiz_completion'] as Map<String, dynamic>?) ?? json;

    return QuizCompletionConfig(
      id: completion['id'] as String? ?? '',
      version: completion['version'] as String? ?? '1.0.0',
      backgroundColor: completion['backgroundColor'] as String? ?? '#FCEEF3',
      topHeaderConfig: TopHeaderConfig.fromJson(
        (completion['topHeaderConfig'] as Map<String, dynamic>?) ?? {},
      ),
      backButton: BackButtonConfig.fromJson(
        (completion['backButton'] as Map<String, dynamic>?) ?? {},
      ),
      completionCircle: CompletionCircleConfig.fromJson(
        (completion['completionCircle'] as Map<String, dynamic>?) ?? {},
      ),
      statsCard: StatsCardConfig.fromJson(
        (completion['statsCard'] as Map<String, dynamic>?) ?? {},
      ),
      statRow: StatRowConfig.fromJson(
        (completion['statRow'] as Map<String, dynamic>?) ?? {},
      ),
      messages: Map<String, String>.from(
        (completion['messages'] as Map<String, dynamic>?)
                ?.cast<String, dynamic>()
                .map((k, v) =>
                    MapEntry(k, v is Map ? (v['English'] ?? '') : v.toString()))
                .cast<String, String>() ??
            {},
      ),
      messageFontSize: (completion['messageFontSize'] as num?)?.toDouble() ?? 26,
      messageFontWeight: completion['messageFontWeight'] as String? ?? 'w800',
      messageColor: completion['messageColor'] as String? ?? '#5D3A3A',
      messageLineHeight: (completion['messageLineHeight'] as num?)?.toDouble() ?? 1.35,
      messageTextAlign: completion['messageTextAlign'] as String? ?? 'center',
      giftIcon: GiftIconConfig.fromJson(
        (completion['giftIcon'] as Map<String, dynamic>?) ?? {},
      ),
      retakeButton: RetakeButtonConfig.fromJson(
        (completion['retakeButton'] as Map<String, dynamic>?) ?? {},
      ),
      dashboardButton: DashboardButtonConfig.fromJson(
        (completion['dashboardButton'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  @override
  List<Object?> get props => [
    id,
    version,
    backgroundColor,
    topHeaderConfig,
    backButton,
    completionCircle,
    statsCard,
    statRow,
    messages,
    messageFontSize,
    messageFontWeight,
    messageColor,
    messageLineHeight,
    messageTextAlign,
    giftIcon,
    retakeButton,
    dashboardButton,
  ];
}

/// Completion circle configuration
class CompletionCircleConfig extends Equatable {
  final double size;
  final String backgroundColor;
  final String shadowColor;
  final double shadowBlurRadius;
  final Map<String, double> shadowOffset;
  final String labelText;
  final double labelFontSize;
  final String labelFontWeight;
  final String labelColor;
  final double percentageFontSize;
  final String percentageFontWeight;
  final String percentageColor;
  final double symbolFontSize;
  final String symbolFontWeight;
  final String symbolColor;

  const CompletionCircleConfig({
    required this.size,
    required this.backgroundColor,
    required this.shadowColor,
    required this.shadowBlurRadius,
    required this.shadowOffset,
    required this.labelText,
    required this.labelFontSize,
    required this.labelFontWeight,
    required this.labelColor,
    required this.percentageFontSize,
    required this.percentageFontWeight,
    required this.percentageColor,
    required this.symbolFontSize,
    required this.symbolFontWeight,
    required this.symbolColor,
  });

  factory CompletionCircleConfig.fromJson(Map<String, dynamic> json) {
    return CompletionCircleConfig(
      size: (json['size'] as num?)?.toDouble() ?? 104,
      backgroundColor: json['backgroundColor'] as String? ?? '#FFFFFF',
      shadowColor: json['shadowColor'] as String? ?? '#59FFA6BD',
      shadowBlurRadius: (json['shadowBlurRadius'] as num?)?.toDouble() ?? 16,
      shadowOffset: Map<String, double>.from(
        ((json['shadowOffset'] as Map<String, dynamic>?) ?? {})
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      ),
      labelText: json['labelText'] as String? ?? 'Completion',
      labelFontSize: (json['labelFontSize'] as num?)?.toDouble() ?? 11,
      labelFontWeight: json['labelFontWeight'] as String? ?? 'w500',
      labelColor: json['labelColor'] as String? ?? '#B07A8A',
      percentageFontSize: (json['percentageFontSize'] as num?)?.toDouble() ?? 28,
      percentageFontWeight: json['percentageFontWeight'] as String? ?? 'w800',
      percentageColor: json['percentageColor'] as String? ?? '#5D3A3A',
      symbolFontSize: (json['symbolFontSize'] as num?)?.toDouble() ?? 14,
      symbolFontWeight: json['symbolFontWeight'] as String? ?? 'w700',
      symbolColor: json['symbolColor'] as String? ?? '#5D3A3A',
    );
  }

  @override
  List<Object?> get props => [
    size,
    backgroundColor,
    shadowColor,
    shadowBlurRadius,
    shadowOffset,
    labelText,
    labelFontSize,
    labelFontWeight,
    labelColor,
    percentageFontSize,
    percentageFontWeight,
    percentageColor,
    symbolFontSize,
    symbolFontWeight,
    symbolColor,
  ];
}

/// Stats card configuration
class StatsCardConfig extends Equatable {
  final String backgroundColor;
  final double borderRadius;
  final double topMargin;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final String shadowColor;
  final double shadowBlurRadius;
  final Map<String, double> shadowOffset;
  final String dividerColor;
  final double dividerThickness;

  const StatsCardConfig({
    required this.backgroundColor,
    required this.borderRadius,
    required this.topMargin,
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.shadowColor,
    required this.shadowBlurRadius,
    required this.shadowOffset,
    required this.dividerColor,
    required this.dividerThickness,
  });

  factory StatsCardConfig.fromJson(Map<String, dynamic> json) {
    return StatsCardConfig(
      backgroundColor: json['backgroundColor'] as String? ?? '#FFFFFF',
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 28,
      topMargin: (json['topMargin'] as num?)?.toDouble() ?? 56,
      horizontalPadding: (json['horizontalPadding'] as num?)?.toDouble() ?? 28,
      topPadding: (json['topPadding'] as num?)?.toDouble() ?? 64,
      bottomPadding: (json['bottomPadding'] as num?)?.toDouble() ?? 28,
      shadowColor: json['shadowColor'] as String? ?? '#40FFA6BD',
      shadowBlurRadius: (json['shadowBlurRadius'] as num?)?.toDouble() ?? 20,
      shadowOffset: Map<String, double>.from(
        ((json['shadowOffset'] as Map<String, dynamic>?) ?? {})
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      ),
      dividerColor: json['dividerColor'] as String? ?? '#F5DCE5',
      dividerThickness: (json['dividerThickness'] as num?)?.toDouble() ?? 1,
    );
  }

  @override
  List<Object?> get props => [
    backgroundColor,
    borderRadius,
    topMargin,
    horizontalPadding,
    topPadding,
    bottomPadding,
    shadowColor,
    shadowBlurRadius,
    shadowOffset,
    dividerColor,
    dividerThickness,
  ];
}

/// Stat row configuration
class StatRowConfig extends Equatable {
  final double bulletSize;
  final String bulletColor;
  final double bulletSpacing;
  final double valueFontSize;
  final String valueFontWeight;
  final String valueColor;
  final double labelFontSize;
  final String labelFontWeight;
  final String labelColor;

  const StatRowConfig({
    required this.bulletSize,
    required this.bulletColor,
    required this.bulletSpacing,
    required this.valueFontSize,
    required this.valueFontWeight,
    required this.valueColor,
    required this.labelFontSize,
    required this.labelFontWeight,
    required this.labelColor,
  });

  factory StatRowConfig.fromJson(Map<String, dynamic> json) {
    return StatRowConfig(
      bulletSize: (json['bulletSize'] as num?)?.toDouble() ?? 10,
      bulletColor: json['bulletColor'] as String? ?? '#E86A8D',
      bulletSpacing: (json['bulletSpacing'] as num?)?.toDouble() ?? 12,
      valueFontSize: (json['valueFontSize'] as num?)?.toDouble() ?? 18,
      valueFontWeight: json['valueFontWeight'] as String? ?? 'w800',
      valueColor: json['valueColor'] as String? ?? '#5D3A3A',
      labelFontSize: (json['labelFontSize'] as num?)?.toDouble() ?? 12,
      labelFontWeight: json['labelFontWeight'] as String? ?? 'w500',
      labelColor: json['labelColor'] as String? ?? '#B07A8A',
    );
  }

  @override
  List<Object?> get props => [
    bulletSize,
    bulletColor,
    bulletSpacing,
    valueFontSize,
    valueFontWeight,
    valueColor,
    labelFontSize,
    labelFontWeight,
    labelColor,
  ];
}

/// Gift icon configuration
class GiftIconConfig extends Equatable {
  final double size;
  final String pinkColor;
  final String ribbonColor;

  const GiftIconConfig({
    required this.size,
    required this.pinkColor,
    required this.ribbonColor,
  });

  factory GiftIconConfig.fromJson(Map<String, dynamic> json) {
    return GiftIconConfig(
      size: (json['size'] as num?)?.toDouble() ?? 110,
      pinkColor: json['pinkColor'] as String? ?? '#F0A8C7',
      ribbonColor: json['ribbonColor'] as String? ?? '#8B5E3C',
    );
  }

  @override
  List<Object?> get props => [size, pinkColor, ribbonColor];
}

/// Retake button configuration
class RetakeButtonConfig extends Equatable {
  final String backgroundColor;
  final double borderRadius;
  final double verticalPadding;
  final double elevation;
  final String shadowColor;
  final String iconColor;
  final double iconSize;
  final double iconSpacing;
  final String textColor;
  final double fontSize;
  final String fontWeight;
  final Map<String, String> text;

  const RetakeButtonConfig({
    required this.backgroundColor,
    required this.borderRadius,
    required this.verticalPadding,
    required this.elevation,
    required this.shadowColor,
    required this.iconColor,
    required this.iconSize,
    required this.iconSpacing,
    required this.textColor,
    required this.fontSize,
    required this.fontWeight,
    required this.text,
  });

  factory RetakeButtonConfig.fromJson(Map<String, dynamic> json) {
    return RetakeButtonConfig(
      backgroundColor: json['backgroundColor'] as String? ?? '#E86A8D',
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 18,
      verticalPadding: (json['verticalPadding'] as num?)?.toDouble() ?? 15,
      elevation: (json['elevation'] as num?)?.toDouble() ?? 4,
      shadowColor: json['shadowColor'] as String? ?? '#66E86A8D',
      iconColor: json['iconColor'] as String? ?? '#FFFFFF',
      iconSize: (json['iconSize'] as num?)?.toDouble() ?? 20,
      iconSpacing: (json['iconSpacing'] as num?)?.toDouble() ?? 8,
      textColor: json['textColor'] as String? ?? '#FFFFFF',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16,
      fontWeight: json['fontWeight'] as String? ?? 'w600',
      text: Map<String, String>.from(
        (json['text'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  @override
  List<Object?> get props => [
    backgroundColor,
    borderRadius,
    verticalPadding,
    elevation,
    shadowColor,
    iconColor,
    iconSize,
    iconSpacing,
    textColor,
    fontSize,
    fontWeight,
    text,
  ];
}

/// Dashboard button configuration
class DashboardButtonConfig extends Equatable {
  final String borderColor;
  final double borderWidth;
  final double borderRadius;
  final double verticalPadding;
  final String iconColor;
  final double iconSize;
  final double iconSpacing;
  final String textColor;
  final double fontSize;
  final String fontWeight;
  final Map<String, String> text;

  const DashboardButtonConfig({
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.verticalPadding,
    required this.iconColor,
    required this.iconSize,
    required this.iconSpacing,
    required this.textColor,
    required this.fontSize,
    required this.fontWeight,
    required this.text,
  });

  factory DashboardButtonConfig.fromJson(Map<String, dynamic> json) {
    return DashboardButtonConfig(
      borderColor: json['borderColor'] as String? ?? '#E86A8D',
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 2,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 18,
      verticalPadding: (json['verticalPadding'] as num?)?.toDouble() ?? 15,
      iconColor: json['iconColor'] as String? ?? '#E86A8D',
      iconSize: (json['iconSize'] as num?)?.toDouble() ?? 20,
      iconSpacing: (json['iconSpacing'] as num?)?.toDouble() ?? 8,
      textColor: json['textColor'] as String? ?? '#E86A8D',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16,
      fontWeight: json['fontWeight'] as String? ?? 'w600',
      text: Map<String, String>.from(
        (json['text'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  @override
  List<Object?> get props => [
    borderColor,
    borderWidth,
    borderRadius,
    verticalPadding,
    iconColor,
    iconSize,
    iconSpacing,
    textColor,
    fontSize,
    fontWeight,
    text,
  ];
}
