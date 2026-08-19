#!/bin/bash

set -euo pipefail

APP_PATH="${1:?Usage: $0 /path/to/App.app}"
CERTIFICATE_PATH="${RUNNER_TEMP:-/tmp}/developer-id-application.p12"
KEYCHAIN_PATH="${RUNNER_TEMP:-/tmp}/continuity-repair-signing.keychain-db"
NOTARIZE_ZIP="${RUNNER_TEMP:-/tmp}/continuity-repair-notarization.zip"
KEYCHAIN_PASSWORD="${KEYCHAIN_PASSWORD:-$(openssl rand -hex 24)}"

cleanup() {
  security delete-keychain "$KEYCHAIN_PATH" >/dev/null 2>&1 || true
  rm -f "$CERTIFICATE_PATH" "$NOTARIZE_ZIP"
}
trap cleanup EXIT

: "${APPLE_CERTIFICATE_BASE64:?APPLE_CERTIFICATE_BASE64 is required}"
: "${APPLE_CERTIFICATE_PASSWORD:?APPLE_CERTIFICATE_PASSWORD is required}"
: "${APPLE_SIGNING_IDENTITY:?APPLE_SIGNING_IDENTITY is required}"
: "${APPLE_ID:?APPLE_ID is required}"
: "${APPLE_TEAM_ID:?APPLE_TEAM_ID is required}"
: "${APPLE_APP_PASSWORD:?APPLE_APP_PASSWORD is required}"

echo "$APPLE_CERTIFICATE_BASE64" | base64 --decode > "$CERTIFICATE_PATH"
security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security import "$CERTIFICATE_PATH" -P "$APPLE_CERTIFICATE_PASSWORD" -A -t cert -f pkcs12 "$KEYCHAIN_PATH"
security list-keychains -d user -s "$KEYCHAIN_PATH"
security default-keychain -s "$KEYCHAIN_PATH"
security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

codesign --force --deep --options runtime --timestamp \
  --sign "$APPLE_SIGNING_IDENTITY" \
  --keychain "$KEYCHAIN_PATH" \
  "$APP_PATH"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$NOTARIZE_ZIP"
xcrun notarytool submit "$NOTARIZE_ZIP" \
  --apple-id "$APPLE_ID" \
  --team-id "$APPLE_TEAM_ID" \
  --password "$APPLE_APP_PASSWORD" \
  --wait
xcrun stapler staple "$APP_PATH"
xcrun stapler validate "$APP_PATH"
spctl --assess --type execute --verbose=2 "$APP_PATH"

echo "Signed and notarized: $APP_PATH"
