#!/bin/zsh

if [[ "${CONTINUITY_REPAIR_LANG:-zh}" == "en" ]]; then
  echo "Repairing Continuity Camera…"
else
  echo "修复共享摄像头…"
fi
killall ContinuityCaptureAgent 2>/dev/null || true
if [[ "${CONTINUITY_REPAIR_LANG:-zh}" == "en" ]]; then
  echo "Waiting for ContinuityCaptureAgent to restart…"
else
  echo "等待 ContinuityCaptureAgent 重新启动…"
fi
sleep 5
if pgrep -x ContinuityCaptureAgent >/dev/null 2>&1; then
  if [[ "${CONTINUITY_REPAIR_LANG:-zh}" == "en" ]]; then
    echo "ContinuityCaptureAgent has recovered."
  else
    echo "ContinuityCaptureAgent 已恢复。"
  fi
else
  if [[ "${CONTINUITY_REPAIR_LANG:-zh}" == "en" ]]; then
    echo "ContinuityCaptureAgent is not running yet. Wait a moment, then refresh status."
  else
    echo "ContinuityCaptureAgent 尚未出现，请稍等后刷新状态。"
  fi
fi
