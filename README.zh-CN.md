# macOS 共享剪贴板修复工具

[English](README.md)

这是一个面向 macOS 的轻量级 Universal Clipboard（通用剪贴板）与 Handoff（接力）诊断、修复工具。

它不会替代苹果系统的共享剪贴板，也不会保存或同步剪贴板历史；它只观察相关系统状态，并执行有限、可逆的修复操作。

## 能做什么

- 查看 `ClipboardSharingEnabled` 是否开启
- 查看 `useractivityd`、`sharingd`、`pboard` 等相关服务是否运行
- 修复 Handoff / Universal Clipboard
- 查看并修复 Continuity Camera（连续互通相机）
- 显示 Wi‑Fi、蓝牙和系统代理状态
- 观察连续互通相机最近日志中的状态：

```text
magic:1
usable:1
nearby:1
wired:0
```

Handoff 和连续互通相机是两个独立的修复按钮，不会混在一起处理。

## 安全边界

本工具：

- 不需要 `sudo`
- 不退出 iCloud 或 Apple 账户
- 不重置网络
- 不修改钥匙串
- 不保存剪贴板内容
- 不主动发起网络请求

Handoff 修复只执行当前用户范围内的以下操作：

```sh
defaults delete ~/Library/Preferences/com.apple.coreservices.useractivityd.plist ClipboardSharingEnabled
defaults write ~/Library/Preferences/com.apple.coreservices.useractivityd.plist ClipboardSharingEnabled 1
killall useractivityd
killall sharingd
killall pboard
```

连续互通相机修复只重启 `ContinuityCaptureAgent`，并等待服务恢复。

## 使用科学插件时的提示

如果以上检查和修复都无法恢复，可以尝试切换科学插件的“全局/规则”模式，恢复之后大概率可以再切回全局模式。

不同科学插件的内部实现不同，因此本工具只显示系统代理状态，不能可靠读取每个插件内部的“全局/规则”模式。

## 本地编译

要求：

- macOS 13 或更高版本
- Apple Command Line Tools（包含 `clang`）

在仓库根目录执行：

```sh
./build-app.sh
open "build/Universal Clipboard Repair.app"
```

默认构建版本为 `1.0.0`。也可以指定版本号：

```sh
APP_VERSION=1.0.0 ./build-app.sh
```

生成的 App 未经过 Apple 签名。如果首次打开时被 Gatekeeper 拦截，请在 App 上右键，选择“打开”，然后再次选择“打开”。

## 使用 GitHub Actions 生成 App

1. 打开仓库的 **Actions** 页面。
2. 选择 **Build macOS App**。
3. 点击 **Run workflow**。
4. 填写版本号，例如 `1.0.0`。
5. 点击 **Run workflow**。
6. 在完成的任务页面下载 `Universal-Clipboard-Repair-v*-macOS` artifact。

推送版本标签（例如 `v1.0.0`）后，工作流会自动构建 App，并把压缩包附加到对应的 GitHub Release。

## 项目定位

本项目专注于苹果系统原生 Continuity 服务的观察和修复，不是第三方剪贴板同步软件，也不是系统清理或网络代理工具。

## License

本项目采用 MIT License，详见 [LICENSE](LICENSE)。
