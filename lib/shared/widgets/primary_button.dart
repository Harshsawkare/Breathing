import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typography = theme.extension<AppTypographyExtension>();

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? AppColors.darkButtonBg : AppColors.lightButtonBg,
          foregroundColor:
              isDark ? AppColors.darkButtonText : AppColors.lightButtonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: (typography?.buttonText ?? theme.textTheme.labelLarge)
                  ?.copyWith(
                    color: isDark
                        ? AppColors.darkButtonText
                        : AppColors.lightButtonText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

