import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:breathing/core/theme/app_typography.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../shared/widgets/background_with_overlays.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/selectable_chip.dart';
import '../../../breathing_session/session_config.dart';
import '../../domain/models/breath_phase.dart';
import '../../domain/models/round_preset.dart';
import '../bloc/breathing_settings_bloc.dart';
import '../bloc/breathing_settings_event.dart';
import '../bloc/breathing_settings_state.dart';

class BreathingSettingsPage extends StatelessWidget {
  const BreathingSettingsPage({super.key});

  static const routeName = AppStrings.routeSettings;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final preferences = context.read<PreferencesService>();
        // Load persisted settings on first build.
        return BreathingSettingsBloc(preferences)..add(const LoadSettings());
      },
      child: const _BreathingSettingsView(),
    );
  }
}

class _BreathingSettingsView extends StatelessWidget {
  const _BreathingSettingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BackgroundWithOverlays(
        isDark: isDark,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              // Cap content width on large screens for readability.
              final contentWidth = maxWidth < 600 ? maxWidth : 480.0;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HeaderRow(isDark: isDark),
                          const SizedBox(height: 24),
                          Text(
                            AppStrings.settingsSetYourPace,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.settingsSubtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 24),
                          const _SettingsCard(),
                          const SizedBox(height: 24),
                          BlocBuilder<
                            BreathingSettingsBloc,
                            BreathingSettingsState
                          >(
                            buildWhen: (prev, curr) =>
                                prev.phaseDurations != curr.phaseDurations ||
                                prev.roundPreset != curr.roundPreset,
                            builder: (context, state) {
                              return PrimaryButton(
                                label: AppStrings.settingsStartBreathing,
                                onPressed: () {
                                  // Pass current config so session and completion can reuse it.
                                  Navigator.of(context).pushNamed(
                                    AppStrings.routeSession,
                                    arguments: SessionConfig(
                                      phaseDurations: state.phaseDurations,
                                      roundPreset: state.roundPreset,
                                      soundOn: state.soundOn,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreathingSettingsBloc, BreathingSettingsState>(
      buildWhen: (prev, curr) => prev.darkModeEnabled != curr.darkModeEnabled,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                final newDark = !state.darkModeEnabled;
                context.read<BreathingSettingsBloc>().add(
                  DarkModeToggled(newDark),
                );
                context.read<ThemeCubit>().setDark(newDark);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkThemeIconBg
                      : AppColors.lightThemeIconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 20,
                  color: isDark
                      ? AppColors.darkThemeIcon
                      : AppColors.lightThemeIcon,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BreathDurationSection(),
          const SizedBox(height: 20),
          const _RoundsSection(),
          const SizedBox(height: 20),
          const _AdvancedTimingSection(),
          const SizedBox(height: 20),
          const _SoundSection(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _BreathDurationSection extends StatelessWidget {
  const _BreathDurationSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: AppStrings.breathDuration,
          subtitle: AppStrings.secondsPerPhase,
        ),
        const SizedBox(height: 12),
        BlocBuilder<BreathingSettingsBloc, BreathingSettingsState>(
          buildWhen: (prev, curr) =>
              prev.simpleBreathDurationSeconds !=
                  curr.simpleBreathDurationSeconds ||
              prev.phaseDurations != curr.phaseDurations,
          builder: (context, state) {
            const options = [3, 4, 5, 6];
            final phaseValues = state.phaseDurations.values.toSet();
            final allPhasesEqualOneValue = phaseValues.length == 1;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < options.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    SelectableChip(
                      label: AppStrings.secondsLabel(options[i]),
                      selected:
                          allPhasesEqualOneValue &&
                          state.phaseDurations[BreathPhase.breatheIn] ==
                              options[i],
                      onTap: () {
                        context.read<BreathingSettingsBloc>().add(
                          BreathDurationSelected(options[i]),
                        );
                      },
                      minWidth: 64,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RoundsSection extends StatelessWidget {
  const _RoundsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: AppStrings.rounds,
          subtitle: AppStrings.roundsSubtitle,
        ),
        const SizedBox(height: 12),
        BlocBuilder<BreathingSettingsBloc, BreathingSettingsState>(
          buildWhen: (prev, curr) => prev.roundPreset != curr.roundPreset,
          builder: (context, state) {
            final presets = RoundPreset.values;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < presets.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    SelectableChip(
                      label: _roundPresetLabel(presets[i]),
                      selected: state.roundPreset == presets[i],
                      onTap: () {
                        context.read<BreathingSettingsBloc>().add(
                          RoundPresetSelected(presets[i]),
                        );
                      },
                      minWidth: 80,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AdvancedTimingSection extends StatelessWidget {
  const _AdvancedTimingSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreathingSettingsBloc, BreathingSettingsState>(
      buildWhen: (prev, curr) =>
          prev.isAdvancedOpen != curr.isAdvancedOpen ||
          prev.phaseDurations != curr.phaseDurations,
      builder: (context, state) {
        final isOpen = state.isAdvancedOpen;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: AppStrings.advancedTiming,
              subtitle: AppStrings.advancedTimingSubtitle,
              trailing: IconButton(
                onPressed: () {
                  context.read<BreathingSettingsBloc>().add(
                    AdvancedTimingToggled(!isOpen),
                  );
                },
                icon: AnimatedRotation(
                  duration: const Duration(milliseconds: 180),
                  turns: isOpen ? 0.5 : 0.0,
                  child: Icon(
                    Icons.expand_more_rounded,
                    size: 20,
                    color: isDark
                        ? AppColors.darkExpandIcon
                        : AppColors.lightExpandIcon,
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    _PhaseRow(
                      label: AppStrings.phaseBreatheIn,
                      phase: BreathPhase.breatheIn,
                      seconds: state.phaseDurations[BreathPhase.breatheIn] ?? 4,
                    ),
                    const SizedBox(height: 8),
                    _PhaseRow(
                      label: AppStrings.phaseHoldIn,
                      phase: BreathPhase.holdIn,
                      seconds: state.phaseDurations[BreathPhase.holdIn] ?? 4,
                    ),
                    const SizedBox(height: 8),
                    _PhaseRow(
                      label: AppStrings.phaseBreatheOut,
                      phase: BreathPhase.breatheOut,
                      seconds:
                          state.phaseDurations[BreathPhase.breatheOut] ?? 4,
                    ),
                    const SizedBox(height: 8),
                    _PhaseRow(
                      label: AppStrings.phaseHoldOut,
                      phase: BreathPhase.holdOut,
                      seconds: state.phaseDurations[BreathPhase.holdOut] ?? 4,
                    ),
                  ],
                ),
              ),
              crossFadeState: isOpen
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),
          ],
        );
      },
    );
  }
}

class _PhaseRow extends StatelessWidget {
  const _PhaseRow({
    required this.label,
    required this.phase,
    required this.seconds,
  });

  final String label;
  final BreathPhase phase;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDark
            ? AppColors.darkAdvancedCard
            : AppColors.lightAdvancedCard,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
                  fontFamily: AppTypography.fontFamilyHeading,
                ),
              ),
            ),
            _RoundIconButton(
              icon: Icons.remove_rounded,
              onPressed: () {
                context.read<BreathingSettingsBloc>().add(
                  PhaseDurationDecremented(phase),
                );
              },
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.secondsLabel(seconds),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
              ),
            ),
            const SizedBox(width: 12),
            _RoundIconButton(
              icon: Icons.add_rounded,
              onPressed: () {
                context.read<BreathingSettingsBloc>().add(
                  PhaseDurationIncremented(phase),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkIncrementButtonBg
              : AppColors.lightIncrementButtonBg,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark
              ? AppColors.darkIncrementButtonFg
              : AppColors.lightIncrementButtonFg,
        ),
      ),
    );
  }
}

class _SoundSection extends StatelessWidget {
  const _SoundSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<BreathingSettingsBloc, BreathingSettingsState>(
      buildWhen: (prev, curr) => prev.soundOn != curr.soundOn,
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.sound, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.soundSubtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: state.soundOn,
              activeThumbColor: AppColors.lightActiveToggleThumb,
              activeTrackColor: theme.brightness == Brightness.dark
                  ? AppColors.darkActiveTrack
                  : AppColors.lightActiveTrack,
              inactiveThumbColor: AppColors.darkActiveToggleThumb,
              inactiveTrackColor: theme.brightness == Brightness.dark
                  ? AppColors.darkInActiveTrack
                  : AppColors.lightInActiveTrack,
              onChanged: (value) {
                context.read<BreathingSettingsBloc>().add(SoundToggled(value));
              },
            ),
          ],
        );
      },
    );
  }
}

String _roundPresetLabel(RoundPreset preset) {
  switch (preset) {
    case RoundPreset.quick2:
      return AppStrings.roundPreset2Quick;
    case RoundPreset.calm4:
      return AppStrings.roundPreset4Calm;
    case RoundPreset.deep6:
      return AppStrings.roundPreset6Deep;
    case RoundPreset.zen8:
      return AppStrings.roundPreset8Zen;
  }
}
