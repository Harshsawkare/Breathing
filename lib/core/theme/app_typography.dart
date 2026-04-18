import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Responsive font sizes: mobile first, web uses larger sizes.
/// Used when building [ThemeData] (e.g. with [kIsWeb] or screen width).
class AppTypography {
  AppTypography._();

  // Heading: mobile 24, web 32 — Quicksand
  static double headingSize(bool isWeb) => isWeb ? 32.0 : 24.0;

  // Subheading: 14 / 16 — Quicksand
  static double subheadingSize(bool isWeb) => isWeb ? 16.0 : 14.0;

  // Title: 15 / 16 — Quicksand
  static double titleSize(bool isWeb) => isWeb ? 16.0 : 15.0;

  // Subtitle: 12 / 16 — Quicksand
  static double subtitleSize(bool isWeb) => isWeb ? 16.0 : 12.0;

  // Chip text: 14 / 14 — Quicksand
  static double chipTextSize(bool isWeb) => 14.0;

  // Button text: 16 / 16 — Quicksand
  static double buttonTextSize(bool isWeb) => 16.0;

  // Breathing counter: 36 / 36 — Quicksand (prominent)
  static double breathingCounterSize(bool isWeb) => 36.0;

  static const String fontFamilyHeading = 'Quicksand';
  static const String fontFamilyBody = 'Quicksand';
}

/// Theme extension that provides app text styles with correct font families
/// and responsive sizes. Requires [isWeb] to be set when building the theme.
class AppTypographyExtension extends ThemeExtension<AppTypographyExtension> {
  const AppTypographyExtension({
    required this.isWeb,
    required this.isDark,
  });

  final bool isWeb;
  final bool isDark;

  double get _heading => AppTypography.headingSize(isWeb);
  double get _subheading => AppTypography.subheadingSize(isWeb);
  double get _title => AppTypography.titleSize(isWeb);
  double get _subtitle => AppTypography.subtitleSize(isWeb);
  double get _chipText => AppTypography.chipTextSize(isWeb);
  double get _buttonText => AppTypography.buttonTextSize(isWeb);
  double get _breathingCounter => AppTypography.breathingCounterSize(isWeb);

  Color get _headingColor => isDark ? AppColors.darkHeading : AppColors.lightHeading;
  Color get _subheadingColor =>
      isDark ? AppColors.darkSubheading : AppColors.lightSubheading;
  Color get _titleColor => isDark ? AppColors.darkTitle : AppColors.lightTitle;
  Color get _subtitleColor =>
      isDark ? AppColors.darkSubtitle : AppColors.lightSubtitle;
  Color get _buttonTextColor =>
      isDark ? AppColors.darkButtonText : AppColors.lightButtonText;

  TextStyle get heading => TextStyle(
        fontFamily: AppTypography.fontFamilyHeading,
        fontSize: _heading,
        fontWeight: FontWeight.w700,
        color: _headingColor,
      );

  TextStyle get subheading => TextStyle(
        fontFamily: AppTypography.fontFamilyHeading,
        fontSize: _subheading,
        fontWeight: FontWeight.w500,
        color: _subheadingColor,
      );

  TextStyle get title => TextStyle(
        fontFamily: AppTypography.fontFamilyBody,
        fontSize: _title,
        fontWeight: FontWeight.w600,
        color: _titleColor,
      );

  TextStyle get subtitle => TextStyle(
        fontFamily: AppTypography.fontFamilyBody,
        fontSize: _subtitle,
        fontWeight: FontWeight.w400,
        color: _subtitleColor,
      );

  TextStyle get chipText => TextStyle(
        fontFamily: AppTypography.fontFamilyBody,
        fontSize: _chipText,
        fontWeight: FontWeight.w500,
      );

  TextStyle get buttonText => TextStyle(
        fontFamily: AppTypography.fontFamilyBody,
        fontSize: _buttonText,
        fontWeight: FontWeight.w600,
        color: _buttonTextColor,
      );

  TextStyle get breathingCounter => TextStyle(
        fontFamily: AppTypography.fontFamilyHeading,
        fontSize: _breathingCounter,
        fontWeight: FontWeight.w700,
      );

  @override
  ThemeExtension<AppTypographyExtension> copyWith({
    bool? isWeb,
    bool? isDark,
  }) {
    return AppTypographyExtension(
      isWeb: isWeb ?? this.isWeb,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  ThemeExtension<AppTypographyExtension> lerp(
    covariant ThemeExtension<AppTypographyExtension>? other,
    double t,
  ) {
    // No animation; just switch at t >= 0.5.
    if (other is! AppTypographyExtension) return this;
    return AppTypographyExtension(
      isWeb: other.isWeb,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}
