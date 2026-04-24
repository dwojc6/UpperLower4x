# Changelog

All notable changes to this project are documented in this file.

## 2.9 - 2026-04-24

### Added
- Session set circles now support long press to clear logged reps immediately.
- Settings now shows a brief in-page confirmation after exports instead of a separate success alert.

### Changed
- Finishing the last set now waits briefly before returning to the workout exercise list so reps can be adjusted.
- Backup and completed-lifts exports now use the native iOS export picker for a more reliable save flow.

## 2.8 - 2026-04-14

### Added
- History settings can now export completed lifts to CSV, including reps and weight for each logged set.

## 2.7 - 2026-03-02

### Fixed
- History time-edit sheet now follows system appearance instead of forcing dark mode.
- Stabilized session UI bottom controls to prevent the rest timer and End Workout button from appearing in the middle of the screen.
- Reworked Save Workout prompt presentation so it is anchored above the End Workout button again.
- Removed white flash artifact and reduced animation lag when opening/closing the Save Workout prompt.

### Changed
- Improved bottom overlay layout behavior for session actions to be more consistent across device sizes and safe-area configurations.
