# <img src="assets/icons/icon.png" height="32" alt="Home Orders Tracker icon"/> Home Orders Tracker

[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android)](android/)
[![Flutter](https://img.shields.io/badge/flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![State](https://img.shields.io/badge/state-Riverpod-00599C)](https://riverpod.dev)
[![Database](https://img.shields.io/badge/database-SQLite-003B57?logo=sqlite)](https://www.sqlite.org)
[![Languages](https://img.shields.io/badge/languages-Arabic%20%7C%20English-7952B3)](lib/l10n/)

Home Orders Tracker is a local-first Flutter application for tracking household supplies, estimating when items need replacement, and turning low-stock items into a shopping list.

The app is built for Android and keeps data on the device in SQLite. It focuses on a simple offline workflow for families and households that want to remember what is running low, what was restocked, and what should be bought next.

## Features

- Fast, simple inventory tracking for recurring home supplies.
- Add, edit, search, restock, correct, and delete inventory items.
- Expected duration, refresh date, remaining-days calculation, notes, and custom warning/urgent thresholds.
- Status grouping for safe, warning, and urgent items.
- Attention view for items that are close to running out or already urgent.
- Shopping-list entries generated from inventory items or added manually.
- Duplicate prevention for shopping-list entries linked to the same inventory item.
- Optional item prices, checked/unchecked purchase state, list search, swipe delete, bulk delete, undo, and total price display.
- Item history for create, update, restock, correction, and delete events.
- Revert inventory items to previous logged snapshots.
- Configurable history retention and manual log cleanup.
- Manual SQLite database backup and restore.
- Android daily notifications for warning and urgent items.
- Notification text localized in Arabic and English.
- First-run language selection and onboarding flow.
- Arabic and English UI with RTL/LTR support.
- Bundled Tajawal font family.

## Screenshots

<table border="0">
    <tr>
        <td>
            <img src="assets/screenshots/en/home_en.png" alt="English home screen" title="English home screen">
        </td>
        <td>
            <img src="assets/screenshots/en/expiry_en.png" alt="English expiry screen" title="English expiry screen">
        </td>
    </tr>
    <tr>
        <td>
            <img src="assets/screenshots/en/shopping_list_en.png" alt="English shopping list screen" title="English shopping list screen">
        </td>
        <td>
            <img src="assets/screenshots/en/edit_item_en.png" alt="English edit item screen" title="English edit item screen">
        </td>
    </tr>
</table>

## Tech Stack

Home Orders Tracker is written in Dart with Flutter and uses the following open-source packages:

- [Flutter](https://flutter.dev)
- [Dart](https://dart.dev)
- [Riverpod](https://riverpod.dev)
- [Flutter Bloc](https://bloclibrary.dev)
- [GoRouter](https://pub.dev/packages/go_router)
- [SQLite](https://www.sqlite.org) through [`sqflite`](https://pub.dev/packages/sqflite)
- [`shared_preferences`](https://pub.dev/packages/shared_preferences)
- [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications)
- [`timezone`](https://pub.dev/packages/timezone) and [`flutter_timezone`](https://pub.dev/packages/flutter_timezone)
- [`flutter_file_dialog`](https://pub.dev/packages/flutter_file_dialog)
- [`share_plus`](https://pub.dev/packages/share_plus)
- [`intl`](https://pub.dev/packages/intl) and [`jiffy`](https://pub.dev/packages/jiffy)
- [`uuid`](https://pub.dev/packages/uuid)
- [`restart_app`](https://pub.dev/packages/restart_app)
- [`app_settings`](https://pub.dev/packages/app_settings)
- [`introduction_screen`](https://pub.dev/packages/introduction_screen)

## Getting Started

### Requirements

- Flutter 3.x or a compatible stable Flutter SDK.
- Dart 3.x or the Dart SDK bundled with Flutter.
- Android SDK and a configured Android device or emulator.
- JDK 17 or newer for the Android Gradle build.

This repository currently contains Android platform files only. iOS, web, Windows, macOS, and Linux project folders are not present.

### Install Dependencies

```bash
flutter pub get
```

### Run

```bash
flutter run
```

### Build

```bash
flutter build apk --release
flutter build appbundle --release
```

Release signing reads `android/key.properties` when present. A template is available at [`android/key.properties.example`](android/key.properties.example).

## Development

Useful commands:

```bash
flutter analyze
dart format .
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter test
```

Notes:

- Riverpod generated files are checked in as `*.g.dart`.
- Localization output is configured by [`l10n.yaml`](l10n.yaml) and generated under [`lib/l10n/`](lib/l10n/).
- Launcher icon and splash configuration live in [`pubspec.yaml`](pubspec.yaml).
- There is no `test/` directory in the current repository, so `flutter test` exits with `Test directory "test" not found.` until tests are added.

## Configuration

- Package namespace and application ID: `com.home_orders_tracker.app`.
- Java source and target compatibility: 17.
- Release builds enable code minification and resource shrinking.
- Android permissions include notification posting, vibration, and boot-completed handling for scheduled notifications.
- Android backup is disabled in the manifest; use the app's manual backup and restore flow for database portability.

## Current Limitations

- Android is the only platform configured in this repository.
- There is no cloud sync, account system, or multi-device merge behavior.
- Backups are manual SQLite database exports.
- Automated tests are not currently included.
- Long-form user documentation is not currently included.

## Contributing

Contributions are welcome. Keep pull requests focused and include a clear description of the behavior changed.

Before opening a pull request:

- Run `flutter analyze`.
- Format Dart code with `dart format .`.
- Regenerate providers or localization files when their sources change.
- Add or update tests when introducing behavior that can be tested.
- Avoid unrelated refactors in feature or bug-fix pull requests.

Useful contribution areas include tests, screenshots, accessibility review, localization improvements, and Android notification reliability.

## Support

Open an issue in this repository when you find a bug, have a feature request, or want to discuss an improvement.

## License

The source code is released under the MIT License. See [LICENSE](LICENSE) for the full text.

## Trademark

The repository contains a [`TRADEMARK.md`](TRADEMARK.md) file, but it is currently empty. Until trademark guidance is added, the license covers source-code use only and does not provide separate written branding guidelines.
