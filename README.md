# SSH Config Manager (Flutter Desktop)

Desktop app for managing `~/.ssh/config`.

## Main Features

- Load and parse the system SSH config.
- Host list with key parameters (`HostName`, `User`, `Port`).
- Visual create/edit form for SSH hosts.
- Delete hosts.
- Drag-and-drop host reordering with automatic persistence.
- Auto-save to `~/.ssh/config` after add/edit/delete/reorder.
- Start `ssh <alias>` connection directly from the UI.
- Localization: `ru` and `en` (`en` is default when system language is not Russian).

## External Dependencies

Install outside this project:

- Flutter SDK (stable) with desktop support enabled.
- OpenSSH client (`ssh`) available in the system.

Platform toolchains:

- Linux: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`.
- Windows: Visual Studio 2022 with **Desktop development with C++** workload.
- macOS: Xcode + Command Line Tools.

## Commands

Setup:

```bash
flutter pub get
```

Run:

```bash
flutter run -d linux
flutter run -d windows
flutter run -d macos
```

Release builds:

```bash
flutter build linux --release
flutter build windows --release
flutter build macos
```

Notes:

- `flutter build windows --release` is supported only on Windows hosts.
- `flutter build macos` is supported only on macOS hosts (release build).
