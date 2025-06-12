import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';

@immutable
class SurfaceColors extends ThemeExtension<SurfaceColors> {
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceContainerLow;
  final Color surfaceContainerLowest;
  final Color surfaceDim;
  final Color surfaceBright;

  const SurfaceColors({
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceContainerLow,
    required this.surfaceContainerLowest,
    required this.surfaceDim,
    required this.surfaceBright,
  });

  @override
  SurfaceColors copyWith({
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? surfaceContainerLow,
    Color? surfaceContainerLowest,
    Color? surfaceDim,
    Color? surfaceBright,
  }) {
    return SurfaceColors(
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest ?? this.surfaceContainerHighest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainerLowest: surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceBright: surfaceBright ?? this.surfaceBright,
    );
  }

  @override
  SurfaceColors lerp(ThemeExtension<SurfaceColors>? other, double t) {
    if (other is! SurfaceColors) {
      return this;
    }
    return SurfaceColors(
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainerHighest: Color.lerp(surfaceContainerHighest, other.surfaceContainerHighest, t)!,
      surfaceContainerLow: Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainerLowest: Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
    );
  }

  static const light = SurfaceColors(
    surfaceContainer: Color(0xFFF3F4F6),
    surfaceContainerHigh: Color(0xFFE5E7EB),
    surfaceContainerHighest: Color(0xFFD1D5DB),
    surfaceContainerLow: Color(0xFFF9FAFB),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceDim: Color(0xFFE5E7EB),
    surfaceBright: Color(0xFFFFFFFF),
  );

  static const dark = SurfaceColors(
    surfaceContainer: Color(0xFF1E293B),
    surfaceContainerHigh: Color(0xFF334155),
    surfaceContainerHighest: Color(0xFF475569),
    surfaceContainerLow: Color(0xFF0F172A),
    surfaceContainerLowest: Color(0xFF020617),
    surfaceDim: Color(0xFF0F172A),
    surfaceBright: Color(0xFF334155),
  );
}

@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  const SemanticColors({
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
  });

  @override
  SemanticColors copyWith({
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    return SemanticColors(
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) {
      return this;
    }
    return SemanticColors(
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
    );
  }

  static const light = SemanticColors(
    warning: Color(0xFFF59E0B),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFEF3C7),
    onWarningContainer: Color(0xFF92400E),
    info: Color(0xFF3B82F6),
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFFDEEAFF),
    onInfoContainer: Color(0xFF1E40AF),
  );

  static const dark = SemanticColors(
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF92400E),
    warningContainer: Color(0xFFD97706),
    onWarningContainer: Color(0xFFFEF3C7),
    info: Color(0xFF60A5FA),
    onInfo: Color(0xFF1E40AF),
    infoContainer: Color(0xFF1D4ED8),
    onInfoContainer: Color(0xFFDEEAFF),
  );
}

@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  final EdgeInsets screenPadding;
  final EdgeInsets cardPadding;
  final EdgeInsets buttonPadding;
  final EdgeInsets inputPadding;
  final EdgeInsets listItemPadding;
  final EdgeInsets modalPadding;

  const AppSpacing({
    required this.screenPadding,
    required this.cardPadding,
    required this.buttonPadding,
    required this.inputPadding,
    required this.listItemPadding,
    required this.modalPadding,
  });

  @override
  AppSpacing copyWith({
    EdgeInsets? screenPadding,
    EdgeInsets? cardPadding,
    EdgeInsets? buttonPadding,
    EdgeInsets? inputPadding,
    EdgeInsets? listItemPadding,
    EdgeInsets? modalPadding,
  }) {
    return AppSpacing(
      screenPadding: screenPadding ?? this.screenPadding,
      cardPadding: cardPadding ?? this.cardPadding,
      buttonPadding: buttonPadding ?? this.buttonPadding,
      inputPadding: inputPadding ?? this.inputPadding,
      listItemPadding: listItemPadding ?? this.listItemPadding,
      modalPadding: modalPadding ?? this.modalPadding,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) {
      return this;
    }
    return AppSpacing(
      screenPadding: EdgeInsets.lerp(screenPadding, other.screenPadding, t)!,
      cardPadding: EdgeInsets.lerp(cardPadding, other.cardPadding, t)!,
      buttonPadding: EdgeInsets.lerp(buttonPadding, other.buttonPadding, t)!,
      inputPadding: EdgeInsets.lerp(inputPadding, other.inputPadding, t)!,
      listItemPadding: EdgeInsets.lerp(listItemPadding, other.listItemPadding, t)!,
      modalPadding: EdgeInsets.lerp(modalPadding, other.modalPadding, t)!,
    );
  }

  static const standard = AppSpacing(
    screenPadding: EdgeInsets.all(Dimens.spacing),
    cardPadding: EdgeInsets.all(Dimens.cardPadding),
    buttonPadding: EdgeInsets.symmetric(
      horizontal: Dimens.spacingL,
      vertical: Dimens.spacing,
    ),
    inputPadding: EdgeInsets.symmetric(
      horizontal: Dimens.spacing,
      vertical: Dimens.spacing,
    ),
    listItemPadding: EdgeInsets.symmetric(
      horizontal: Dimens.spacing,
      vertical: Dimens.halfSpacing,
    ),
    modalPadding: EdgeInsets.all(Dimens.modalPadding),
  );
}

extension ThemeExtensions on ThemeData {
  SurfaceColors get surfaceColors => extension<SurfaceColors>() ?? SurfaceColors.light;
  SemanticColors get semanticColors => extension<SemanticColors>() ?? SemanticColors.light;
  AppSpacing get appSpacing => extension<AppSpacing>() ?? AppSpacing.standard;
}