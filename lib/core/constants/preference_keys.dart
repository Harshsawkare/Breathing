/// String constants for SharedPreferences keys (persistent storage).
/// Maps to localStorage on Flutter Web.
abstract final class PreferenceKeys {
  PreferenceKeys._();

  static const String breathDuration = 'breath_duration';
  static const String rounds = 'rounds';
  static const String soundEnabled = 'sound_enabled';
  static const String darkMode = 'dark_mode';
  // Advanced timing: per-phase durations (3–6s each).
  static const String advancedTimingEnabled = 'advanced_timing_enabled';
  static const String advancedBreatheIn = 'advanced_breathe_in';
  static const String advancedHoldIn = 'advanced_hold_in';
  static const String advancedBreatheOut = 'advanced_breathe_out';
  static const String advancedHoldOut = 'advanced_hold_out';
}
