import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:newu_breathing/core/constants/app_assets.dart';
import 'package:newu_breathing/core/constants/app_strings.dart';
import 'package:newu_breathing/core/theme/app_colors.dart';
import 'package:newu_breathing/core/theme/app_typography.dart';
import 'package:newu_breathing/core/theme/theme_cubit.dart';
import 'package:newu_breathing/core/services/preferences_service.dart';
import 'package:newu_breathing/features/breathing_session/session_config.dart';
import 'package:newu_breathing/shared/widgets/background_with_overlays.dart';
import 'package:newu_breathing/shared/widgets/primary_button.dart';

/// Shown when a breathing session completes. Displays success animation,
/// message, and actions to start again or return home.
class SessionCompletionPage extends StatelessWidget {
  const SessionCompletionPage({super.key});

  static const routeName = AppStrings.routeCompletion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Config passed from session screen so "Start again" can reuse it.
    final config = ModalRoute.of(context)?.settings.arguments as SessionConfig?;

    return Scaffold(
      body: BackgroundWithOverlays(
        isDark: isDark,
        child: SafeArea(
          child: _wrapForWeb(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  _CompletionHeader(onToggleTheme: _onToggleTheme(context)),
                  Expanded(
                    child: _CompletionContent(isDark: isDark, config: config),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Toggle theme and persist choice via PreferencesService.
  VoidCallback _onToggleTheme(BuildContext context) {
    return () {
      final willBeDark = Theme.of(context).brightness != Brightness.dark;
      context.read<ThemeCubit>().toggle();
      context.read<PreferencesService>().setDarkModeEnabled(willBeDark);
    };
  }

  /// Constrain width on web for a mobile-like layout.
  Widget _wrapForWeb({required Widget child}) {
    if (!kIsWeb) return child;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: child,
      ),
    );
  }
}

class _CompletionHeader extends StatelessWidget {
  const _CompletionHeader({required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [_ThemeButton(isDark: isDark, onTap: onToggleTheme)],
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton({required this.isDark, required this.onTap});

  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkThemeIconBg
              : AppColors.lightThemeIconBg,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          size: 22,
          color: isDark ? AppColors.darkThemeIcon : AppColors.lightThemeIcon,
        ),
      ),
    );
  }
}

class _CompletionContent extends StatelessWidget {
  const _CompletionContent({required this.isDark, required this.config});

  final bool isDark;
  final SessionConfig? config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = theme.extension<AppTypographyExtension>();
    final titleColor = isDark ? AppColors.darkTitle : AppColors.lightTitle;
    final subtitleColor = isDark
        ? AppColors.darkSubtitle
        : AppColors.lightSubtitle;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success animation (Lottie JSON).
            SizedBox(
              width: 160,
              height: 160,
              child: Lottie.asset(
                AppAssets.completionLottie,
                fit: BoxFit.contain,
                repeat: false,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.check_circle_rounded,
                  size: 120,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.completionYouDidIt,
              style: (typography?.heading ?? theme.textTheme.headlineSmall)
                  ?.copyWith(
                    fontFamily: AppTypography.fontFamilyHeading,
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.completionMessage,
              style: (typography?.subtitle ?? theme.textTheme.bodyMedium)
                  ?.copyWith(
                    fontFamily: AppTypography.fontFamilyBody,
                    color: subtitleColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: AppStrings.completionStartAgain,
              onPressed: config != null ? () => _startAgain(context) : null,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _backToHome(context),
              child: Text(
                AppStrings.completionBackToHome,
                style: (typography?.subtitle ?? theme.textTheme.bodyMedium)
                    ?.copyWith(
                      fontFamily: AppTypography.fontFamilyBody,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkBackToHome
                          : AppColors.lightBackToHome,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Replace this screen with a new session using the same config.
  void _startAgain(BuildContext context) {
    if (config == null) return;
    Navigator.of(
      context,
    ).pushReplacementNamed(AppStrings.routeSession, arguments: config);
  }

  /// Pop back to the settings (home) screen.
  void _backToHome(BuildContext context) {
    Navigator.of(
      context,
    ).popUntil((route) => route.settings.name == AppStrings.routeSettings);
  }
}
