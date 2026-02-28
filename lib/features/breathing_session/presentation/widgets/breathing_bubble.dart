import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../breathing_settings/domain/models/breath_phase.dart';

/// Central circle: breathe in => expand, breathe out => shrink, hold => same size.
/// Shows count up (breathe in), count down (breathe out), or nothing (hold).
class BreathingBubble extends StatefulWidget {
  const BreathingBubble({
    super.key,
    required this.isDark,
    this.isPreparing = false,
    this.displayText,
    this.showSecSuffix = false,
    this.currentPhase,
    this.phaseProgress = 0,
    this.totalSecondsInPhase = 4,
    this.secondsRemainingInPhase = 0,
  });

  final bool isDark;
  final bool isPreparing;
  final String? displayText;
  final bool showSecSuffix;
  final BreathPhase? currentPhase;
  final double phaseProgress;
  final int totalSecondsInPhase;
  final int secondsRemainingInPhase;

  static const double _sizeMin = 90;
  static const double _sizeMax = 160;

  @override
  State<BreathingBubble> createState() => _BreathingBubbleState();
}

class _BreathingBubbleState extends State<BreathingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _startSizeFactor = 0;
  double _endSizeFactor = 0;

  /// Target size factor 0–1: breathe in => expand to 1.0, breathe out => shrink to 0, hold => same size.
  /// Breathe-in reaches 1.0 on the last tick (we never get progress=1 from bloc, so scale to full).
  double _targetSizeFactor(
    BreathPhase? phase,
    double progress, {
    int totalSecondsInPhase = 4,
  }) {
    if (phase == null) return 0.0;
    switch (phase) {
      case BreathPhase.breatheIn:
        if (totalSecondsInPhase <= 1) return progress.clamp(0.0, 1.0);
        final maxProgress = (totalSecondsInPhase - 1) / totalSecondsInPhase;
        if (maxProgress <= 0) return 1.0;
        return (progress / maxProgress).clamp(0.0, 1.0);
      case BreathPhase.breatheOut:
        if (totalSecondsInPhase <= 1) return (1.0 - progress).clamp(0.0, 1.0);
        final maxProgress = (totalSecondsInPhase - 1) / totalSecondsInPhase;
        if (maxProgress <= 0) return 0.0;
        return (1.0 - progress / maxProgress).clamp(0.0, 1.0);
      case BreathPhase.holdIn:
        return 1.0; // keep fully expanded
      case BreathPhase.holdOut:
        return 0.0; // keep fully shrunk
    }
  }

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() => setState(() {}))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _startSizeFactor = _endSizeFactor;
            }
          });

    if (!widget.isPreparing && widget.currentPhase != null) {
      _endSizeFactor = _targetSizeFactor(
        widget.currentPhase,
        widget.phaseProgress,
        totalSecondsInPhase: widget.totalSecondsInPhase,
      );
      _startSizeFactor = _endSizeFactor;
    }
  }

  @override
  void didUpdateWidget(BreathingBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPreparing) return;
    // Animate toward new target when phase or progress changes.
    final newTarget = _targetSizeFactor(
      widget.currentPhase,
      widget.phaseProgress,
      totalSecondsInPhase: widget.totalSecondsInPhase,
    );
    // Use current visual size as start so we never jump or shrink at phase boundaries.
    final currentFactor = _animatedSizeFactor;
    if ((newTarget - currentFactor).abs() < 0.001) return;

    _startSizeFactor = currentFactor;
    _endSizeFactor = newTarget;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _animatedSizeFactor {
    if (!_controller.isAnimating && _controller.isCompleted) {
      return _endSizeFactor;
    }
    final t = _controller.value;
    return lerpDouble(_startSizeFactor, _endSizeFactor, t) ?? _endSizeFactor;
  }

  double get _size {
    if (widget.isPreparing) return BreathingBubble._sizeMin;
    final factor = _animatedSizeFactor.clamp(0.0, 1.0);
    return BreathingBubble._sizeMin +
        (BreathingBubble._sizeMax - BreathingBubble._sizeMin) * factor;
  }

  String? get _centerText {
    if (widget.isPreparing) {
      return widget.displayText;
    }
    final phase = widget.currentPhase;
    final total = widget.totalSecondsInPhase;
    final remaining = widget.secondsRemainingInPhase;
    if (phase == BreathPhase.breatheIn) {
      final count = total - remaining + 1;
      return count.clamp(1, total).toString();
    }
    if (phase == BreathPhase.breatheOut) {
      return remaining.clamp(1, total).toString();
    }
    return null;
  }

  bool get _showSecSuffix => widget.isPreparing && widget.showSecSuffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = widget.isDark
        ? AppColors.darkBubbleBorder
        : AppColors.lightBubbleBorder;
    final gradientStart = widget.isDark
        ? AppColors.darkGradientStart
        : AppColors.lightGradientStart;
    final gradientEnd = widget.isDark
        ? AppColors.darkGradientEnd
        : AppColors.lightGradientEnd;
    final textColor = widget.isDark
        ? AppColors.darkTitle
        : AppColors.lightTitle;
    final typo = theme.extension<AppTypographyExtension>();
    final counterStyle =
        typo?.breathingCounter ?? theme.textTheme.headlineMedium;
    final subtitleStyle = typo?.subtitle ?? theme.textTheme.bodyMedium;

    final size = _size;
    final centerText = _centerText;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1),
        gradient: RadialGradient(
          colors: [gradientStart, gradientEnd],
          stops: const [0.0, 1.0],
        ),
      ),
      alignment: Alignment.center,
      child: centerText == null
          ? const SizedBox.shrink()
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  centerText,
                  style: (counterStyle ?? theme.textTheme.headlineMedium)!
                      .copyWith(
                        fontSize: 31,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                ),
                if (_showSecSuffix)
                  Text(
                    AppStrings.sessionSec,
                    style: (subtitleStyle ?? theme.textTheme.bodyMedium)!
                        .copyWith(
                          color: textColor.withValues(alpha: 0.8),
                          fontSize: 16,
                        ),
                  ),
              ],
            ),
    );
  }
}
