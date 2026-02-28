import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Pill-style chip for single choice (e.g. round presets, breath duration). Optional subtitle.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    this.subtitle,
    required this.selected,
    required this.onTap,
    this.minWidth,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typography = theme.extension<AppTypographyExtension>();

    final bgColor = selected
        ? (isDark
            ? AppColors.darkSelectedChipBg
            : AppColors.lightSelectedChipBg)
        : (isDark
            ? AppColors.darkUnselectedChipBg
            : AppColors.lightUnselectedChipBg);

    final borderColor = selected
        ? (isDark
            ? AppColors.darkSelectedChipBorder
            : AppColors.lightSelectedChipBorder)
        : Colors.transparent;

    final textColor = selected
        ? (isDark
            ? AppColors.darkSelectedChipText
            : AppColors.lightSelectedChipText)
        : (isDark
            ? AppColors.darkUnselectedChipText
            : AppColors.lightUnselectedChipText);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          constraints:
              minWidth != null ? BoxConstraints(minWidth: minWidth!) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: (typography?.chipText ?? theme.textTheme.bodyMedium)
                    ?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

