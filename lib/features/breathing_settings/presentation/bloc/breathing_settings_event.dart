import 'package:equatable/equatable.dart';

import '../../domain/models/breath_phase.dart';
import '../../domain/models/round_preset.dart';

abstract class BreathingSettingsEvent extends Equatable {
  const BreathingSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load settings from PreferencesService into state.
class LoadSettings extends BreathingSettingsEvent {
  const LoadSettings();
}

class BreathDurationSelected extends BreathingSettingsEvent {
  const BreathDurationSelected(this.seconds);

  final int seconds;

  @override
  List<Object?> get props => [seconds];
}

class RoundPresetSelected extends BreathingSettingsEvent {
  const RoundPresetSelected(this.preset);

  final RoundPreset preset;

  @override
  List<Object?> get props => [preset];
}

class AdvancedTimingToggled extends BreathingSettingsEvent {
  const AdvancedTimingToggled(this.isOpen);

  final bool isOpen;

  @override
  List<Object?> get props => [isOpen];
}

class PhaseDurationIncremented extends BreathingSettingsEvent {
  const PhaseDurationIncremented(this.phase);

  final BreathPhase phase;

  @override
  List<Object?> get props => [phase];
}

class PhaseDurationDecremented extends BreathingSettingsEvent {
  const PhaseDurationDecremented(this.phase);

  final BreathPhase phase;

  @override
  List<Object?> get props => [phase];
}

class SoundToggled extends BreathingSettingsEvent {
  const SoundToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

class DarkModeToggled extends BreathingSettingsEvent {
  const DarkModeToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

