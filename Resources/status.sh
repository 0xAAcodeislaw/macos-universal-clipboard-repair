#!/bin/zsh

pref="$HOME/Library/Preferences/com.apple.coreservices.useractivityd.plist"
clipboard="$(defaults read "$pref" ClipboardSharingEnabled 2>/dev/null || true)"
service_state() { pgrep -x "$1" >/dev/null 2>&1 && echo ON || echo OFF; }

wifi_device="$(networksetup -listallhardwareports 2>/dev/null | awk '/Hardware Port: Wi-Fi/{getline; sub(/^Device: /, ""); print; exit}')"
wifi="UNKNOWN"
if [[ -n "$wifi_device" ]]; then
  wifi="$(networksetup -getairportpower "$wifi_device" 2>/dev/null | awk -F': ' '{print $2; exit}')"
fi
[[ "$wifi" == "On" ]] && wifi="ON"
[[ "$wifi" == "Off" ]] && wifi="OFF"

bluetooth="$(system_profiler SPBluetoothDataType 2>/dev/null | awk -F': ' '/State:/{print $2; exit}')"
[[ "$bluetooth" == "On" ]] && bluetooth="ON"
[[ "$bluetooth" == "Off" ]] && bluetooth="OFF"

proxy="$(scutil --proxy 2>/dev/null | awk -F' : ' '/HTTPEnable|HTTPSEnable|SOCKSEnable|ProxyAutoConfigEnable/{if ($2=="1") found=1} END{print found ? "ON" : "OFF"}')"
magic_line="$(log show --last 2m --style compact --predicate 'process == "ContinuityCaptureAgent" AND eventMessage CONTAINS[c] "magic:"' 2>/dev/null | grep -E 'magic:[01].*usable:[01].*nearby:[01].*wired:[01]' | tail -1)"
magic="$(printf '%s\n' "$magic_line" | sed -n 's/.*\(magic:[01].*usable:[01].*nearby:[01].*wired:[01]\).*/\1/p')"
[[ -z "$magic" ]] && magic="UNKNOWN"
camera_magic="$(printf '%s\n' "$magic_line" | sed -n 's/.*magic:\([01]\).*/\1/p')"
camera_usable="$(printf '%s\n' "$magic_line" | sed -n 's/.*usable:\([01]\).*/\1/p')"
camera_nearby="$(printf '%s\n' "$magic_line" | sed -n 's/.*nearby:\([01]\).*/\1/p')"
camera_wired="$(printf '%s\n' "$magic_line" | sed -n 's/.*wired:\([01]\).*/\1/p')"
[[ -z "$camera_magic" ]] && camera_magic="UNKNOWN"
[[ -z "$camera_usable" ]] && camera_usable="UNKNOWN"
[[ -z "$camera_nearby" ]] && camera_nearby="UNKNOWN"
[[ -z "$camera_wired" ]] && camera_wired="UNKNOWN"

printf 'handoff=%s\n' "${clipboard:-UNKNOWN}"
printf 'useractivityd=%s\n' "$(service_state useractivityd)"
printf 'sharingd=%s\n' "$(service_state sharingd)"
printf 'pboard=%s\n' "$(service_state pboard)"
printf 'cameraAgent=%s\n' "$(service_state ContinuityCaptureAgent)"
printf 'wifi=%s\n' "${wifi:-UNKNOWN}"
printf 'bluetooth=%s\n' "${bluetooth:-UNKNOWN}"
printf 'proxy=%s\n' "${proxy:-UNKNOWN}"
printf 'magic=%s\n' "$magic"
printf 'cameraMagic=%s\n' "$camera_magic"
printf 'cameraUsable=%s\n' "$camera_usable"
printf 'cameraNearby=%s\n' "$camera_nearby"
printf 'cameraWired=%s\n' "$camera_wired"
