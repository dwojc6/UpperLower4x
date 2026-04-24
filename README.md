# Upper Lower 4x

A SwiftUI iOS workout app that guides users through a 9‑week Upper/Lower program, tracks sessions and history, and lets users customize exercises, equipment, and weights.

## Highlights
- **9‑week program** with 4 training days per week.
- **Session tracking** with timer, rest timer, warm‑ups, and quick set adjustments.
- **Automatic weight targets** for %1RM lifts with rounding to the nearest 5.
- **Exercise customization**: add/remove exercises, reorder, create supersets, edit reps and notes.
- **Equipment system**: Barbell, Machine, Plate Loaded, Cable, Kettlebell, Dumbbell, Body Weight.
- **Barbell base weight** options for barbell exercises (45/25/15 lbs).
- **History & calendar** to review previous workouts.
- **Backup & restore** to JSON from Settings using the native iOS export/import flow.
- **CSV export** for completed lifts from History settings.
- **Progression**: accessory lifts can increase when targets are met.

## Screens/UX Overview
- **Program tab**: week selection, day cards, reset, and graduation flow.
- **Session tab**: active workout, warm‑ups, working sets, rest timer.
- **Exercises tab**: search all exercises, per‑exercise settings, hide/delete.
- **History tab**: calendar and session detail editing.

## Requirements
- Xcode 17+ (recommended)
- iOS 18+
- Swift 5.10+

## Getting Started
1. Open the project in Xcode:
   - `Upper Lower.xcodeproj`
2. Select a simulator or device.
3. Build & run.

## App Structure
```
Upper Lower/
├── Upper Lower.xcodeproj
└── Upper Lower/
    ├── ContentView.swift
    ├── WorkoutManager.swift
    ├── ProgramData.swift
    ├── Models.swift
    ├── ExerciseDatabase.swift
    ├── ExerciseDetailView.swift
    ├── WorkoutDetailView.swift
    ├── ExercisesView.swift
    ├── HistoryView.swift
    ├── SettingsView.swift
    └── ...
```

### Key Components
- **`ProgramData`**: Source of the 9‑week program structure and exercises.
- **`WorkoutManager`**: Session state, progression, overrides, and history.
- **`ExerciseDatabase`**: Saved weights, custom exercises, hidden exercises.
- **`ExerciseDetailView` / `WorkoutDetailView`**: Session and exercise UI.
- **`SettingsView`**: Backup/restore flow.

## Data & Persistence
The app persists state locally using **UserDefaults**, including:
- Current week and completed days
- Session state (for crash/resume)
- History (completed workouts)
- Exercise overrides (reps, equipment, barbell base weight)
- Saved weights and custom exercises
- Hidden exercises

### Backup / Restore
- Export from **Settings → Export Backup** (JSON file via the native iOS export picker).
- Import from **Settings → Import Backup**.
- Export completed lifts from **Settings → Export Completed Lifts** (CSV file).

## Program Logic
- **Weeks 1–9** are defined in `ProgramData`.
- **Progression**:
  - Completing all 4 days in a week advances the week.
  - Week 9 completion shows a graduation prompt.
- **%1RM weights** are calculated from user maxes and rounded to the nearest 5.

## Equipment System
Exercises can be labeled as:
- Barbell
- Machine
- Plate Loaded
- Cable
- Kettlebell
- Dumbbell
- Body Weight

When set to **Barbell**, a “Barbell Weight” option is available (45/25/15 lbs) and plate breakdown is shown.

## Customization
- **Reps and notes** can be edited per exercise.
- **Logged sets** can be cleared with a long press on the set circle.
- **Equipment** can be changed per exercise.
- **Exercises** can be added, removed, reordered, and grouped into supersets.

## Session UX
- Completing the final set waits briefly before returning to the workout exercise list.
- That short delay gives users time to adjust the last logged set if needed.

## Development Notes
- UI is SwiftUI with `@EnvironmentObject` shared state.
- `WorkoutManager` and `ExerciseDatabase` are the primary state containers.
- The app is designed to recover a session after backgrounding.

## Roadmap Ideas
- Cloud sync
- Unit/UI tests
- Dynamic program builder

## License
This project is private to its owner unless otherwise specified.
