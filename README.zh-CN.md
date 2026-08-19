# macOS 共享剪贴板修复工具

[English](README.md)

<p align="center">
  <img src="Resources/AppIcon.png" width="128" alt="Universal Clipboard Repair 图标">
</p>

<p align="center">
  <a href="https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair/releases/latest"><img src="https://img.shields.io/github/v/release/0xAAcodeislaw/macos-universal-clipboard-repair?style=flat-square" alt="最新版本"></a>
  <a href="https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair/actions/workflows/build-app.yml"><img src="https://img.shields.io/github/actions/workflow/status/0xAAcodeislaw/macos-universal-clipboard-repair/build-app.yml?branch=main&style=flat-square" alt="构建状态"></a>
  <a href="https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair/stargazers"><img src="https://img.shields.io/github/stars/0xAAcodeislaw/macos-universal-clipboard-repair?style=flat-square" alt="GitHub Stars"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/0xAAcodeislaw/macos-universal-clipboard-repair?style=flat-square" alt="MIT License"></a>
</p>

<p align="center"><a href="https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair/releases/latest">下载最新 macOS App</a></p>

这是一个面向 macOS 的轻量级 Universal Clipboard（通用剪贴板）与 Handoff（接力）诊断、修复工具。

它不会替代苹果系统的共享剪贴板，也不会保存或同步剪贴板历史；它只观察相关系统状态，并执行有限、可逆的修复操作。

## 故障现象（搜索关键词）

如果你遇到下面这些现象，本项目可能适合用来观察和修复。这里保留了常见中文、英文、系统服务名和参数名，方便通过 GitHub 或搜索引擎定位：

### 通用剪贴板与接力

- Mac、iPhone、iPad 之间无法复制粘贴
- 通用剪贴板失效、共享剪贴板不工作、跨设备复制粘贴失败
- Handoff（接力）失效，但设备仍然可以互相发现
- 复制后另一台设备没有出现接力提示，或者粘贴不到刚刚复制的内容
- `ClipboardSharingEnabled` 读取为 `0`、关闭或缺失
- `useractivityd`（接力服务）、`sharingd`（共享服务）或 `pboard`（本机剪贴板）状态异常

常见英文关键词：`Universal Clipboard not working`、`Handoff not working`、`shared clipboard between Mac and iPhone`、`clipboard sharing disabled`、`ClipboardSharingEnabled 0`、`useractivityd`、`sharingd`、`pboard`。

### 连续互通相机与共享摄像头

- Continuity Camera（连续互通相机、共享摄像头）无法使用
- 共享摄像头正常，但 Universal Clipboard / Handoff 仍然失效
- `magic`、`usable`、`nearby`、`wired` 状态异常或显示 `UNKNOWN`
- `ContinuityCaptureAgent` 没有运行、反复退出或状态不更新

常见英文关键词：`Continuity Camera not working`、`iPhone camera Mac`、`ContinuityCaptureAgent`、`magic usable nearby wired`。

### 代理与科学插件相关现象

- 翻墙工具、代理或科学插件运行时，Universal Clipboard / Handoff 偶尔失效
- 切换科学插件的“全局/规则”模式后，接力或共享剪贴板恢复
- 关闭代理后恢复，但重新开启后故障再次出现

本项目不会绑定某个具体代理软件名称；不同工具统一按“科学插件 / 系统代理”观察。

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

## 参与项目

- [贡献指南](CONTRIBUTING.md)
- [更新日志](CHANGELOG.md)
- [报告故障](.github/ISSUE_TEMPLATE/bug-report.md)

## License

本项目采用 MIT License，详见 [LICENSE](LICENSE)。
