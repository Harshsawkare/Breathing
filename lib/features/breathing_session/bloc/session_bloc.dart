import 'package:flutter_bloc/flutter_bloc.dart';

import '../../breathing_settings/domain/models/breath_phase.dart';
import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc() : super(SessionState.initial()) {
    on<SessionStartRequested>(_onStartRequested);
    on<SessionStarted>(_onStarted);
    on<SessionTick>(_onTick);
    on<SessionPaused>(_onPaused);
    on<SessionResumed>(_onResumed);
    on<SessionClosed>(_onClosed);
  }

  /// Normalises settings-based start into a SessionStarted event with cycle count.
  void _onStartRequested(
    SessionStartRequested event,
    Emitter<SessionState> emit,
  ) {
    add(SessionStarted(
      phaseDurations: event.phaseDurations,
      totalCycles: event.roundPreset.cycles,
    ));
  }

  /// Enters preparing state with 3s countdown before first phase.
  void _onStarted(SessionStarted event, Emitter<SessionState> emit) {
    emit(SessionState(
      status: SessionStatus.preparing,
      prepareCountdown: 3,
      currentCycle: 1,
      totalCycles: event.totalCycles,
      currentPhase: BreathPhase.breatheIn,
      phaseDurations: event.phaseDurations,
      secondsRemainingInPhase: 0,
      totalSecondsInPhase: 0,
    ));
  }

  /// Decrements prepare countdown or phase timer; advances phase/cycle when zero.
  void _onTick(SessionTick event, Emitter<SessionState> emit) {
    if (state.isPaused) return;

    if (state.isPreparing) {
      final next = state.prepareCountdown - 1;
      if (next <= 0) {
        _startFirstPhase(emit);
      } else {
        emit(state.copyWith(prepareCountdown: next));
      }
      return;
    }

    if (!state.isActive) return;

    final remaining = state.secondsRemainingInPhase - 1;
    if (remaining <= 0) {
      _advancePhaseOrCycle(emit);
    } else {
      emit(state.copyWith(secondsRemainingInPhase: remaining));
    }
  }

  /// Switches to active and starts the first phase (breathe in) with its duration.
  void _startFirstPhase(Emitter<SessionState> emit) {
    final phase = SessionState.phaseOrder.first;
    final duration = state.phaseDurations[phase] ?? 4;
    emit(state.copyWith(
      status: SessionStatus.active,
      prepareCountdown: 0,
      currentPhase: phase,
      secondsRemainingInPhase: duration,
      totalSecondsInPhase: duration,
    ));
  }

  /// Moves to next phase in order, or next cycle; completes session when cycles exhausted.
  void _advancePhaseOrCycle(Emitter<SessionState> emit) {
    final order = SessionState.phaseOrder;
    final current = state.currentPhase;
    final index = current == null ? -1 : order.indexOf(current);
    final nextIndex = index + 1;

    if (nextIndex < order.length) {
      final nextPhase = order[nextIndex];
      final duration = state.phaseDurations[nextPhase] ?? 4;
      emit(state.copyWith(
        currentPhase: nextPhase,
        secondsRemainingInPhase: duration,
        totalSecondsInPhase: duration,
      ));
      return;
    }

    final nextCycle = state.currentCycle + 1;
    if (nextCycle > state.totalCycles) {
      emit(state.copyWith(status: SessionStatus.completed));
      return;
    }

    final firstPhase = order.first;
    final duration = state.phaseDurations[firstPhase] ?? 4;
    emit(state.copyWith(
      currentCycle: nextCycle,
      currentPhase: firstPhase,
      secondsRemainingInPhase: duration,
      totalSecondsInPhase: duration,
    ));
  }

  void _onPaused(SessionPaused event, Emitter<SessionState> emit) {
    if (state.isActive) emit(state.copyWith(status: SessionStatus.paused));
  }

  void _onResumed(SessionResumed event, Emitter<SessionState> emit) {
    if (state.isPaused) emit(state.copyWith(status: SessionStatus.active));
  }

  void _onClosed(SessionClosed event, Emitter<SessionState> emit) {
    emit(SessionState.initial());
  }
}
