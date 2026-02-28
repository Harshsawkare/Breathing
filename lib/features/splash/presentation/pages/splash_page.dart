import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const routeName = AppStrings.routeSplash;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Brief delay then navigate to settings (home).
    _timer = Timer(const Duration(milliseconds: 2200), _goToSettings);
  }

  void _goToSettings() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppStrings.routeSettings);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              isDark ? AppAssets.backgroundDark : AppAssets.backgroundLight,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          // App icon and title centered on gradient background.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.asset(
                  AppAssets.appIcon,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.splashTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkHeading
                      : AppColors.lightHeading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
