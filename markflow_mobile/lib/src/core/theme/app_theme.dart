import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/color_schemes.dart';
import 'package:markflow/src/core/theme/custom_colors.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/core/theme/theme_extensions.dart';

class AppTheme {
  static const _fontFamily = 'GeneralSans';

  static ThemeData _buildTheme({required Brightness brightness}) {
    final ColorScheme colors = brightness == Brightness.light ? lightColorScheme : darkColorScheme;

    return ThemeData(
      useMaterial3: true,
      textTheme: _buildTextTheme(colors: colors),
      appBarTheme: _buildAppBarTheme(colors),
      cardTheme: _buildCardTheme(colors),
      elevatedButtonTheme: _buildElevatedButtonTheme(colors),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colors),
      textButtonTheme: _buildTextButtonTheme(colors),
      inputDecorationTheme: _buildInputDecorationTheme(colors),
      chipTheme: _buildChipTheme(colors),
      dividerTheme: _buildDividerTheme(colors),
      listTileTheme: _buildListTileTheme(colors),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(colors),
      navigationBarTheme: _buildNavigationBarTheme(colors),
      dialogTheme: _buildDialogTheme(colors),
      snackBarTheme: _buildSnackBarTheme(colors),
      colorScheme: colors,
      extensions: [
        brightness == Brightness.light ? CustomColors.light : CustomColors.dark,
        brightness == Brightness.light ? SurfaceColors.light : SurfaceColors.dark,
        brightness == Brightness.light ? SemanticColors.light : SemanticColors.dark,
        AppSpacing.standard,
      ],
    );
  }

  static TextTheme _buildTextTheme({required ColorScheme colors}) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 32,
        color: colors.onSurface,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 28,
        color: colors.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: colors.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: colors.onSurface,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: colors.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: colors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: colors.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: colors.onSurface,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: colors.onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: colors.onSurface,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 10,
        color: colors.onSurface,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme(ColorScheme colors) {
    return AppBarTheme(
      surfaceTintColor: Colors.transparent,
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: colors.onSurface,
      ),
    );
  }

  static CardThemeData _buildCardTheme(ColorScheme colors) {
    // Get the surface colors extension based on the color scheme brightness
    final surfaceColors = colors.brightness == Brightness.light 
        ? SurfaceColors.light 
        : SurfaceColors.dark;
        
    return CardThemeData(
      // Use the lightest surface color for cards
      color: surfaceColors.surfaceContainerLowest,
      shadowColor: colors.shadow.withValues(alpha: 0.1),
      elevation: Dimens.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.cardRadius),
      ),
      margin: const EdgeInsets.all(Dimens.cardMargin),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme colors) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 2,
        shadowColor: colors.shadow.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.buttonRadius),
        ),
        minimumSize: const Size(0, Dimens.buttonHeight),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(ColorScheme colors) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.outline, width: Dimens.borderWidth),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.buttonRadius),
        ),
        minimumSize: const Size(0, Dimens.buttonHeight),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(ColorScheme colors) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.buttonRadius),
        ),
        minimumSize: const Size(0, Dimens.buttonHeight),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(ColorScheme colors) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimens.inputRadius),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimens.inputRadius),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimens.inputRadius),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimens.inputRadius),
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimens.inputRadius),
        borderSide: BorderSide(color: colors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacing,
        vertical: Dimens.spacing,
      ),
      hintStyle: TextStyle(
        fontFamily: _fontFamily,
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w400,
        fontSize: Dimens.fontSizeL,
      ),
      labelStyle: TextStyle(
        fontFamily: _fontFamily,
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w500,
        fontSize: Dimens.fontSizeM,
      ),
      floatingLabelStyle: TextStyle(
        fontFamily: _fontFamily,
        color: colors.primary,
        fontWeight: FontWeight.w500,
        fontSize: Dimens.fontSizeM,
      ),
    );
  }

  static ChipThemeData _buildChipTheme(ColorScheme colors) {
    return ChipThemeData(
      backgroundColor: colors.secondaryContainer,
      labelStyle: TextStyle(
        fontFamily: _fontFamily,
        color: colors.onSecondaryContainer,
        fontWeight: FontWeight.w500,
        fontSize: Dimens.fontSizeM,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.chipRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacing,
        vertical: Dimens.halfSpacing,
      ),
    );
  }

  static DividerThemeData _buildDividerTheme(ColorScheme colors) {
    return DividerThemeData(
      color: colors.outlineVariant,
      thickness: Dimens.dividerThickness,
      space: Dimens.spacing,
    );
  }

  static ListTileThemeData _buildListTileTheme(ColorScheme colors) {
    return ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacing,
        vertical: Dimens.halfSpacing,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius),
      ),
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: colors.onSurface,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: colors.onSurfaceVariant,
      ),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme(ColorScheme colors) {
    return BottomNavigationBarThemeData(
      backgroundColor: colors.surface,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    );
  }

  static NavigationBarThemeData _buildNavigationBarTheme(ColorScheme colors) {
    return NavigationBarThemeData(
      backgroundColor: colors.surface,
      indicatorColor: colors.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: colors.onSurface,
          );
        }
        return TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: colors.onSurfaceVariant,
        );
      }),
    );
  }

  static DialogThemeData _buildDialogTheme(ColorScheme colors) {
    return DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.modalRadius),
      ),
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: colors.onSurface,
      ),
      contentTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: colors.onSurface,
      ),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme(ColorScheme colors) {
    return SnackBarThemeData(
      backgroundColor: colors.inverseSurface,
      contentTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: colors.onInverseSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.snackbarRadius),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  static final ThemeData lightTheme = _buildTheme(brightness: Brightness.light);

  static final ThemeData darkTheme = _buildTheme(brightness: Brightness.dark);
}
