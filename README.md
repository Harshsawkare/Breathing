# Breathing

## Project Overview

The app guides users through configurable breathing cycles (breathe in → hold in → breathe out → hold out) with optional sound cues and a responsive, theme-aware UI. Implementation focuses on clean architecture, BLoC-based state, and production-ready code across platforms.

---

## Live Demo

<!-- Add hosted web link when deployed -->
**Web:** [Web-link](https://newu-breathing.web.app/)

---

## Feature Overview

**End-to-end flow:** `main` loads `SharedPreferences`, builds `PreferencesService` and `ThemeCubit`, then `MaterialApp` starts on **Splash** (~2.2s) and **replaces** the route with **Breathing Settings** (home). **Start breathing** pushes **Breathing Session** with a `SessionConfig` (phase durations, round preset, sound on/off). After all cycles, the session screen **replaces** itself with **Session Completion** (same config in route arguments for **Start again**). **Back to home** pops the stack until Settings; closing the session (X) resets `SessionBloc` and **pops** to the previous screen without going through completion.

| Screen | Purpose |
|--------|--------|
| **Splash** | App icon, title, themed background; timer then `pushReplacement` to Settings. |
| **Breathing Settings** | Breath length (3 / 4 / 5 / 6s), rounds (2 / 4 / 6 / 8), optional advanced per-phase timing, sound toggle, dark mode; **Start breathing** passes live config into the session route. |
| **Breathing Session** | 3s **Get ready** countdown, then guided cycles: affirmation, bubble + phase copy, cycle **x of n**, per-cycle progress bar, pause/resume (after the first phase), close (pop) and theme toggle. |
| **Session Completion** | Success Lottie (fallback icon if asset fails), **Start again** (same `SessionConfig`), **Back to home** (pop until Settings), theme toggle. |

**Settings:** Simple mode uses one duration for all four phases (stored and applied consistently with advanced keys). **Advanced timing** exposes each phase at 3–6s; turning it off resets every phase to the current simple duration. Round chips map to presets (`2 quick` … `8 zen`). Wider layouts cap content width (~480px) for readability.

**Session:** One **cycle** = Breathe In → Hold In → Breathe Out → Hold Out; **rounds** = number of full cycles. Progress bar reflects position within the current cycle. Session progress is not persisted.

---

## Architecture

Feature-driven **clean architecture**: each feature owns its domain models, BLoC (events/states), and presentation (pages/widgets). Shared UI and app-wide concerns live in `core/` and `shared/`.

- **Core:** `PreferencesService` (SharedPreferences wrapper), constants, theme (colors, typography, light/dark), `ThemeCubit`.
- **App shell:** `RepositoryProvider<PreferencesService>` plus `BlocProvider<ThemeCubit>` in `main` / `BreathingApp`; named routes in `MaterialApp`.
- **Features:** Self-contained modules (splash, breathing_settings, breathing_session, session_completion) with clear boundaries.
- **State:** BLoC for session and settings; Cubit for theme. Session and settings blocs are scoped to their routes (new `SessionBloc` per session run).

---

## Folder Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/     # app_assets, app_strings, preference_keys
│   ├── services/      # preferences_service
│   └── theme/         # app_colors, app_theme, app_typography, theme_cubit
├── features/
│   ├── splash/                # presentation/pages
│   ├── breathing_settings/    # domain/models, presentation/bloc + pages
│   ├── breathing_session/     # bloc (session state machine), presentation/screen + widgets
│   └── session_completion/    # presentation/pages
└── shared/
    └── widgets/       # background_with_overlays, selectable_chip, primary_button
```

---

## State Management

- **flutter_bloc** for feature logic. Settings: `BreathingSettingsBloc` (load/save preferences, round/phase config, sound, dark mode). Session: **SessionBloc** as a state machine—`SessionStatus` is `preparing` (3s countdown), `active`, `paused`, or `completed` only (no separate “cancelled” state; close dispatches `SessionClosed` and pops). Events: `SessionStartRequested` (normalises preset → cycle count), `SessionStarted`, `SessionTick`, `SessionPaused`, `SessionResumed`, `SessionClosed`. A **1 Hz** `Timer.periodic` emits `SessionTick` while preparing or active (not paused), driving countdown and phase transitions.
- **ThemeCubit** in core for light/dark; persisted via `PreferencesService` (also toggled from settings, session, and completion UIs).

---

## Animation & Breathing Logic

- **Bubble:** `AnimationController` interpolates **scale** only—breathe in expands, breathe out shrinks, hold phases stay at the expanded or shrunk size. Center text: countdown + “sec” while preparing; breathe in shows a **count up**, breathe out a **count down**; hold phases show no number in the bubble.
- **Phases:** Ordered list `breatheIn → holdIn → breatheOut → holdOut`. BLoC holds `currentPhase`, `secondsRemainingInPhase`, `totalSecondsInPhase`, and `phaseDurations` (from the session route arguments). Each `SessionTick` decrements the active timer; at zero the bloc advances phase, starts the next cycle, or emits `completed`.
- **Audio:** `audioplayers` plays a bundled chime when sound is on: at each **phase start** while active, and again at **3 seconds remaining** when the phase length is **6s**. No network.

---

## Local Persistence

**SharedPreferences** (via `PreferencesService`); on web this uses the standard Flutter web implementation (e.g. localStorage under the hood).

**Persisted:** `breath_duration`, `rounds`, `sound_enabled`, `dark_mode`, `advanced_timing_enabled`, and per-phase durations (`advanced_breathe_in`, `advanced_hold_in`, `advanced_breathe_out`, `advanced_hold_out`). Defaults and clamps live in `PreferenceDefaults` / `PreferencesService` (e.g. breath and phases 3–6s, rounds only 2/4/6/8).

**Not persisted:** Session progress or in-progress session state (assignment treated caching as optional).

---

## Engineering Decisions

- **BLoC over setState:** Session timing and phase transitions are easier to reason about and test as a single state machine with discrete events.
- **SharedPreferences:** Simple key-value persistence with good cross-platform support (including web) and no extra infra.
- **Feature folders:** Scales better than layer-first (e.g. “all blocs in one folder”); each feature can be understood in isolation.
- **Single tick stream:** One `SessionTick` per second keeps the state machine simple and avoids multiple timers or async drift.
- **Local assets only:** Lottie and audio are bundled; no runtime network for core flows.
- **Web layout:** Session and completion screens constrain max width (~400px) for a phone-like column on large viewports.

---

## Trade-offs (Hackathon)

- **No session resume:** In-progress sessions are not saved; restarting the app starts fresh. Reduces scope and avoids edge cases (e.g. app killed mid-phase).
- **No backend:** All state is local; no sync, no accounts. Fits the assignment and demo scope.
- **Preset-only rounds:** Rounds are 2/4/6/8; no arbitrary number. Keeps UI and validation simple.
- **Web and mobile share one codebase:** Responsive caps on content/session width; no separate web-only product surface.

---

## Dependencies (Summary)

| Package | Use |
|--------|-----|
| flutter_bloc, equatable | State management |
| lottie | Completion success animation |
| audioplayers | Chimes (phase start; extra cue at 3s left on 6s phases) |
| shared_preferences | Local persistence |
| flutter_svg | SVG assets |

---

*Built with Flutter.*
