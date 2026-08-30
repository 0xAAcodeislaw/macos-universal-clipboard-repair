#!/bin/zsh

set -euo pipefail

if (( $# < 2 || $# > 3 )); then
  echo "Usage: $0 <app-path> <output-dmg> [volume-name]" >&2
  exit 64
fi

if [[ "$(uname -s)" != "Darwin" ]] || ! command -v hdiutil >/dev/null 2>&1; then
  echo "Error: DMG packaging requires macOS and hdiutil." >&2
  exit 69
fi

app_path="${1:A}"
output_dmg="${2:A}"
volume_name="${3:-Universal Clipboard Repair}"

if [[ ! -d "$app_path" || "${app_path:e}" != "app" ]]; then
  echo "Error: app bundle not found: $app_path" >&2
  exit 66
fi

output_dir="${output_dmg:h}"
stage_dir="$(mktemp -d "${TMPDIR:-/tmp}/universal-clipboard-repair-dmg.XXXXXX")"

cleanup() {
  rm -rf "$stage_dir"
}
trap cleanup EXIT INT TERM

mkdir -p "$output_dir"
ditto "$app_path" "$stage_dir/${app_path:t}"
ln -s /Applications "$stage_dir/Applications"

script_dir="${0:A:h}"
repository_root="${script_dir:h}"
if [[ -f "$repository_root/LICENSE" ]]; then
  cp "$repository_root/LICENSE" "$stage_dir/LICENSE"
fi

hdiutil create \
  -volname "$volume_name" \
  -srcfolder "$stage_dir" \
  -ov \
  -format UDZO \
  "$output_dmg"

hdiutil verify "$output_dmg"
echo "Created and verified: $output_dmg"
