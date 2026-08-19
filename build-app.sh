#!/bin/zsh

set -euo pipefail

ROOT_DIR="${0:A:h}"
APP_DIR="$ROOT_DIR/build/Universal Clipboard Repair.app"
CONTENTS_DIR="$APP_DIR/Contents"

rm -rf "$APP_DIR"
mkdir -p "$CONTENTS_DIR/MacOS" "$CONTENTS_DIR/Resources"

MACOSX_DEPLOYMENT_TARGET=13.0 clang -mmacosx-version-min=13.0 -fobjc-arc -O2 -framework Cocoa -framework QuartzCore \
  -o "$CONTENTS_DIR/MacOS/UniversalClipboardRepair" \
  "$ROOT_DIR/Sources/ContinuityRepair.m"

cp "$ROOT_DIR/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/Resources/status.sh" "$CONTENTS_DIR/Resources/status.sh"
cp "$ROOT_DIR/Resources/repair-handoff.sh" "$CONTENTS_DIR/Resources/repair-handoff.sh"
cp "$ROOT_DIR/Resources/repair-camera.sh" "$CONTENTS_DIR/Resources/repair-camera.sh"

chmod +x "$CONTENTS_DIR/MacOS/UniversalClipboardRepair"
chmod +x "$CONTENTS_DIR/Resources/"*.sh
plutil -lint "$CONTENTS_DIR/Info.plist"

echo "Built: $APP_DIR"
