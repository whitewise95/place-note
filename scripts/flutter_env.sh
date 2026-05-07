#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.gem/ruby/2.6.0/bin:$HOME/.codex-flutter/flutter/bin:$PATH"

export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"
