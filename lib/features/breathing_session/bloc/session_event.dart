import 'package:equatable/equatable.dart';

import '../../breathing_settings/domain/models/breath_phase.dart';
import '../../breathing_settings/domain/models/round_preset.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

/// Start a new session with the given config.
class SessionStarted extends SessionEvent {
  const SessionStarted({
    required this.phaseDurations,
    required this.totalCycles,
  });

  final Map<BreathPhase, int> phaseDurations;
  final int totalCycles;

  @override
  List<Object?> get props => [phaseDurations, totalCycles];
}

/// Start session from settings (uses RoundPreset.cycles).
class SessionStartRequested extends SessionEvent {
  const SessionStartRequested({
    required this.phaseDurations,
    required this.roundPreset,
  });

  final Map<BreathPhase, int> phaseDurations;
  final RoundPreset roundPreset;

  @override
  List<Object?> get props => [phaseDurations, roundPreset];
}

/// One second elapsed; update countdown/phase.
class SessionTick extends SessionEvent {
  const SessionTick();
}

/// User paused the session; timer stops, UI shows Resume.
class SessionPaused extends SessionEvent {
  const SessionPaused();
}

/// User resumed; timer runs again from current phase.
class SessionResumed extends SessionEvent {
  const SessionResumed();
}

/// User closed or session ended; bloc resets and screen pops.
class SessionClosed extends SessionEvent {
  const SessionClosed();
}
