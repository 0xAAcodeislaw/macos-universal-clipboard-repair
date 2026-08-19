# macOS Universal Clipboard Repair

macOS Universal Clipboard Repair is a small, local-only diagnostic and repair app for Apple Continuity features:

- Universal Clipboard / Handoff
- Continuity Camera
- Wi‑Fi and Bluetooth readiness
- System proxy status
- Recent Continuity Camera state: `magic`, `usable`, `nearby`, `wired`

It is designed for the narrow failure mode where macOS discovers another Apple device but a Continuity service is stuck. It does not replace Universal Clipboard, store clipboard history, or synchronize clipboard data itself.

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

The resulting app is unsigned. If Gatekeeper blocks the first launch, right-click the app, choose **Open**, then choose **Open** again.

## GitHub Actions

To build a downloadable app from GitHub:

1. Open the **Actions** tab.
2. Select **Build macOS App**.
3. Choose **Run workflow**.
4. Download the `Universal-Clipboard-Repair-macOS` artifact from the completed run.

## Similar projects and scope

This project is intentionally different from clipboard synchronization apps. Public projects found during the initial search include:

- [A Universal Clipboard repair gist](https://gist.github.com/wehrwein1/389c2adaca3845a81b7fbb8427276400), which documents the `ClipboardSharingEnabled` reset but is not a full diagnostic app.
- [Machete](https://github.com/rayone/machete), a broad macOS tuning/debloating toolkit that includes Continuity-related service controls; it is much broader and more invasive than this project.
- [UniClipboard](https://github.com/UniClipboard/UniClipboard) and [Uniclip](https://github.com/quackduck/uniclip), which implement alternative clipboard synchronization rather than repairing Apple's native Continuity stack.

The goal here is a small, transparent, reversible repair and observation tool for Apple's native services.

## License

MIT. See [LICENSE](LICENSE).
