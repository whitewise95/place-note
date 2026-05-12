# Dot Archive Refactor Design

## Goal

Refactor Place Note's current Flutter UI to match the approved dot-style preview and make the design direction durable for future AI-assisted development.

## Approved Direction

The approved preview is `design_previews/dot_design_preview.html`. The app should feel like a warm personal archive for screenshot/OCR text:

- Cream paper background
- Ivory cards
- Deep ink primary actions
- Caramel highlights
- Small square dot-grid details
- Sage local-save state
- Folder-first organization
- Long OCR/source content hidden behind focused views

## Architecture

The refactor stays within the existing Flutter structure. Shared visual decisions are centralized in `AppTheme`, `AppCard`, `DotMark`, and `StatusPill`. Screen-level widgets keep their current data flow and repository behavior while adopting the Dot Archive visual language.

## Scope

Included:

- Add persistent design documentation and AI guidance.
- Update Flutter theme tokens, button styles, inputs, dialogs, sheets, chips, and tab styles.
- Rework home, capture, OCR selection, history, extraction, and report screens to use Dot Archive colors and folder/archive language.
- Keep existing OCR, folder, image persistence, and local repository behavior unchanged.

Excluded:

- Backend work
- Account sync
- New OCR engine changes
- Full custom app icon generation

## Testing

Run `flutter analyze` and `flutter test`. If an emulator is available, run the app on Android after the refactor for manual inspection.
