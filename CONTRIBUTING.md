# Contributing

感谢你帮助改进 Universal Clipboard Repair。

## 提交故障报告

请尽量提供：

- macOS 版本和 Mac 型号
- 对端设备类型和系统版本
- Universal Clipboard、Handoff 或 Continuity Camera 的具体故障现象
- App 状态面板中的相关参数
- 是否使用系统代理或科学插件，以及切换“全局/规则”后是否有变化
- 可复现步骤和相关截图

请不要在 Issue 中粘贴剪贴板内容、Apple 账户信息、设备序列号或完整私人日志。

## 本地验证

```sh
./build-app.sh
open "build/Universal Clipboard Repair.app"
```

请保持项目的安全边界：不加入 `sudo`、iCloud 退出、网络重置、钥匙串修改或剪贴板内容收集。

## 提交代码

提交前请确认：

- 修改范围只服务于 Universal Clipboard、Handoff、Continuity Camera 诊断或修复
- 构建脚本可以在 macOS 13 或更新版本运行
- README、更新日志和用户可见行为保持同步
- 不包含个人路径、个人邮箱、访问令牌或私有日志
