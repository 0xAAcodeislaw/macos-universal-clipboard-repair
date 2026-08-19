# macOS Universal Clipboard Repair

[简体中文](README.zh-CN.md)

<p align="center">
  <img src="Resources/AppIcon.png" width="128" alt="Universal Clipboard Repair icon">
</p>

<p align="center">
  <a href="https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair/releases/latest"><img src="https://img.shields.io/github/v/release/0xAAcodeislaw/macos-universal-clipboard-repair?style=flat-square" alt="Latest release"></a>
  <a href="https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair/releases"><img src="https://img.shields.io/github/downloads/0xAAcodeislaw/macos-universal-clipboard-repair/total?style=flat-square&label=downloads" alt="Downloads"></a>
  <a href="https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair/actions/workflows/build-app.yml"><img src="https://img.shields.io/github/actions/workflow/status/0xAAcodeislaw/macos-universal-clipboard-repair/build-app.yml?branch=main&style=flat-square" alt="Build status"></a>
  <a href="https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair/stargazers"><img src="https://img.shields.io/github/stars/0xAAcodeislaw/macos-universal-clipboard-repair?style=flat-square" alt="GitHub stars"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/0xAAcodeislaw/macos-universal-clipboard-repair?style=flat-square" alt="MIT License"></a>
</p>

<p align="center"><a href="https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair/releases/latest">Download the latest macOS App</a></p>

macOS Universal Clipboard Repair is a small, local-only diagnostic and repair app for Apple Continuity features:

- Universal Clipboard / Handoff
- Continuity Camera
- Wi‑Fi and Bluetooth readiness
- System proxy status
- Recent Continuity Camera state: `magic`, `usable`, `nearby`, `wired`

It is designed for the narrow failure mode where macOS discovers another Apple device but a Continuity service is stuck. It does not replace Universal Clipboard, store clipboard history, or synchronize clipboard data itself.

> Ready to use: no installer and no `sudo` required. Download a Release archive, unzip it, and open the app. The app bundle is about **2.3 MB**, making it a few-megabyte lightweight utility. Actual idle RSS includes macOS/AppKit frameworks; it measured about **91 MB RSS** on the development Mac and varies by macOS version.

The `downloads` badge above shows the cumulative download count for all GitHub Release assets. The [Releases](https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair/releases) page also shows the count for each version archive.

The bottom of the app window shows the current version, a link to the [GitHub repository](https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair), and a **Check for updates** entry. Clicking it opens the GitHub Releases page; the app does not continuously access system data or make background network requests.

## Typical symptoms and search terms

This project is intended for symptoms such as:

- Mac, iPhone, or iPad cannot copy and paste across devices
- Universal Clipboard, shared clipboard, or Handoff / 接力 stops working while devices are still discoverable
- `ClipboardSharingEnabled` is `0`, disabled, or missing
- `useractivityd`, `sharingd`, or `pboard` is not running as expected
- Continuity Camera / shared camera is unavailable, or the camera works while Universal Clipboard does not
- `ContinuityCaptureAgent` is missing, repeatedly exits, or reports `magic`, `usable`, `nearby`, or `wired` as `UNKNOWN`
- A proxy or scientific-networking plugin makes Continuity recover after switching between Global and Rule mode

Search terms include: `Universal Clipboard not working`, `Handoff not working`, `shared clipboard Mac iPhone`, `ClipboardSharingEnabled 0`, `useractivityd`, `sharingd`, `pboard`, `Continuity Camera not working`, `ContinuityCaptureAgent`, `macOS clipboard sharing`, `通用剪贴板失效`, `接力失效`, and `共享摄像头无法使用`.

## Safety boundary

The app:

- uses no `sudo`;
- does not sign out of iCloud or Apple Account;
- does not reset networking;
- does not modify Keychain data;
- does not make network requests;
- keeps Handoff and Continuity Camera repairs as separate actions.

The Handoff repair uses the following user-level operations:

```sh
defaults delete ~/Library/Preferences/com.apple.coreservices.useractivityd.plist ClipboardSharingEnabled
defaults write ~/Library/Preferences/com.apple.coreservices.useractivityd.plist ClipboardSharingEnabled 1
killall useractivityd
killall sharingd
killall pboard
```

The camera repair only restarts `ContinuityCaptureAgent` and waits for it to return.

## Proxy tools

As a last resort, if the steps above do not repair Continuity, try switching the scientific-networking/proxy plugin between **Global** and **Rule** mode. Once Continuity recovers, it will usually be possible to switch back to Global mode. The app intentionally uses generic wording and only reads system proxy state; it cannot reliably determine the internal mode of every proxy plugin.

## Camera state

The camera panel reads recent `ContinuityCaptureAgent` logs. The expected wireless-ready state is:

```text
magic:1
usable:1
nearby:1
wired:0
```

If there is no matching log entry in the recent window, the app shows `UNKNOWN` instead of presenting stale data as current.

