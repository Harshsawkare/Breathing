import 'package:equatable/equatable.dart';

import '../../breathing_settings/domain/models/breath_phase.dart';

/// Lifecycle of a single breathing session.
enum SessionStatus { preparing, active, paused, completed }

class SessionState extends Equatable {
  const SessionState({
    required this.status,
    required this.prepareCountdown,
    required this.currentCycle,
    required this.totalCycles,
    required this.currentPhase,
    required this.phaseDurations,
    required this.secondsRemainingInPhase,
    required this.totalSecondsInPhase,
  });

  factory SessionState.initial() {
    return const SessionState(
      status: SessionStatus.preparing,
      prepareCountdown: 3,
      currentCycle: 0,
      totalCycles: 1,
      currentPhase: BreathPhase.breatheIn,
      phaseDurations: {},
      secondsRemainingInPhase: 0,
      totalSecondsInPhase: 0,
    );
  }

  final SessionStatus status;
  final int prepareCountdown;
  final int currentCycle;
  final int totalCycles;
  final BreathPhase? currentPhase;
  final Map<BreathPhase, int> phaseDurations;
  final int secondsRemainingInPhase;
  final int totalSecondsInPhase;

  /// Box-breathing order: in → hold in → out → hold out, then repeat for next cycle.
  static const List<BreathPhase> phaseOrder = [
    BreathPhase.breatheIn,
    BreathPhase.holdIn,
    BreathPhase.breatheOut,
    BreathPhase.holdOut,
  ];

  bool get isPreparing => status == SessionStatus.preparing;
  bool get isActive => status == SessionStatus.active;
  bool get isPaused => status == SessionStatus.paused;
  bool get isCompleted => status == SessionStatus.completed;
  bool get isRunning => isActive || isPaused;

  /// Progress within current phase (0.0 to 1.0).
  double get phaseProgress =>
      totalSecondsInPhase > 0
          ? 1.0 - (secondsRemainingInPhase / totalSecondsInPhase)
          : 0.0;

  /// Progress across the full 4-phase cycle (0.0 to 1.0).
  /// Each phase contributes an equal 25%:
  /// - breathe in:   0.00 → 0.25
  /// - hold in:      0.25 → 0.50
  /// - breathe out:  0.50 → 0.75
  /// - hold out:     0.75 → 1.00
  double get cycleProgress {
    final phase = currentPhase;
    if (phase == null) return 0.0;

    final index = phaseOrder.indexOf(phase);
    if (index < 0) return 0.0;

    final clampedPhaseProgress = phaseProgress.clamp(0.0, 1.0);

    return ((index + clampedPhaseProgress) / phaseOrder.length).clamp(0.0, 1.0);
  }

  SessionState copyWith({
    SessionStatus? status,
    int? prepareCountdown,
    int? currentCycle,
    int? totalCycles,
    BreathPhase? currentPhase,
    Map<BreathPhase, int>? phaseDurations,
    int? secondsRemainingInPhase,
    int? totalSecondsInPhase,
  }) {
    return SessionState(
      status: status ?? this.status,
      prepareCountdown: prepareCountdown ?? this.prepareCountdown,
      currentCycle: currentCycle ?? this.currentCycle,
      totalCycles: totalCycles ?? this.totalCycles,
      currentPhase: currentPhase ?? this.currentPhase,
      phaseDurations: phaseDurations ?? this.phaseDurations,
      secondsRemainingInPhase:
          secondsRemainingInPhase ?? this.secondsRemainingInPhase,
      totalSecondsInPhase: totalSecondsInPhase ?? this.totalSecondsInPhase,
    );
  }

  @override
  List<Object?> get props => [
        status,
        prepareCountdown,
        currentCycle,
        totalCycles,
        currentPhase,
        phaseDurations,
        secondsRemainingInPhase,
        totalSecondsInPhase,
      ];
}
