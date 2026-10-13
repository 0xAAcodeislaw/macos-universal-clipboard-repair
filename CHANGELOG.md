# Changelog

## [Unreleased]

- 记录已验证的 iPhone 端连续互通相机恢复方法：当状态为 `magic:0 / usable:0 / nearby:1 / wired:0` 时，关闭再开启手机端的“接力”和“连续互通相机”。

## [1.0.3] - 2026-08-20

- App 内置简体中文 / English 界面切换，并记住用户选择。
- 状态参数、修复按钮、执行日志和最终提示会随界面语言同步切换。
- README 中补充双语界面使用说明。
- GitHub Actions 支持手动按最新标签构建 App、DMG 和纯脚本包。
- Release 增加可拖入“应用程序”的 DMG 与 SHA-256 校验文件。

## [1.0.0] - 2026-08-19

- 首个公开版本。
- 支持 Universal Clipboard / Handoff 状态观察和修复。
- 支持 Continuity Camera 状态观察和独立修复。
- 提供 MIT License、中文简体 README 和 GitHub Actions 构建。
- 发布 macOS App 图标、版本化构建和 GitHub Release 下载包。
