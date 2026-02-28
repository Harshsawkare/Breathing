/// Central string constants for UI. All user-facing literals should be referenced here.
class AppStrings {
  AppStrings._();

  // App
  static const String appTitle = 'NewU Breathing';

  // Routes
  static const String routeSplash = '/';
  static const String routeSettings = '/settings';
  static const String routeSession = '/session';

  // Splash
  static const String splashTitle = 'NewU Breathing';

  // Breathing settings
  static const String settingsSetYourPace = 'Set your pace';
  static const String settingsSubtitle =
      'Customise your breathing session.\nYou can always change this later.';
  static const String settingsStartBreathing = 'Start breathing';

  // Sections
  static const String breathDuration = 'Breath duration';
  static const String secondsPerPhase = 'Seconds per phase';
  static const String rounds = 'Rounds';
  static const String roundsSubtitle = 'Full box breathing cycles';
  static const String advancedTiming = 'Advanced timing';
  static const String advancedTimingSubtitle =
      'Set different durations for each phase';
  static const String sound = 'Sound';
  static const String soundSubtitle = 'Gentle chime between phases';

  // Phases (settings)
  static const String phaseBreatheIn = 'Breathe in';
  static const String phaseHoldIn = 'Hold in';
  static const String phaseBreatheOut = 'Breathe out';
  static const String phaseHoldOut = 'Hold out';

  // Session phase labels (friendly in-session text)
  static const String sessionPhaseHoldIn = 'Hold gently';
  static const String sessionPhaseHoldOut = 'Hold softly';

  // Formatting
  static String secondsLabel(int seconds) => '${seconds}s';

  // Round presets (display labels; map from feature layer)
  static const String roundPreset2Quick = '2 quick';
  static const String roundPreset4Calm = '4 calm';
  static const String roundPreset6Deep = '6 deep';
  static const String roundPreset8Zen = '8 zen';

  // Breathing session
  static const String sessionGetReady = 'Get ready';
  static const String sessionGetReadySubtitle =
      'Get going on your breathing session';
  static const String sessionSec = 'sec';
  static const String sessionAffirmation = "You're a natural";
  static const String sessionSubtitleBreatheIn = 'nice and slow';
  static const String sessionSubtitleBreatheOut = 'nice and slow';
  static const String sessionSubtitleHoldIn = 'you are doing great!';
  static const String sessionSubtitleHoldOut = 'just be here';
  static String sessionCycle(int current, int total) =>
      'Cycle $current of $total';
  static const String sessionPause = 'Pause';
  static const String sessionResume = 'Resume';
}
