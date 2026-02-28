import 'package:equatable/equatable.dart';

import '../../domain/models/breath_phase.dart';
import '../../domain/models/round_preset.dart';

class BreathingSettingsState extends Equatable {
  const BreathingSettingsState({
    required this.simpleBreathDurationSeconds,
    required this.roundPreset,
    required this.isAdvancedOpen,
    required this.phaseDurations,
    required this.soundOn,
    required this.darkModeEnabled,
  });

  factory BreathingSettingsState.initial() {
    const baseDuration = 4;
    final defaultDurations = {
      for (final phase in BreathPhase.values) phase: baseDuration,
    };

    return BreathingSettingsState(
      simpleBreathDurationSeconds: baseDuration,
      roundPreset: RoundPreset.calm4,
      isAdvancedOpen: false,
      phaseDurations: defaultDurations,
      soundOn: true,
      darkModeEnabled: false,
    );
  }

  final int simpleBreathDurationSeconds;
  final RoundPreset roundPreset;
  final bool isAdvancedOpen;
  final Map<BreathPhase, int> phaseDurations;
  final bool soundOn;
  final bool darkModeEnabled;

  BreathingSettingsState copyWith({
    int? simpleBreathDurationSeconds,
    RoundPreset? roundPreset,
    bool? isAdvancedOpen,
    Map<BreathPhase, int>? phaseDurations,
    bool? soundOn,
    bool? darkModeEnabled,
  }) {
    return BreathingSettingsState(
      simpleBreathDurationSeconds:
          simpleBreathDurationSeconds ?? this.simpleBreathDurationSeconds,
      roundPreset: roundPreset ?? this.roundPreset,
      isAdvancedOpen: isAdvancedOpen ?? this.isAdvancedOpen,
      phaseDurations: phaseDurations ?? this.phaseDurations,
      soundOn: soundOn ?? this.soundOn,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }

  @override
  List<Object?> get props => [
        simpleBreathDurationSeconds,
        roundPreset,
        isAdvancedOpen,
        phaseDurations,
        soundOn,
        darkModeEnabled,
      ];
}

