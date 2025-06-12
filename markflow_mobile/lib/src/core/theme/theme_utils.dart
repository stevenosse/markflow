import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';

class ThemeUtils {
  ThemeUtils._();

  /// Creates a consistent shadow for elevated components
  static List<BoxShadow> createShadow({
    required Color shadowColor,
    double elevation = Dimens.elevationMedium,
    double opacity = 0.1,
  }) {
    return [
      BoxShadow(
        color: shadowColor.withValues(alpha: opacity),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation / 2),
        spreadRadius: 0,
      ),
    ];
  }

  /// Creates a consistent border radius based on component type
  static BorderRadius getBorderRadius({
    required BorderRadiusType type,
    double? customRadius,
  }) {
    switch (type) {
      case BorderRadiusType.none:
        return BorderRadius.zero;
      case BorderRadiusType.small:
        return BorderRadius.circular(Dimens.radiusS);
      case BorderRadiusType.medium:
        return BorderRadius.circular(Dimens.radius);
      case BorderRadiusType.large:
        return BorderRadius.circular(Dimens.radiusL);
      case BorderRadiusType.card:
        return BorderRadius.circular(Dimens.cardRadius);
      case BorderRadiusType.button:
        return BorderRadius.circular(Dimens.buttonRadius);
      case BorderRadiusType.input:
        return BorderRadius.circular(Dimens.inputRadius);
      case BorderRadiusType.chip:
        return BorderRadius.circular(Dimens.chipRadius);
      case BorderRadiusType.full:
        return BorderRadius.circular(Dimens.fullRadius);
      case BorderRadiusType.custom:
        return BorderRadius.circular(customRadius ?? Dimens.radius);
    }
  }

  /// Creates consistent spacing based on the design system
  static EdgeInsets getSpacing({
    required SpacingType type,
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    switch (type) {
      case SpacingType.none:
        return EdgeInsets.zero;
      case SpacingType.min:
        return const EdgeInsets.all(Dimens.minSpacing);
      case SpacingType.half:
        return const EdgeInsets.all(Dimens.halfSpacing);
      case SpacingType.standard:
        return const EdgeInsets.all(Dimens.spacing);
      case SpacingType.large:
        return const EdgeInsets.all(Dimens.spacingL);
      case SpacingType.double:
        return const EdgeInsets.all(Dimens.doubleSpacing);
      case SpacingType.triple:
        return const EdgeInsets.all(Dimens.tripleSpacing);
      case SpacingType.screen:
        return const EdgeInsets.all(Dimens.spacing);
      case SpacingType.card:
        return const EdgeInsets.all(Dimens.cardPadding);
      case SpacingType.modal:
        return const EdgeInsets.all(Dimens.modalPadding);
      case SpacingType.custom:
        if (all != null) {
          return EdgeInsets.all(all);
        }
        return EdgeInsets.symmetric(
          horizontal: horizontal ?? 0,
          vertical: vertical ?? 0,
        );
    }
  }

  /// Creates a consistent text style based on the design system
  static TextStyle getTextStyle({
    required BuildContext context,
    required TextStyleType type,
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    double? height,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    TextStyle baseStyle;
    switch (type) {
      case TextStyleType.displayLarge:
        baseStyle = textTheme.displayLarge!;
        break;
      case TextStyleType.headlineLarge:
        baseStyle = textTheme.headlineLarge!;
        break;
      case TextStyleType.titleLarge:
        baseStyle = textTheme.titleLarge!;
        break;
      case TextStyleType.titleMedium:
        baseStyle = textTheme.titleMedium!;
        break;
      case TextStyleType.titleSmall:
        baseStyle = textTheme.titleSmall!;
        break;
      case TextStyleType.bodyLarge:
        baseStyle = textTheme.bodyLarge!;
        break;
      case TextStyleType.bodyMedium:
        baseStyle = textTheme.bodyMedium!;
        break;
      case TextStyleType.bodySmall:
        baseStyle = textTheme.bodySmall!;
        break;
      case TextStyleType.labelLarge:
        baseStyle = textTheme.labelLarge!;
        break;
      case TextStyleType.labelMedium:
        baseStyle = textTheme.labelMedium!;
        break;
      case TextStyleType.labelSmall:
        baseStyle = textTheme.labelSmall!;
        break;
    }

    return baseStyle.copyWith(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
      height: height,
    );
  }

  /// Creates a consistent decoration for containers
  static BoxDecoration createContainerDecoration({
    required BuildContext context,
    Color? backgroundColor,
    BorderRadiusType borderRadiusType = BorderRadiusType.medium,
    double? customRadius,
    bool hasShadow = false,
    double elevation = Dimens.elevationMedium,
    Color? borderColor,
    double borderWidth = 0,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BoxDecoration(
      color: backgroundColor ?? colorScheme.surface,
      borderRadius: getBorderRadius(
        type: borderRadiusType,
        customRadius: customRadius,
      ),
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      boxShadow: hasShadow
          ? createShadow(
              shadowColor: colorScheme.shadow,
              elevation: elevation,
            )
          : null,
    );
  }

  /// Determines if the current theme is dark
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Gets the appropriate color based on theme brightness
  static Color getAdaptiveColor({
    required BuildContext context,
    required Color lightColor,
    required Color darkColor,
  }) {
    return isDarkMode(context) ? darkColor : lightColor;
  }

  /// Creates a consistent button style
  static ButtonStyle createButtonStyle({
    required BuildContext context,
    required ButtonStyleType type,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    BorderRadiusType borderRadiusType = BorderRadiusType.button,
    EdgeInsets? padding,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (type) {
      case ButtonStyleType.elevated:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? colorScheme.primary,
          foregroundColor: foregroundColor ?? colorScheme.onPrimary,
          elevation: elevation ?? Dimens.elevationMedium,
          shape: RoundedRectangleBorder(
            borderRadius: getBorderRadius(type: borderRadiusType),
          ),
          padding: padding ?? ThemeUtils.getSpacing(type: SpacingType.custom, horizontal: Dimens.spacingL, vertical: Dimens.spacing),
        );
      case ButtonStyleType.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: getBorderRadius(type: borderRadiusType),
          ),
          padding: padding ?? ThemeUtils.getSpacing(type: SpacingType.custom, horizontal: Dimens.spacingL, vertical: Dimens.spacing),
        );
      case ButtonStyleType.text:
        return TextButton.styleFrom(
          foregroundColor: foregroundColor ?? colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: getBorderRadius(type: borderRadiusType),
          ),
          padding: padding ?? ThemeUtils.getSpacing(type: SpacingType.custom, horizontal: Dimens.spacingL, vertical: Dimens.spacing),
        );
    }
  }
}

enum BorderRadiusType {
  none,
  small,
  medium,
  large,
  card,
  button,
  input,
  chip,
  full,
  custom,
}

enum SpacingType {
  none,
  min,
  half,
  standard,
  large,
  double,
  triple,
  screen,
  card,
  modal,
  custom,
}

enum TextStyleType {
  displayLarge,
  headlineLarge,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

enum ButtonStyleType {
  elevated,
  outlined,
  text,
}