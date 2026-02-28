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
  /// Whether to play the chime when the phase changes.
  final bool soundOn;
}
