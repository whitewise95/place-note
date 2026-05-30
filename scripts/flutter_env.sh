#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  PLACE_NOTE_ENV_SOURCE="${BASH_SOURCE[0]}"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  eval 'PLACE_NOTE_ENV_SOURCE="${(%):-%x}"'
else
  PLACE_NOTE_ENV_SOURCE="$0"
fi

SCRIPT_DIR="$(cd "$(dirname "$PLACE_NOTE_ENV_SOURCE")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

export PATH="$HOME/.gem/ruby/2.6.0/bin:$HOME/.codex-flutter/flutter/bin:$PATH"

export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"

PLACE_NOTE_DART_DEFINES=()

_place_note_config_value() {
  local file="$1"
  local key="$2"

  if [[ ! -f "$file" ]]; then
    return 0
  fi

  sed -n -E "s/^[[:space:]]*${key}[[:space:]]*:[[:space:]]*[\"']?([^\"'#]+)[\"']?.*$/\\1/p" "$file" \
    | head -n 1 \
    | xargs
}

_place_note_add_dart_define() {
  local key="$1"
  local value="$2"

  if [[ -n "$value" && "$value" != \{*\} ]]; then
    PLACE_NOTE_DART_DEFINES+=("--dart-define=${key}=${value}")
  fi
}

PLACE_NOTE_CONFIG_FILE="${PLACE_NOTE_CONFIG_FILE:-$PROJECT_DIR/config/app_config.local.yml}"
KAKAO_REST_API_KEY_VALUE="${KAKAO_REST_API_KEY:-}"
PLACE_NOTE_WEB_APP_URL_VALUE="${PLACE_NOTE_WEB_APP_URL:-}"

if [[ -z "$KAKAO_REST_API_KEY_VALUE" ]]; then
  KAKAO_REST_API_KEY_VALUE="$(_place_note_config_value "$PLACE_NOTE_CONFIG_FILE" "kakao_rest_api_key")"
fi

if [[ -z "$PLACE_NOTE_WEB_APP_URL_VALUE" ]]; then
  PLACE_NOTE_WEB_APP_URL_VALUE="$(_place_note_config_value "$PLACE_NOTE_CONFIG_FILE" "place_note_web_app_url")"
fi

_place_note_add_dart_define "KAKAO_REST_API_KEY" "$KAKAO_REST_API_KEY_VALUE"
_place_note_add_dart_define "PLACE_NOTE_WEB_APP_URL" "$PLACE_NOTE_WEB_APP_URL_VALUE"
