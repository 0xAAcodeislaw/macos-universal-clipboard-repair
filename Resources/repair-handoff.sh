#!/bin/zsh

pref="$HOME/Library/Preferences/com.apple.coreservices.useractivityd.plist"
if [[ "${CONTINUITY_REPAIR_LANG:-zh}" == "en" ]]; then
  echo "Repairing Handoff / Universal Clipboard…"
else
  echo "修复 Handoff / Universal Clipboard…"
fi
defaults delete "$pref" ClipboardSharingEnabled >/dev/null 2>&1 || true
defaults write "$pref" ClipboardSharingEnabled 1
killall useractivityd 2>/dev/null || true
killall sharingd 2>/dev/null || true
killall pboard 2>/dev/null || true
if [[ "${CONTINUITY_REPAIR_LANG:-zh}" == "en" ]]; then
  echo "Waiting 8 seconds…"
else
  echo "等待 8 秒…"
fi
sleep 8
if [[ "${CONTINUITY_REPAIR_LANG:-zh}" == "en" ]]; then
  echo "Handoff repair action completed."
else
  echo "Handoff 修复动作完成。"
fi
