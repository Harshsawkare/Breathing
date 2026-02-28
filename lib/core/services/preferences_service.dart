import 'package:shared_preferences/shared_preferences.dart';

import '../constants/preference_keys.dart';
import '../../features/breathing_settings/domain/models/breath_phase.dart';
import '../../features/breathing_settings/domain/models/round_preset.dart';

/// Default values when nothing is stored.
abstract final class PreferenceDefaults {
  static const int breathDuration = 4;
  static const int rounds = 4; // calm
  static const bool soundEnabled = true;
  static const bool darkMode = false;
  static const bool advancedTimingEnabled = false;
  static const int phaseSeconds = 4;
}

/// Wraps [SharedPreferences] and provides typed getters/setters for app settings.
/// Works on Android, iOS, and Flutter Web (localStorage).
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  // ----- Breath duration (3, 4, 5, 6 seconds) -----

  int get breathDuration =>
      _prefs.getInt(PreferenceKeys.breathDuration) ?? PreferenceDefaults.breathDuration;

  Future<bool> setBreathDuration(int value) async {
    final clamped = value.clamp(3, 6);
    return _prefs.setInt(PreferenceKeys.breathDuration, clamped);
  }

  // ----- Rounds (2 quick, 4 calm, 6 deep, 8 zen) -----

  int get rounds =>
      _prefs.getInt(PreferenceKeys.rounds) ?? PreferenceDefaults.rounds;

  RoundPreset get roundPreset {
    final n = rounds;
    switch (n) {
      case 2:
        return RoundPreset.quick2;
      case 4:
        return RoundPreset.calm4;
      case 6:
        return RoundPreset.deep6;
      case 8:
        return RoundPreset.zen8;
      default:
        return RoundPreset.calm4;
    }
  }

  Future<bool> setRounds(int value) async {
    final clamped = value.clamp(2, 8);
    if (![2, 4, 6, 8].contains(clamped)) {
      return _prefs.setInt(PreferenceKeys.rounds, PreferenceDefaults.rounds);
    }
    return _prefs.setInt(PreferenceKeys.rounds, clamped);
  }

  Future<bool> setRoundPreset(RoundPreset preset) async {
    return setRounds(preset.cycles);
  }

  // ----- Sound -----

  bool get soundEnabled =>
      _prefs.getBool(PreferenceKeys.soundEnabled) ?? PreferenceDefaults.soundEnabled;

  Future<bool> setSoundEnabled(bool value) async {
    return _prefs.setBool(PreferenceKeys.soundEnabled, value);
  }

  // ----- Dark mode -----

  bool get darkModeEnabled =>
      _prefs.getBool(PreferenceKeys.darkMode) ?? PreferenceDefaults.darkMode;

  Future<bool> setDarkModeEnabled(bool value) async {
    return _prefs.setBool(PreferenceKeys.darkMode, value);
  }

  // ----- Advanced timing -----

  bool get advancedTimingEnabled =>
      _prefs.getBool(PreferenceKeys.advancedTimingEnabled) ??
      PreferenceDefaults.advancedTimingEnabled;

  Future<bool> setAdvancedTimingEnabled(bool value) async {
    return _prefs.setBool(PreferenceKeys.advancedTimingEnabled, value);
  }

  int _getPhaseSeconds(String key) =>
      _prefs.getInt(key) ?? PreferenceDefaults.phaseSeconds;

  Future<bool> _setPhaseSeconds(String key, int value) async {
    final clamped = value.clamp(3, 6);
    return _prefs.setInt(key, clamped);
  }

  int get advancedBreatheIn =>
      _getPhaseSeconds(PreferenceKeys.advancedBreatheIn);

  int get advancedHoldIn => _getPhaseSeconds(PreferenceKeys.advancedHoldIn);

  int get advancedBreatheOut =>
      _getPhaseSeconds(PreferenceKeys.advancedBreatheOut);

  int get advancedHoldOut => _getPhaseSeconds(PreferenceKeys.advancedHoldOut);

  Future<bool> setAdvancedBreatheIn(int value) async =>
      _setPhaseSeconds(PreferenceKeys.advancedBreatheIn, value);

  Future<bool> setAdvancedHoldIn(int value) async =>
      _setPhaseSeconds(PreferenceKeys.advancedHoldIn, value);

  Future<bool> setAdvancedBreatheOut(int value) async =>
      _setPhaseSeconds(PreferenceKeys.advancedBreatheOut, value);

  Future<bool> setAdvancedHoldOut(int value) async =>
      _setPhaseSeconds(PreferenceKeys.advancedHoldOut, value);

  /// Returns phase durations from storage. When advanced timing is disabled,
  /// callers should use the simple breath duration for all phases.
  Map<BreathPhase, int> getPhaseDurations() {
    return {
      BreathPhase.breatheIn: advancedBreatheIn,
      BreathPhase.holdIn: advancedHoldIn,
      BreathPhase.breatheOut: advancedBreatheOut,
      BreathPhase.holdOut: advancedHoldOut,
    };
  }

  /// Saves all four phase durations (each clamped 3–6).
  Future<bool> setPhaseDurations(Map<BreathPhase, int> durations) async {
    var ok = true;
    ok &= await setAdvancedBreatheIn(
        durations[BreathPhase.breatheIn] ?? PreferenceDefaults.phaseSeconds);
    ok &= await setAdvancedHoldIn(
        durations[BreathPhase.holdIn] ?? PreferenceDefaults.phaseSeconds);
    ok &= await setAdvancedBreatheOut(
        durations[BreathPhase.breatheOut] ?? PreferenceDefaults.phaseSeconds);
    ok &= await setAdvancedHoldOut(
        durations[BreathPhase.holdOut] ?? PreferenceDefaults.phaseSeconds);
    return ok;
  }
}
