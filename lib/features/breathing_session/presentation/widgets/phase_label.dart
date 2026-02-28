import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Two-line label: main instruction (e.g. "Breathe in") and subtitle (e.g. "nice and slow").
class PhaseLabel extends StatelessWidget {
  const PhaseLabel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = isDark ? AppColors.darkTitle : AppColors.lightTitle;
    final subtitleColor = isDark
        ? AppColors.darkSubtitle
        : AppColors.lightSubtitle;
    final typo = theme.extension<AppTypographyExtension>();

    final titleStyle = typo?.title ?? theme.textTheme.titleSmall;
    final subtitleStyle = typo?.subtitle ?? theme.textTheme.bodyMedium;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: (titleStyle ?? theme.textTheme.titleSmall)!.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: titleColor,
            fontFamily: AppTypography.fontFamilyHeading,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: (subtitleStyle ?? theme.textTheme.bodyMedium)!.copyWith(
            color: subtitleColor,
            fontSize: 14,
            fontFamily: AppTypography.fontFamilyHeading,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
