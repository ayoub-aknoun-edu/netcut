# NetCut (Android) — Local VPN App Firewall (No Root)

NetCut is an **Android (no-root)** firewall that **cuts internet access (Wi-Fi + mobile data)** for selected apps using the Android **VPN API** (a “local VPN” approach).  
You can block apps individually or through **Groups** (e.g., “Social Media”) and toggle them quickly.

> ⚠️ Note: This app uses a local VPN tunnel to control which apps can send/receive network traffic. It does **not** require root.  
> Because it uses the VPN API, the system will show an “Always-on VPN / VPN active” indicator while blocking is enabled.

---

## Features

### Core

- ✅ **Block internet per app** (no root)
- ✅ **Groups**: create a group (e.g., “Social Media”), add apps, then block/allow them **all at once**
- ✅ **Local VPN firewall**: routes selected apps into the VPN and drops their packets
- ✅ **Persistent rules**: blocked apps and groups remain after restart
- ✅ **Dark/Light theme support** (custom palette + typography)

### UX / Reliability

- ✅ First-run **Setup flow** to grant required permissions
- ✅ Shortcuts to recommended system settings (battery “Unrestricted” / optimization)
- ✅ Search apps, filter “Blocked”

---

## How blocking works (high level)

NetCut starts an Android **VPN service**.  
When enabled, it builds a per-app rule list and configures the VPN so only selected apps are routed through the tunnel. The VPN service then **drops their traffic**, resulting in “no internet” for those apps, while other apps continue to work normally.

---

## Screens / Navigation

- **Setup**: guides you through permissions
- **Home**
  - **Apps tab**: list installed apps, block directly, add to groups
  - **Groups tab**: manage groups & group toggles
  - **Insights tab**: simple stats
- **Settings**: theme mode + permission status + battery settings shortcuts

---

## Permissions & System Requirements

### Android permissions (typical)

- **VPN permission**: required to run the local VPN.
- **Notifications permission (Android 13+)**: required to show the ongoing VPN foreground notification.
- **Battery optimization**: recommended to reduce VPN being killed by OEM power management.

> Some devices (especially Xiaomi/Realme/Oppo/Samsung variants) may aggressively stop background services. Setting Battery to **Unrestricted** can help.

---

## Limitations (important)

- Some apps may still appear to “partially work” offline due to cached content.
- OEM battery optimizers can kill the VPN service unless excluded.
- This approach is designed for **app-level** blocking. It is not a full-feature network sniffer/proxy.
- VPN-based firewalls can’t bypass OS restrictions (e.g., system components or privileged apps).
- “Always-on VPN” and “Block connections without VPN” options may affect behavior if enabled in system settings.

---

## Tech Stack

- **Flutter** UI
- **Riverpod** for state management
- **SharedPreferences** for persistence
- **Android Kotlin** for platform integration (VpnService, app list, battery settings intents)
- Neumorphic UI kit: **flutter_neumorphic_plus**
- Permission handling: **permission_handler**

---

## Project Structure

```text
lib/
  app.dart
  main.dart
  app_providers.dart

  core/platform/
    firewall_platform.dart        # MethodChannel bridge

  features/
    bootstrap/                    # decides Setup vs Home
    setup/                        # permission wizard
    home/                         # main shell + tabs
    apps/                         # apps list + search
    groups/                       # groups CRUD + group detail
    direct_blocks/                # direct app blocks persistence
    firewall/                     # computes final blocked list + starts VPN
    permissions/                  # permission checks + battery status
    insights/                     # metrics
    settings/                     # theme mode, status

  routing/
    neumorphic_page_route.dart    # route adapter

  theme/
    app_neumorphic_theme.dart     # neumorphic theme + TextTheme
    app_palette.dart
    app_typography.dart
    palette_ext.dart
````

---

## Build & Run (Development)

### Prerequisites

- Flutter SDK installed
- Android Studio (or Android SDK tools)
- A real Android device or emulator (VPN is best tested on a real device)

### Steps

```bash
flutter doctor
flutter pub get
flutter run
```

If you made Kotlin changes:

```bash
flutter clean
flutter pub get
flutter run
```

---

## Android Setup Notes

- Ensure your `AndroidManifest.xml` includes:

  - `POST_NOTIFICATIONS` (Android 13+)
  - required foreground service permissions (depending on Android version)
  - your VPN service declaration

- Confirm `minSdkVersion` in `android/app/build.gradle` matches your target devices.

---

## Troubleshooting

### “Blocking doesn’t work”

- Make sure **Firewall ON** is enabled in the app
- Confirm VPN permission is granted
- Confirm a **blocked list is non-empty** (at least one app blocked directly or via enabled group)
- Check system VPN settings:

  - If “Always-on VPN” or “Block connections without VPN” is enabled, behavior may differ
- Set Battery usage for NetCut to **Unrestricted**

### “VPN starts but some apps still load”

- Cached content can appear as if internet is working
- Some apps may use special OS APIs or background sync timing
- Try fully force-stop the target app and reopen

### “App list is empty / missing apps”

- Ensure the Android code uses launcher intents to list user-launchable apps
- Some system apps are not launchable and won’t appear (by design)

---

## Contributing

Contributions are welcome:

- bug reports
- UX improvements
- stability fixes across OEM devices
- docs

### Suggested contribution flow

1. Fork
2. Create a branch: `feat/<name>` or `fix/<name>`
3. Make changes
4. Add tests (when applicable)
5. Open PR

---

## Security & Privacy

- NetCut is designed to be **on-device**.
- The VPN service can be implemented without logging or exporting network traffic.
- If you add analytics/crash reporting, document it clearly.

> If you discover a security issue, please open a private report (or a GitHub Security Advisory) instead of a public issue.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
