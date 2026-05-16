#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/flutter_env.sh"

cd "$PROJECT_DIR"
flutter pub get
flutter run "${PLACE_NOTE_DART_DEFINES[@]}" -d macos
