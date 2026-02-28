import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/breathing_settings/presentation/pages/breathing_settings_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';

void main() {
  runApp(const NewuBreathingApp());
}

class NewuBreathingApp extends StatelessWidget {
  const NewuBreathingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDark) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppStrings.appTitle,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            initialRoute: AppStrings.routeSplash,
            routes: {
              AppStrings.routeSplash: (_) => const SplashPage(),
              AppStrings.routeSettings: (_) =>
                  const BreathingSettingsPage(),
            },
          );
        },
      ),
    );
  }
}

