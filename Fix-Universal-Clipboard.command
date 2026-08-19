#!/bin/zsh

# One-click repair for Universal Clipboard only.
# This script does not touch Continuity Camera, iCloud sign-in, networking, or Keychain.

PREF="$HOME/Library/Preferences/com.apple.coreservices.useractivityd.plist"

echo "=== Fix Universal Clipboard ==="
echo "[1/4] Reset ClipboardSharingEnabled..."
defaults delete "$PREF" ClipboardSharingEnabled >/dev/null 2>&1 || true
defaults write "$PREF" ClipboardSharingEnabled 1

echo "[2/4] Restart Universal Clipboard services..."
killall useractivityd 2>/dev/null || true
killall sharingd 2>/dev/null || true
killall pboard 2>/dev/null || true

echo "[3/4] Waiting 8 seconds for services to restart..."
sleep 8

echo "[4/4] Verifying..."
clipboard_value="$(defaults read "$PREF" ClipboardSharingEnabled 2>/dev/null || true)"
echo "ClipboardSharingEnabled = ${clipboard_value:-unknown}"

check_services() {
  local service
  local check_failed=0
  for service in useractivityd sharingd pboard; do
    if pgrep -x "$service" >/dev/null 2>&1; then
      echo "OK: $service"
    else
      echo "WARN: $service not found"
      check_failed=1
    fi
  done
  return "$check_failed"
}

check_services
failed=$?
if [[ "$failed" -ne 0 ]]; then
  echo "Services are still restarting; checking once more..."
  sleep 2
  check_services
  failed=$?
fi

if [[ "$clipboard_value" == "1" && "$failed" -eq 0 ]]; then
  message="Universal Clipboard repair complete. Test copy/paste now."
  echo ""
  echo "Done."
else
  message="Universal Clipboard repair ran with a verification warning."
  echo ""
  echo "Repair ran, but one or more checks need attention."
fi

osascript -e "display notification \"$message\" with title \"Universal Clipboard\"" >/dev/null 2>&1 || true
