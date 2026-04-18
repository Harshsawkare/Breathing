import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static bool get _isWeb => kIsWeb;

  static ThemeData light() {
    return _buildTheme(isDark: false);
  }

  static ThemeData dark() {
    return _buildTheme(isDark: true);
  }

  /// Builds light or dark theme with app typography and colors.
  static ThemeData _buildTheme({required bool isDark}) {
    final base =
        isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);
    final isWeb = _isWeb;

    final headingColor = isDark ? AppColors.darkHeading : AppColors.lightHeading;
    final subheadingColor =
        isDark ? AppColors.darkSubheading : AppColors.lightSubheading;
    final titleColor = isDark ? AppColors.darkTitle : AppColors.lightTitle;
    final subtitleColor =
        isDark ? AppColors.darkSubtitle : AppColors.lightSubtitle;

    final tt = base.textTheme.apply(fontFamily: AppTypography.fontFamilyHeading);
    final textTheme = tt.copyWith(
      // Heading — Quicksand, 24 mobile / 32 web
      headlineMedium: tt.headlineMedium?.copyWith(
        fontSize: AppTypography.headingSize(isWeb),
        fontWeight: FontWeight.w700,
        color: headingColor,
      ),
      // Subheading — Quicksand, 14 mobile / 16 web
      titleMedium: tt.titleMedium?.copyWith(
        fontSize: AppTypography.subheadingSize(isWeb),
        fontWeight: FontWeight.w500,
        color: subheadingColor,
      ),
      // Title — Quicksand, 15 mobile / 16 web
      titleSmall: tt.titleSmall?.copyWith(
        fontSize: AppTypography.titleSize(isWeb),
        fontWeight: FontWeight.w600,
        color: titleColor,
      ),
      // Subtitle — Quicksand, 12 mobile / 16 web
      bodyMedium: tt.bodyMedium?.copyWith(
        fontSize: AppTypography.subtitleSize(isWeb),
        fontWeight: FontWeight.w400,
        color: subtitleColor,
      ),
      bodySmall: tt.bodySmall?.copyWith(
        fontSize: AppTypography.subtitleSize(isWeb),
        fontWeight: FontWeight.w400,
        color: subtitleColor,
      ),
      // Button text — Quicksand, 16/16
      labelLarge: tt.labelLarge?.copyWith(
        fontSize: AppTypography.buttonTextSize(isWeb),
        fontWeight: FontWeight.w600,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor:
          isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      colorScheme: base.colorScheme.copyWith(
        primary: isDark ? AppColors.darkButtonBg : AppColors.lightButtonBg,
        secondary: isDark
            ? AppColors.darkSelectedChipText
            : AppColors.lightSelectedChipText,
        surface: isDark ? AppColors.darkCard : AppColors.lightCard,
        onPrimary: isDark ? AppColors.darkButtonText : AppColors.lightButtonText,
        onSurface: titleColor,
      ),
      textTheme: textTheme,
      primaryTextTheme:
          base.primaryTextTheme.apply(fontFamily: AppTypography.fontFamilyHeading),
      extensions: <ThemeExtension<dynamic>>[
        AppTypographyExtension(isWeb: isWeb, isDark: isDark),
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.lightTitle,
      ),
    );
  }
}
