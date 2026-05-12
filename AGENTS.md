# Place Note AI Development Guide

## Product Direction

Place Note is a local-first mobile app for collecting text from screenshots, copied content, and OCR. The core mental model is "small notes stored in warm folders", not map search or address analysis.

## Dot Visual System

Use the Dot Archive design direction for all new UI work:

- Warm paper surfaces: cream app background, ivory cards, soft caramel dividers.
- Dot-first accents: small square dot grids, pixel-like marks, deep ink primary actions, caramel highlights, sage green success/secondary states.
- Folder-first layout: cards may use a small folder-tab detail when representing folders or collections.
- Calm utility: the app should feel like a neat personal archive, not a marketing landing page.
- Keep corners restrained: 8px for most UI, 10-14px only for larger panels.
- Prefer icon + compact text controls. Avoid decorative gradients, glassmorphism, neon colors, mascot-like illustration, or overly cute styling.

## UX Rules

- Home starts from folders and recent saved text.
- Saving flow should keep source image and OCR text available, but hide long raw OCR text behind "원문 보기".
- OCR selection areas must scroll when content is long.
- Saved entries should show a short text preview, date, local-save status, and image thumbnail when available.

## Source Of Truth

Before changing UI, read:

- `docs/design/dot_design_system.md`
- `design_previews/dot_design_preview.html`
- `lib/core/theme/app_theme.dart`

Keep those files aligned when the design system changes.
