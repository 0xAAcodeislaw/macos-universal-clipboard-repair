# Universal Clipboard Repair — Script-only mode / 纯脚本模式

## 中文说明

这是一个不依赖 GUI App 的 macOS Universal Clipboard（通用剪贴板）/ Handoff（接力）修复脚本包。

### 使用方法

1. 解压此压缩包。
2. 双击 `Fix-Universal-Clipboard.command`。
3. 等待约 8 秒，让 `useractivityd`、`sharingd` 和 `pboard` 重启。
4. 在 Mac 与 iPhone 或 iPad 之间测试复制粘贴。

也可以在终端执行：

```sh
zsh ./Fix-Universal-Clipboard.command
```

脚本不使用 `sudo`，不退出 iCloud，不重置网络，不修改钥匙串，也不处理连续互通摄像头。它只重置 `ClipboardSharingEnabled`、重启三个 Universal Clipboard 相关服务、检查状态并显示 macOS 通知。

如果 macOS 拦截下载的脚本包，请先阅读主仓库 README 中的 Gatekeeper 放行步骤。

This package contains a standalone zsh script for repairing macOS Universal Clipboard / Handoff without opening the GUI app.

## Use

1. Unzip this archive.
2. Double-click `Fix-Universal-Clipboard.command`.
3. Wait about 8 seconds while `useractivityd`, `sharingd`, and `pboard` restart.
4. Test copy and paste between your Mac and iPhone or iPad.

You can also run it from Terminal:

```sh
zsh ./Fix-Universal-Clipboard.command
```

The script does not use `sudo`, sign out of iCloud, reset networking, modify Keychain data, or touch Continuity Camera. It only resets `ClipboardSharingEnabled`, restarts the three Universal Clipboard-related services, verifies their state, and shows a macOS notification.

If macOS blocks the downloaded script package, follow the Gatekeeper steps in the main repository README.

MIT License. See `LICENSE`.
