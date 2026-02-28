import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../breathing_settings/domain/models/breath_phase.dart';

/// Central circle: animates size by phase (90px hold, 90→120 breathe in, 120→90 breathe out);
/// shows count up (breathe in), count down (breathe out), or nothing (hold).
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

  double _targetSizeFactor(BreathPhase? phase, double progress) {
    if (phase == null) return 0.0;
    switch (phase) {
      case BreathPhase.breatheIn:
        return progress.clamp(0.0, 1.0);
      case BreathPhase.breatheOut:
        return (1.0 - progress).clamp(0.0, 1.0);
      case BreathPhase.holdIn:
      case BreathPhase.holdOut:
        return 0.0;
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
      );
      _startSizeFactor = _endSizeFactor;
    }
  }

  @override
  void didUpdateWidget(BreathingBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPreparing) return;

    final newTarget = _targetSizeFactor(
      widget.currentPhase,
      widget.phaseProgress,
    );
    if (newTarget == _endSizeFactor) return;

    _startSizeFactor = _endSizeFactor;
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
