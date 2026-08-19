#!/bin/zsh

echo "修复共享摄像头…"
killall ContinuityCaptureAgent 2>/dev/null || true
echo "等待 ContinuityCaptureAgent 重新启动…"
sleep 5
if pgrep -x ContinuityCaptureAgent >/dev/null 2>&1; then
  echo "ContinuityCaptureAgent 已恢复。"
else
  echo "ContinuityCaptureAgent 尚未出现，请稍等后刷新状态。"
fi
