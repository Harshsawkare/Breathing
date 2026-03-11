import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:breathing/core/theme/app_typography.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../shared/widgets/background_with_overlays.dart';
import '../../breathing_settings/domain/models/breath_phase.dart';
import '../bloc/session_bloc.dart';
import '../bloc/session_event.dart';
import '../bloc/session_state.dart';
import '../session_config.dart';
import 'widgets/breathing_bubble.dart';
import 'widgets/phase_label.dart';
import 'widgets/session_progress_bar.dart';

class BreathingSessionScreen extends StatefulWidget {
  const BreathingSessionScreen({super.key});

  static const routeName = AppStrings.routeSession;

  @override
  State<BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<BreathingSessionScreen> {
  Timer? _ticker;
  StreamSubscription<SessionState>? _subscription;
  SessionState?
  _previousState; // Used to detect phase changes for chime and ticker.
  bool _soundOn = false;
  AudioPlayer? _chimePlayer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = context.read<SessionBloc>();
    if (_subscription == null) {
      // Start session from route arguments and subscribe to state.
      final config = _sessionConfig;
      if (config != null) {
        _soundOn = config.soundOn;
        bloc.add(
          SessionStartRequested(
            phaseDurations: config.phaseDurations,
            roundPreset: config.roundPreset,
          ),
        );
      }
      _subscription = bloc.stream.listen(_onSessionStateChanged);
    }
  }

  /// Reads session config from the route that pushed this screen.
  SessionConfig? get _sessionConfig {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is SessionConfig ? args : null;
  }

  /// Plays the phase chime once if sound is on; uses AssetSource path without "assets/" prefix.
  void _playChime() {
    if (!_soundOn || !mounted) return;
    _chimePlayer ??= AudioPlayer();
    // AssetSource expects path without leading "assets/".
    final path = AppAssets.chimeSound.replaceFirst('assets/', '');
    _chimePlayer!.play(AssetSource(path));
  }

  void _onSessionStateChanged(SessionState state) {
    // Play chime on phase start, and again at 3s remaining when phase duration is 6s.
    if (_soundOn && state.isActive && state.currentPhase != null) {
      final prev = _previousState;
      final phaseJustStarted =
          (prev == null ||
              prev.currentPhase != state.currentPhase ||
              prev.isPreparing) &&
          state.secondsRemainingInPhase == state.totalSecondsInPhase;
      final repeatAtThree =
          state.totalSecondsInPhase == 6 &&
          state.secondsRemainingInPhase == 3 &&
          prev?.secondsRemainingInPhase == 4;
      if (phaseJustStarted || repeatAtThree) {
        _playChime();
      }
    }
    _previousState = state;

    // Drive session clock: 1s periodic timer while preparing or active and not paused.
    final runTicker = state.isPreparing || (state.isActive && !state.isPaused);
    if (runTicker && (_ticker == null || !_ticker!.isActive)) {
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) context.read<SessionBloc>().add(const SessionTick());
      });
    } else if (!runTicker) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _subscription?.cancel();
    _chimePlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BackgroundWithOverlays(
        isDark: isDark,
        child: SafeArea(
          child: _wrapForWeb(
            child: BlocBuilder<SessionBloc, SessionState>(
              builder: (context, state) {
                if (state.isCompleted) {
                  // Navigate to completion screen, then pop this session.
                  // Do not dispatch SessionClosed() here — it resets state to initial
                  // and causes the UI to show "Get ready" again instead of navigating.
                  context.read<SessionBloc>().add(const SessionClosed());
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final config = _sessionConfig;
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(
                        AppStrings.routeCompletion,
                        arguments: config,
                      );
                    }
                  });
                  return const SizedBox.shrink();
                }
                return _SessionContent(
                  state: state,
                  isDark: isDark,
                  onClose: _onClose,
                  onToggleTheme: _onToggleTheme,
                  onPause: _onPause,
                  onResume: _onResume,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// User tapped close; reset bloc and return to previous screen.
  void _onClose() {
    context.read<SessionBloc>().add(const SessionClosed());
    Navigator.of(context).pop();
  }

  void _onToggleTheme() {
    final willBeDark = Theme.of(context).brightness != Brightness.dark;
    context.read<ThemeCubit>().toggle();
    context.read<PreferencesService>().setDarkModeEnabled(willBeDark);
  }

  void _onPause() {
    context.read<SessionBloc>().add(const SessionPaused());
  }

  void _onResume() {
    context.read<SessionBloc>().add(const SessionResumed());
  }

  /// Constrain width on web for a mobile-like layout.
  Widget _wrapForWeb({required Widget child}) {
    if (!kIsWeb) return child;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: child,
      ),
    );
  }
}

/// Main column: header, affirmation, bubble, phase label, progress, cycle text, pause/resume.
class _SessionContent extends StatelessWidget {
  const _SessionContent({
    required this.state,
    required this.isDark,
    required this.onClose,
    required this.onToggleTheme,
    required this.onPause,
    required this.onResume,
  });

