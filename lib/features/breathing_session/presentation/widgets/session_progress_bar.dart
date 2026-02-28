import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../breathing_settings/domain/models/breath_phase.dart';

/// Horizontal bar showing progress within the current phase (0.0–1.0).
/// Progress animates smoothly toward the target over each second (no jump).
/// Uses [totalSecondsInPhase] so the bar reaches 1.0 in the last second (bloc never emits 1.0).
/// In hold phases the bar animates back to 0 and remains at zero.
/// Pauses and resumes with the session (freezes animation when paused).
class SessionProgressBar extends StatefulWidget {
  const SessionProgressBar({
    super.key,
    required this.progress,
    required this.totalSecondsInPhase,
    required this.currentPhase,
    required this.isDark,
    this.isPaused = false,
  });

  final double progress;
  final int totalSecondsInPhase;
  final BreathPhase? currentPhase;
  final bool isDark;
  final bool isPaused;

  @override
  State<SessionProgressBar> createState() => _SessionProgressBarState();
}

class _SessionProgressBarState extends State<SessionProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _startProgress = 0;
  double _targetProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() => setState(() {}))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _startProgress = _targetProgress;
            }
          });
    _targetProgress = _effectiveTarget(
      widget.progress,
      widget.totalSecondsInPhase,
      widget.currentPhase,
    );
    _startProgress = _targetProgress;
  }

  /// Bloc never emits progress 1.0 (it advances phase immediately). In the last second
  /// we animate toward 1.0 so the bar completes the track. In hold phases we target 0.
  double _effectiveTarget(double progress, int totalSeconds, BreathPhase? phase) {
    if (phase == BreathPhase.holdIn || phase == BreathPhase.holdOut) {
      return 0.0;
    }
    final p = progress.clamp(0.0, 1.0);
    if (totalSeconds <= 0) return p;
    final oneStep = 1.0 / totalSeconds;
    if (p >= 1.0 - oneStep - 0.001) return 1.0;
    return p;
  }

  @override
  void didUpdateWidget(SessionProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newTarget = _effectiveTarget(
      widget.progress,
      widget.totalSecondsInPhase,
      widget.currentPhase,
    );

    if (widget.isPaused) {
      if (!oldWidget.isPaused) {
        _controller.stop();
        final current =
            lerpDouble(_startProgress, _targetProgress, _controller.value) ??
            _targetProgress;
        _startProgress = current;
        _targetProgress = current;
      }
      return;
    }

    if (newTarget == _targetProgress) return;

    _startProgress = _targetProgress;
    _targetProgress = newTarget;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _displayProgress {
    if (!_controller.isAnimating && _controller.isCompleted) {
      return _targetProgress;
    }
    final t = _controller.value;
    return lerpDouble(_startProgress, _targetProgress, t) ?? _targetProgress;
  }

  @override
  Widget build(BuildContext context) {
    final trackColor = widget.isDark
        ? AppColors.darkprogressBg
        : AppColors.lightprogressBg;
    final p = _displayProgress.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fillWidth = p >= 1.0 - 0.001 ? width : width * p;

        return SizedBox(
          width: width,
          height: 6,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Full-width track
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Fill from left, exact width so it reaches the end when p == 1
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: fillWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.progressFill1,
                          AppColors.progressFill2,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
