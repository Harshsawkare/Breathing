/// Asset path constants. All asset paths should be referenced here.
class AppAssets {
  AppAssets._();

  static const String appIcon = 'assets/app_icon.png';
  // Backgrounds are theme-specific (dark/light).

  static const String backgroundDark = 'assets/dark/background.png';
  static const String backgroundLight = 'assets/light/background.png';

  /// Chime played when phase changes (and optionally at 3s when phase duration is 6s).
  static const String chimeSound = 'assets/files/chime_sound.mp3';

  /// Lottie animation (JSON) shown on session completion.
  static const String completionLottie = 'assets/files/completion.json';

  static const String iconPauseDark = 'assets/icons/pause_dark.svg';
  static const String iconPauseLight = 'assets/icons/pause_light.svg';
  static const String iconPlayDark = 'assets/icons/play_dark.svg';
  static const String iconPlayLight = 'assets/icons/play_light.svg';
  static const String iconFastWind = 'assets/icons/fast-wind.svg';
}
