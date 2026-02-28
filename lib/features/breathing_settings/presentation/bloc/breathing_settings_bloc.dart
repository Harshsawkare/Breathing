import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/breath_phase.dart';
import 'breathing_settings_event.dart';
import 'breathing_settings_state.dart';

class BreathingSettingsBloc
    extends Bloc<BreathingSettingsEvent, BreathingSettingsState> {
  BreathingSettingsBloc() : super(BreathingSettingsState.initial()) {
    on<BreathDurationSelected>(_onBreathDurationSelected);
    on<RoundPresetSelected>(_onRoundPresetSelected);
    on<AdvancedTimingToggled>(_onAdvancedTimingToggled);
    on<PhaseDurationIncremented>(_onPhaseDurationIncremented);
    on<PhaseDurationDecremented>(_onPhaseDurationDecremented);
    on<SoundToggled>(_onSoundToggled);
  }

  void _onBreathDurationSelected(
    BreathDurationSelected event,
    Emitter<BreathingSettingsState> emit,
  ) {
    final newDuration = event.seconds.clamp(2, 10);

    // When the simple duration changes and advanced is closed,
    // ensure all phases use the same duration.
    final updatedPhaseDurations = Map<BreathPhase, int>.from(
      state.phaseDurations,
    );

    if (!state.isAdvancedOpen) {
      for (final phase in BreathPhase.values) {
        updatedPhaseDurations[phase] = newDuration;
      }
    }

    emit(
      state.copyWith(
        simpleBreathDurationSeconds: newDuration,
        phaseDurations: updatedPhaseDurations,
      ),
    );
  }

  void _onRoundPresetSelected(
    RoundPresetSelected event,
    Emitter<BreathingSettingsState> emit,
  ) {
    emit(state.copyWith(roundPreset: event.preset));
  }

  void _onAdvancedTimingToggled(
    AdvancedTimingToggled event,
    Emitter<BreathingSettingsState> emit,
  ) {
    var updatedDurations = state.phaseDurations;

    // When closing the panel, reset all phases to the simple duration.
    if (!event.isOpen) {
      updatedDurations = {
        for (final phase in BreathPhase.values)
          phase: state.simpleBreathDurationSeconds,
      };
    }

    emit(
      state.copyWith(
        isAdvancedOpen: event.isOpen,
        phaseDurations: updatedDurations,
      ),
    );
  }

  void _onPhaseDurationIncremented(
    PhaseDurationIncremented event,
    Emitter<BreathingSettingsState> emit,
  ) {
    final updated = Map<BreathPhase, int>.from(state.phaseDurations);
    final current = updated[event.phase] ?? state.simpleBreathDurationSeconds;
    if (current >= 10) return;
    updated[event.phase] = current + 1;

    emit(state.copyWith(phaseDurations: updated));
  }

  void _onPhaseDurationDecremented(
    PhaseDurationDecremented event,
    Emitter<BreathingSettingsState> emit,
  ) {
    final updated = Map<BreathPhase, int>.from(state.phaseDurations);
    final current = updated[event.phase] ?? state.simpleBreathDurationSeconds;
    if (current <= 2) return;
    updated[event.phase] = current - 1;

    emit(state.copyWith(phaseDurations: updated));
  }

  void _onSoundToggled(
    SoundToggled event,
    Emitter<BreathingSettingsState> emit,
  ) {
    emit(state.copyWith(soundOn: event.enabled));
  }
}

