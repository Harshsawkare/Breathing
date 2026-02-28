import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Full-width primary action button; uses theme purple and optional wind icon on web.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

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
          backgroundColor: isDark
              ? AppColors.darkButtonBg
              : AppColors.lightButtonBg,
          foregroundColor: AppColors.darkButtonText,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: (typography?.buttonText ?? theme.textTheme.labelLarge)
                  ?.copyWith(color: AppColors.darkButtonText),
            ),
            // Wind icon shown on web only per design.
            if (kIsWeb) ...[
              const SizedBox(width: 8),
              SvgPicture.asset(AppAssets.iconFastWind, width: 24, height: 24),
            ],
          ],
        ),
      ),
    );
  }
}
