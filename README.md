# Breathing

## Project Overview

The app guides users through configurable breathing cycles (breathe in → hold in → breathe out → hold out) with optional sound cues and a responsive, theme-aware UI. Implementation focuses on clean architecture, BLoC-based state, and production-ready code across platforms.

---

## Live Demo

<!-- Add hosted web link when deployed -->
**Web:** _[Deploy and add link here]_

---

## Screenshots

<!-- Add screenshots: Splash, Settings, Session, Completion -->
| Splash | Settings | Session | Completion |
|--------|----------|---------|------------|
| _Screenshot_ | _Screenshot_ | _Screenshot_ | _Screenshot_ |

---

## Feature Overview

| Screen | Purpose |
|--------|--------|
| **Splash** | Branding and initial load; navigates to Settings. |
| **Breathing Settings** | Configure breath duration (3–6s), rounds (2 / 4 / 6 / 8), sound toggle, dark mode, and optional advanced per-phase timing. |
| **Breathing Session** | Guided run with expanding/shrinking bubble, phase labels, cycle counter, progress bar, pause/resume, and cancel. |
| **Session Completion** | Success Lottie and navigation back to Settings. |

**Settings:** Breath duration presets; round presets (Quick 2, Calm 4, Deep 6, Zen 8); sound on/off; advanced timing for Breathe In, Hold In, Breathe Out, Hold Out (each 3–6s).

**Session:** One cycle = Breathe In → Hold In → Breathe Out → Hold Out. Bubble animation and numeric counter reflect the current phase; optional audio plays on phase change. Session progress is not persisted (per assignment scope).

---

## Architecture

Feature-driven **clean architecture**: each feature owns its domain models, BLoC (events/states), and presentation (pages/widgets). Shared UI and app-wide concerns live in `core/` and `shared/`.

- **Core:** `PreferencesService` (SharedPreferences wrapper), constants, theme (colors, typography, light/dark), `ThemeCubit`.
- **Features:** Self-contained modules (splash, breathing_settings, breathing_session, session_completion) with clear boundaries.
- **State:** BLoC for session and settings; Cubit for theme. No global app state beyond injected services.

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

- **flutter_bloc** for all feature logic. Settings: `BreathingSettingsBloc` (load/save preferences, round/phase config). Session: **SessionBloc** as an explicit state machine—states include `preparing` (3s countdown), `active` (phase/cycle progress), `paused`, `completed`, `cancelled`. Events: `SessionStartRequested`, `SessionStarted`, `SessionTick`, `SessionPaused`, `SessionResumed`, `SessionClosed`. A single `SessionTick` handler drives countdown and phase transitions.
- **ThemeCubit** in core for light/dark; persisted via `PreferencesService`.

---

## Animation & Breathing Logic

- **Bubble:** `AnimationController` drives scale (and optional opacity) for breathe in (expand) and breathe out (shrink); phase changes from BLoC state trigger the correct animation. No physics—deterministic curves for predictable timing.
- **Phases:** Ordered list `breatheIn → holdIn → breatheOut → holdOut`. BLoC holds `currentPhase`, `secondsRemainingInPhase`, and `phaseDurations` (from settings or advanced timing). A 1-second tick (e.g. `Timer.periodic`) sends `SessionTick`; when remaining hits 0, the bloc advances phase or cycle and optionally completes the session.
- **Audio:** Phase-change sounds via `audioplayers`; bundled assets, no network. Respects “sound on/off” from settings.

---

## Local Persistence

**SharedPreferences** (via `PreferencesService`); on web this uses the standard Flutter web implementation (e.g. localStorage under the hood).

**Persisted:** `breath_duration`, `rounds`, `sound_enabled`, `dark_mode`, `advanced_timing_enabled`, and per-phase durations (`advanced_breathe_in`, `advanced_hold_in`, `advanced_breathe_out`, `advanced_hold_out`). All with sensible defaults in `PreferenceDefaults`; validation (e.g. 3–6s) applied on read/write.

**Not persisted:** Session progress or in-progress session state (assignment treated caching as optional).

---

## Engineering Decisions

- **BLoC over setState:** Session timing and phase transitions are easier to reason about and test as a single state machine with discrete events.
- **SharedPreferences:** Simple key-value persistence with good cross-platform support (including web) and no extra infra.
- **Feature folders:** Scales better than layer-first (e.g. “all blocs in one folder”); each feature can be understood in isolation.
- **Single tick stream:** One `SessionTick` per second keeps the state machine simple and avoids multiple timers or async drift.
- **Local assets only:** Lottie and audio are bundled; no runtime network for core flows.

---

## Trade-offs (Hackathon)

- **No session resume:** In-progress sessions are not saved; restarting the app starts fresh. Reduces scope and avoids edge cases (e.g. app killed mid-phase).
- **No backend:** All state is local; no sync, no accounts. Fits the assignment and demo scope.
- **Preset-only rounds:** Rounds are 2/4/6/8; no arbitrary number. Keeps UI and validation simple.
- **Web and mobile share one codebase:** Some layout tweaks for responsiveness; no separate web-only UX in this version.

---

## Dependencies (Summary)

| Package | Use |
|--------|-----|
| flutter_bloc, equatable | State management |
| lottie | Completion success animation |
| audioplayers | Phase change sounds |
| shared_preferences | Local persistence |
| flutter_svg | SVG assets |

---

*Built with Flutter.*
