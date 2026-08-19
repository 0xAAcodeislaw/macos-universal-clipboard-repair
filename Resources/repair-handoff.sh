#!/bin/zsh

pref="$HOME/Library/Preferences/com.apple.coreservices.useractivityd.plist"
echo "修复 Handoff / Universal Clipboard…"
defaults delete "$pref" ClipboardSharingEnabled >/dev/null 2>&1 || true
defaults write "$pref" ClipboardSharingEnabled 1
killall useractivityd 2>/dev/null || true
killall sharingd 2>/dev/null || true
killall pboard 2>/dev/null || true
echo "等待 8 秒…"
sleep 8
echo "Handoff 修复动作完成。"
