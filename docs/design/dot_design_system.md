# Dot Archive Design System

## Intent

Dot Archive is the visual direction for Place Note: a simple, polished folder-based archive for text captured from screenshots and OCR. The app should feel warm, tidy, and practical, with dot-grid details acting as the main brand signal.

## Palette

| Token | Hex | Use |
| --- | --- | --- |
| `paper` | `#F6F2EA` | Scaffold background |
| `paperDeep` | `#E8DDCE` | Soft section backgrounds and dividers |
| `surface` | `#FFFCF5` | Cards, dialogs, sheets |
| `surfaceAlt` | `#F1E7D8` | Image placeholders and chip backgrounds |
| `brown` | `#2F2923` | Primary text, app bars, CTA buttons |
| `acorn` | `#6B5542` | Secondary text, icons, folder details |
| `caramel` | `#E08A32` | Highlights, selected chips, dot accents |
| `sage` | `#6D8D70` | Success/local-save state |
| `ink` | `#211D19` | Body text |
| `muted` | `#75675A` | Helper text |
| `line` | `#DCCBB7` | Borders |

## Components

### App Surface

Use a warm paper background. Large surfaces may include a subtle square dot grid, but it must be quiet and never reduce readability.

### Cards

Cards use ivory surfaces, 8px radius, a thin caramel-tinted border, and a soft brown shadow. Avoid nested cards. Use cards for folders, saved text items, source panels, and modal content.

### Folder Cards

Folder cards should feel slightly physical while still belonging to a dot-grid system. Use a small tab shape at the top-left, a folder icon block, or a compact dot mark. Folder rows should show:

- Folder name
- Saved item count
- Latest saved text preview
- Management menu

### Buttons

Primary actions use deep brown. Secondary actions use outlined ivory buttons with brown text. Destructive actions stay explicit and appear only in confirmation dialogs or menus.

### OCR Selection

OCR selection remains utility-first:

- Long OCR lists are scrollable.
- Selected chips use warm caramel/surface contrast.
- Mode controls use `SegmentedButton`.
- Raw OCR and source image live inside "원문 보기" with tabs for image and text.

## Typography

Keep typography compact and readable. Use high-weight titles for important labels, but avoid oversized hero typography inside tool screens.

## Implementation Notes

- Flutter theme tokens live in `lib/core/theme/app_theme.dart`.
- Shared card styling lives in `lib/core/widgets/app_card.dart`.
- Status chips live in `lib/core/widgets/status_pill.dart`.
- Dot mark lives in `lib/core/widgets/dot_mark.dart`.
- Preview reference lives in `design_previews/dot_design_preview.html`.