  final SessionState state;
  final bool isDark;
  final VoidCallback onClose;
  final VoidCallback onToggleTheme;
  final VoidCallback onPause;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final showGetReady = state.isPreparing;
    // Derive main label and bubble from phase or "Get ready" countdown.
    final title = showGetReady
        ? AppStrings.sessionGetReady
        : _phaseTitle(state.currentPhase);
    final subtitle = showGetReady
        ? AppStrings.sessionGetReadySubtitle
        : _phaseSubtitle(state.currentPhase);
    final bubbleText = showGetReady
        ? '${state.prepareCountdown}'
        : '${state.secondsRemainingInPhase}';
    final showSecSuffix = state.isPreparing;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header stays fixed at the top.
          _SessionHeader(
            isDark: isDark,
            onClose: onClose,
            onToggleTheme: onToggleTheme,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.sessionAffirmation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    fontFamily: AppTypography.fontFamilyBody,
                    color: isDark
                        ? AppColors.darkSubtitle
                        : AppColors.lightSubtitle,
                  ),
                ),
                const SizedBox(height: 80),
                SizedBox(
                  width: 230,
                  height: 230,
                  child: Center(
                    child: BreathingBubble(
                      isDark: isDark,
                      isPreparing: showGetReady,
                      displayText: bubbleText,
                      showSecSuffix: showSecSuffix,
                      currentPhase: state.currentPhase,
                      phaseProgress: state.phaseProgress,
                      totalSecondsInPhase: state.totalSecondsInPhase,
                      secondsRemainingInPhase: state.secondsRemainingInPhase,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                PhaseLabel(title: title, subtitle: subtitle, isDark: isDark),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: SessionProgressBar(
                    progress: state.phaseProgress,
                    totalSecondsInPhase: state.totalSecondsInPhase,
                    currentPhase: state.currentPhase,
                    isDark: isDark,
                    isPaused: state.isPaused,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.isPreparing
                      ? AppStrings.sessionCycle(1, state.totalCycles)
                      : AppStrings.sessionCycle(
                          state.currentCycle,
                          state.totalCycles,
                        ),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
                    fontFamily: AppTypography.fontFamilyHeading,
                  ),
                ),
                const SizedBox(height: 24),
                // Only show pause/resume once the first phase has started.
                if (state.isRunning)
                  _PauseResumeButton(
                    isPaused: state.isPaused,
                    isDark: isDark,
                    onPause: onPause,
                    onResume: onResume,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _phaseTitle(BreathPhase? phase) {
    if (phase == null) return AppStrings.sessionGetReady;
    switch (phase) {
      case BreathPhase.breatheIn:
        return AppStrings.phaseBreatheIn;
      case BreathPhase.holdIn:
        return AppStrings.sessionPhaseHoldIn;
      case BreathPhase.breatheOut:
        return AppStrings.phaseBreatheOut;
      case BreathPhase.holdOut:
        return AppStrings.sessionPhaseHoldOut;
    }
  }

  String _phaseSubtitle(BreathPhase? phase) {
    if (phase == null) return AppStrings.sessionGetReadySubtitle;
    switch (phase) {
      case BreathPhase.breatheIn:
        return AppStrings.sessionSubtitleBreatheIn;
      case BreathPhase.holdIn:
        return AppStrings.sessionSubtitleHoldIn;
      case BreathPhase.breatheOut:
        return AppStrings.sessionSubtitleBreatheOut;
      case BreathPhase.holdOut:
        return AppStrings.sessionSubtitleHoldOut;
    }
  }
}

/// Top row: close (X) and theme toggle (sun/moon).
class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.isDark,
    required this.onClose,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onClose;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CircleButton(isDark: isDark, icon: Icons.close, onTap: onClose),
        _CircleButton(
          isDark: isDark,
          icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          onTap: onToggleTheme,
        ),
      ],
    );
  }
}

/// Circular icon button used in the session header (close, theme).
class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.isDark,
    required this.icon,
    required this.onTap,
  });

  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkThemeIconBg
              : AppColors.lightThemeIconBg,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDark ? AppColors.darkThemeIcon : AppColors.lightThemeIcon,
        ),
      ),
    );
  }
}

/// Full-width pill button to pause or resume the session.
class _PauseResumeButton extends StatelessWidget {
  const _PauseResumeButton({
    required this.isPaused,
    required this.isDark,
    required this.onPause,
    required this.onResume,
  });

  final bool isPaused;
  final bool isDark;
  final VoidCallback onPause;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final label = isPaused ? AppStrings.sessionResume : AppStrings.sessionPause;
    final iconAsset = isPaused
        ? (isDark ? AppAssets.iconPlayDark : AppAssets.iconPlayLight)
        : (isDark ? AppAssets.iconPauseDark : AppAssets.iconPauseLight);
    final bgColor = isDark
        ? AppColors.darkPlayPauseButtonBg
        : AppColors.lightPlayPauseButtonBg;
    final textColor = isDark
        ? AppColors.darkButtonText
        : AppColors.lightButtonText;

    return SizedBox(
      width: 130,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: isPaused ? onResume : onPause,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(iconAsset, width: 24, height: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: textColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
