# Dot Archive Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the approved dot-style visual direction to the existing Place Note Flutter app.

**Architecture:** Centralize tokens in `AppTheme`, keep shared surfaces in `AppCard`, `DotMark`, and `StatusPill`, then update each screen without changing repository behavior. Add `AGENTS.md` and design docs so future AI work references the same direction.

**Tech Stack:** Flutter, Material 3, SharedPreferences-backed local storage, ML Kit OCR.

---

### Task 1: Design Source Of Truth

**Files:**
- Create: `AGENTS.md`
- Create: `docs/design/dot_design_system.md`
- Create: `docs/superpowers/specs/2026-05-12-dot-refactor-design.md`

- [ ] Add product and visual rules to `AGENTS.md`.
- [ ] Document palette, component rules, and implementation notes in `docs/design/dot_design_system.md`.
- [ ] Save the approved design spec under `docs/superpowers/specs`.

### Task 2: Shared Theme And Components

**Files:**
- Modify: `lib/core/theme/app_theme.dart`
- Modify: `lib/core/widgets/app_card.dart`
- Create: `lib/core/widgets/dot_mark.dart`
- Modify: `lib/core/widgets/status_pill.dart`

- [ ] Replace teal/navy palette with Dot Archive tokens.
- [ ] Update Material theme for buttons, chips, segmented controls, app bars, sheets, dialogs, inputs, and progress indicators.
- [ ] Update card, dot mark, and status pill surfaces to match the dot-style preview.

### Task 3: Primary Screens

**Files:**
- Modify: `lib/features/home_screen.dart`
- Modify: `lib/features/capture/capture_screen.dart`
- Modify: `lib/features/address/address_candidate_screen.dart`
- Modify: `lib/features/history/history_screen.dart`
- Modify: `lib/features/report/report_screen.dart`
- Modify: `lib/features/extraction/extraction_screen.dart`

- [ ] Refresh home as a folder archive dashboard.
- [ ] Refresh capture and OCR selection surfaces.
- [ ] Refresh history/report item previews with image-aware archive styling.
- [ ] Keep the data flow and navigation behavior unchanged.

### Task 4: Verification

**Files:**
- Test: `test/widget_test.dart`
- Test: `test/address_candidate_extractor_test.dart`

- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Launch Android emulator/app when available for visual inspection.
