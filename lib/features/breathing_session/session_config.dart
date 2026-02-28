import '../breathing_settings/domain/models/breath_phase.dart';
import '../breathing_settings/domain/models/round_preset.dart';

/// Config passed when navigating to the breathing session.
class SessionConfig {
  const SessionConfig({
    required this.phaseDurations,
    required this.roundPreset,
    required this.soundOn,
  });

  final Map<BreathPhase, int> phaseDurations;
  final RoundPreset roundPreset;
  final bool soundOn; // Whether to play chime on phase change.
}