## Build

Requirements:

- macOS 13 or newer
- Apple Command Line Tools (`clang`)

Build the app locally:

```sh
./build-app.sh
open "build/Universal Clipboard Repair.app"
```

## First launch and Gatekeeper override for end users

When signing credentials are not configured, this repository still produces a transparent, testable unsigned app. If macOS says it cannot verify the developer, blocks the app, or suggests moving it to the Trash after download, follow these steps:

1. Download the archive from a GitHub Release and unzip it. Do not run the app from the archive preview window.
2. Double-click the app once so macOS records the blocked launch.
3. Open **System Settings → Privacy & Security**, scroll to **Security**, click **Open Anyway**, and confirm **Open**. This button normally appears for a short time after you try to launch the app.
4. Alternatively, right-click the app, choose **Open**, and confirm **Open** again.
5. If **Open Anyway** is still not available, and you trust the download source, you can remove the quarantine flag for this file in Terminal. Adjust the path if the app is stored elsewhere:

   ```sh
   xattr -dr com.apple.quarantine "$HOME/Downloads/Universal Clipboard Repair.app"
   ```

   If the app has a different name or location, replace the final path with the actual path. This only removes the downloaded-file quarantine flag; it does not disable Gatekeeper for the whole Mac.

After one successful approval, macOS will normally allow the same app to open by double-clicking it. Only override Gatekeeper for a copy whose source you trust and whose contents have not been altered.

For a true double-click launch without any user-side override, the repository must publish a build signed with a Developer ID Application certificate and notarized by Apple. The workflow includes an opt-in signing, notarization, and stapling path; if it is not enabled, it does not pretend that the artifact is signed.

## GitHub Actions

To build a downloadable app from GitHub:

1. Open the **Actions** tab.
2. Select **Build macOS App**.
3. Enter a version number, such as `1.0.0`.
4. Choose **Run workflow**.
5. Download the versioned `Universal-Clipboard-Repair-v*-macOS` artifact from the completed run.

Pushing a version tag such as `v1.0.0` runs the same build and attaches the App archive to a GitHub Release automatically.

### Script-only mode

Every GitHub Actions build also creates a standalone script archive:

```text
Universal-Clipboard-Repair-Script-v*-macOS.zip
```

It does not require opening the GUI app. Unzip it and double-click `Fix-Universal-Clipboard.command`, or run it from Terminal:

```sh
zsh ./Fix-Universal-Clipboard.command
```

The script-only version handles Universal Clipboard / Handoff only: it resets `ClipboardSharingEnabled`, restarts `useractivityd`, `sharingd`, and `pboard`, waits about 8 seconds, and checks their state. It does not use `sudo`, sign out of iCloud, reset networking, modify Keychain data, or touch Continuity Camera.

The script archive is uploaded alongside the App archive as both a GitHub Actions artifact and a GitHub Release asset.

### Enabling signing and notarization

Maintainers can add these GitHub Actions Secrets in the repository settings:

- `SIGNING_ENABLED`: set to `true` to enable the signing path
- `APPLE_CERTIFICATE_BASE64`: Base64 content of the Developer ID Application `.p12` certificate
- `APPLE_CERTIFICATE_PASSWORD`: password for the `.p12` file
- `APPLE_SIGNING_IDENTITY`: certificate name, such as `Developer ID Application: Example (TEAMID)`
- `APPLE_ID`: Apple account used for notarization
- `APPLE_TEAM_ID`: Apple Developer Team ID
- `APPLE_APP_PASSWORD`: app-specific password for that Apple account

Keep certificates, passwords, and private keys in GitHub Secrets only. Never commit them or paste them into an Issue, README, or chat.

## Development note

The code, interface, build scripts, and documentation for this project were completed with **OpenAI Codex** collaboration, with the repository kept public for review, reproducible builds, and independent compilation. The repair actions remain limited to macOS-native operations described in this README.

## Similar projects and scope

This project is intentionally different from clipboard synchronization apps. Public projects found during the initial search include:

- [A Universal Clipboard repair gist](https://gist.github.com/wehrwein1/389c2adaca3845a81b7fbb8427276400), which documents the `ClipboardSharingEnabled` reset but is not a full diagnostic app.
- [Machete](https://github.com/rayone/machete), a broad macOS tuning/debloating toolkit that includes Continuity-related service controls; it is much broader and more invasive than this project.
- [UniClipboard](https://github.com/UniClipboard/UniClipboard) and [Uniclip](https://github.com/quackduck/uniclip), which implement alternative clipboard synchronization rather than repairing Apple's native Continuity stack.

The goal here is a small, transparent, reversible repair and observation tool for Apple's native services.

## Contributing and changelog

- [Contributing guide](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)
- [Report a bug](.github/ISSUE_TEMPLATE/bug-report.md)

## License

MIT. See [LICENSE](LICENSE).
