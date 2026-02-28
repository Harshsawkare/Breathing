import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_strings.dart';
import 'core/services/preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/breathing_settings/presentation/pages/breathing_settings_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final preferencesService = PreferencesService(prefs);
  final initialDarkMode = preferencesService.darkModeEnabled;

  runApp(NewuBreathingApp(
    preferencesService: preferencesService,
    initialDarkMode: initialDarkMode,
  ));
}

class NewuBreathingApp extends StatelessWidget {
  const NewuBreathingApp({
    super.key,
    required this.preferencesService,
    required this.initialDarkMode,
  });

  final PreferencesService preferencesService;
  final bool initialDarkMode;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<PreferencesService>.value(
      value: preferencesService,
      child: BlocProvider(
        create: (_) => ThemeCubit(initialDarkMode),
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
      ),
    );
  }
}
