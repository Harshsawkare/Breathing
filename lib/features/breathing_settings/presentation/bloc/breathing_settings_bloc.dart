import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/preferences_service.dart';
import '../../domain/models/breath_phase.dart';
import 'breathing_settings_event.dart';
import 'breathing_settings_state.dart';

class BreathingSettingsBloc
    extends Bloc<BreathingSettingsEvent, BreathingSettingsState> {
  BreathingSettingsBloc(this._preferences) : super(BreathingSettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<BreathDurationSelected>(_onBreathDurationSelected);
    on<RoundPresetSelected>(_onRoundPresetSelected);
    on<AdvancedTimingToggled>(_onAdvancedTimingToggled);
    on<PhaseDurationIncremented>(_onPhaseDurationIncremented);
    on<PhaseDurationDecremented>(_onPhaseDurationDecremented);
    on<SoundToggled>(_onSoundToggled);
    on<DarkModeToggled>(_onDarkModeToggled);
  }

  final PreferencesService _preferences;

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<BreathingSettingsState> emit,
  ) async {
    final breathDuration = _preferences.breathDuration;
    final roundPreset = _preferences.roundPreset;
    final isAdvancedOpen = _preferences.advancedTimingEnabled;
    final phaseDurations = _preferences.getPhaseDurations();
    final soundOn = _preferences.soundEnabled;
    final darkModeEnabled = _preferences.darkModeEnabled;

    emit(BreathingSettingsState(
      simpleBreathDurationSeconds: breathDuration,
      roundPreset: roundPreset,
      isAdvancedOpen: isAdvancedOpen,
      phaseDurations: phaseDurations,
      soundOn: soundOn,
      darkModeEnabled: darkModeEnabled,
    ));
  }

  Future<void> _onBreathDurationSelected(
    BreathDurationSelected event,
    Emitter<BreathingSettingsState> emit,
  ) async {
    final newDuration = event.seconds.clamp(3, 6);

    // Always set all advanced timing phases to the selected breath duration.
    final updatedPhaseDurations = {
      for (final phase in BreathPhase.values) phase: newDuration,
    };

    await _preferences.setBreathDuration(newDuration);
    await _preferences.setPhaseDurations(updatedPhaseDurations);

    emit(
      state.copyWith(
        simpleBreathDurationSeconds: newDuration,
        phaseDurations: updatedPhaseDurations,
      ),
    );
  }

  Future<void> _onRoundPresetSelected(
    RoundPresetSelected event,
    Emitter<BreathingSettingsState> emit,
  ) async {
    await _preferences.setRoundPreset(event.preset);
    emit(state.copyWith(roundPreset: event.preset));
  }

  Future<void> _onAdvancedTimingToggled(
    AdvancedTimingToggled event,
    Emitter<BreathingSettingsState> emit,
  ) async {
    var updatedDurations = state.phaseDurations;

    if (!event.isOpen) {
      updatedDurations = {
        for (final phase in BreathPhase.values)
          phase: state.simpleBreathDurationSeconds,
      };
      await _preferences.setAdvancedTimingEnabled(false);
      await _preferences.setPhaseDurations(updatedDurations);
    } else {
      await _preferences.setAdvancedTimingEnabled(true);
      await _preferences.setPhaseDurations(updatedDurations);
    }

    emit(
      state.copyWith(
        isAdvancedOpen: event.isOpen,
        phaseDurations: updatedDurations,
      ),
    );
  }

  Future<void> _onPhaseDurationIncremented(
    PhaseDurationIncremented event,
    Emitter<BreathingSettingsState> emit,
  ) async {
    final updated = Map<BreathPhase, int>.from(state.phaseDurations);
    final current = updated[event.phase] ?? state.simpleBreathDurationSeconds;
    if (current >= 6) return;
    updated[event.phase] = current + 1;

    await _preferences.setPhaseDurations(updated);

    // When all phases are equal again, sync simple breath duration so that chip shows selected.
    final values = updated.values.toSet();
    final simpleDuration = values.length == 1 ? values.single : state.simpleBreathDurationSeconds;
    if (values.length == 1) {
      await _preferences.setBreathDuration(simpleDuration);
    }

    emit(state.copyWith(
      phaseDurations: updated,
      simpleBreathDurationSeconds: simpleDuration,
    ));
  }

  Future<void> _onPhaseDurationDecremented(
    PhaseDurationDecremented event,
    Emitter<BreathingSettingsState> emit,
  ) async {
    final updated = Map<BreathPhase, int>.from(state.phaseDurations);
    final current = updated[event.phase] ?? state.simpleBreathDurationSeconds;
    if (current <= 3) return;
    updated[event.phase] = current - 1;

    await _preferences.setPhaseDurations(updated);

    final values = updated.values.toSet();
    final simpleDuration = values.length == 1 ? values.single : state.simpleBreathDurationSeconds;
    if (values.length == 1) {
      await _preferences.setBreathDuration(simpleDuration);
    }

    emit(state.copyWith(
      phaseDurations: updated,
      simpleBreathDurationSeconds: simpleDuration,
    ));
  }

  Future<void> _onSoundToggled(
    SoundToggled event,
    Emitter<BreathingSettingsState> emit,
  ) async {
    await _preferences.setSoundEnabled(event.enabled);
    emit(state.copyWith(soundOn: event.enabled));
  }

  Future<void> _onDarkModeToggled(
    DarkModeToggled event,
    Emitter<BreathingSettingsState> emit,
  ) async {
    await _preferences.setDarkModeEnabled(event.enabled);
    emit(state.copyWith(darkModeEnabled: event.enabled));
  }
}
