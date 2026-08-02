# Home Orders Tracker

Home Orders Tracker is a local-first Flutter application for tracking household supplies, estimating when items need replacement, and turning low-stock items into a shopping list. It is built for Android and stores its data on the device in SQLite.

[![License](https://img.shields.io/badge/license-Unlicense-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android)](android/)
[![Flutter](https://img.shields.io/badge/flutter-3.44.8-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-3.12.2-0175C2?logo=dart)](https://dart.dev)
[![State Management](https://img.shields.io/badge/state-Riverpod-00599C)](https://riverpod.dev)
[![Database](https://img.shields.io/badge/database-SQLite-003B57?logo=sqlite)](https://www.sqlite.org)

## Overview

The app helps a household keep track of recurring consumable items such as food or supplies. Each inventory item has an expected duration, a refresh date, warning and urgent thresholds, optional notes, and notification settings. The app uses that information to calculate remaining days, group items by urgency, and notify the user when attention is needed.

Home Orders Tracker does not include accounts, cloud sync, or server integration. Application data is persisted locally in a private SQLite database, with manual backup and restore available from the settings screen.

## Why This Project?

Household stock is often managed from memory, which makes it easy to miss essentials, duplicate purchases, or lose track of what changed. This project provides a small offline workflow for:

- Recording how long each item usually lasts.
- Seeing which items are safe, close to running out, or urgent.
- Creating shopping-list entries from inventory items that need attention.
- Keeping a change history for inventory edits, restocks, corrections, and deletions.
- Exporting and restoring the local database when moving or protecting data.

## Features

### Inventory Tracking

- Add, edit, search, and delete household inventory items.
- Store item name, quantity description, expected days, refresh date, notes, notification preference, and warning/urgent thresholds.
- Calculate expected expiry dates and remaining days from the latest refresh date.
- Classify items as safe, warning, or urgent based on configurable thresholds.
- Restock an existing item and immediately reset its tracking date.
- Correct stock status when real-world stock differs from the app estimate.
- Share an inventory report with optional status filtering, remaining days, and renewal dates.

### Expiry And Attention View

- Show only warning and urgent inventory items.
- Group attention items into expiry buckets.
- Add one attention item, or all missing attention items, to the shopping list.
- Avoid duplicate shopping-list entries linked to the same inventory item.

### Shopping List

- Add shopping-list entries from tracked inventory items.
- Add manual shopping-list entries that are not linked to inventory.
- Optional price entry for shopping-list items.
- Check and uncheck purchased items.
- Search the shopping list.
- Swipe-delete an item with undo.
- Long-press multi-select mode for bulk deletion with undo.
- Delete all shopping-list items.
- Share the shopping list with optional price and purchase-status details.
- Display a total for entered prices.

### History And Revert

- Record inventory item create, update, restock, stock-correction, and delete events.
- Store previous and new item snapshots for change-log entries.
- View localized change summaries for an item.
- Revert an item to a previous logged snapshot.
- Configure log retention: off, three months, six months, one year, or a custom number of days.
- Run manual log cleanup from settings.
- Run retention cleanup on app startup.

### Backup And Restore

- Export the SQLite database through the Android file save dialog.
- Restore from a selected SQLite database file.
- Validate the SQLite file header before restore.
- Move the current database and SQLite sidecar files aside during restore so a failed restore can roll back.
- Restart the app after a successful restore.

### Notifications And Device Behavior

- Schedule a daily Android notification at 8 PM for warning and urgent items with notifications enabled.
- Localize notification text in Arabic or English.
- Use the device timezone, with fallback handling for unsupported timezone aliases.
- Request notification permission on Android.
- Register notification receivers for boot and package replacement.
- Prompt the user, after a delay, to review Android battery optimization settings when scheduled notifications may be affected.

### Localization And Onboarding

- First-run language selection.
- Onboarding flow before the main app is shown.
- Arabic and English localization through Flutter ARB files.
- RTL/LTR support through Flutter localization.
- Bundled Tajawal font family.

## Screenshots

Screenshots are not currently included in the repository.

Suggested future paths:

```text
docs/screenshots/home.png
docs/screenshots/expiry.png
docs/screenshots/shopping-list.png
docs/screenshots/settings.png
```

## Architecture

The application uses a layered Flutter architecture:

```text
Screens and widgets
        |
Riverpod providers and one Bloc/Cubit flow
        |
Services
        |
SQLite and SharedPreferences
```

- `MaterialApp.router` is configured in `lib/main.dart`.
- Navigation uses `go_router` with a language-selection gate, onboarding gate, and a stateful shell route for the main bottom-navigation areas.
- Inventory, shopping-list, locale, summary, and app-state data are exposed through Riverpod providers.
- The add-shopping-item flow uses a small `flutter_bloc` Cubit because that screen owns debounced search, manual-entry validation, and mode switching.
- `StorageService` owns SQLite schema creation, inventory persistence, shopping-list persistence, item history, and log-retention settings.
- `NotificationService`, `BackupService`, and `BatteryService` isolate platform-facing behavior from UI code.

## Tech Stack

| Area | Technology |
| --- | --- |
| Framework | Flutter |
| Language | Dart |
| Platform in this repository | Android |
| State management | Riverpod, Riverpod Generator, Flutter Bloc for the add-shopping-item flow |
| Routing | GoRouter |
| Database | SQLite via `sqflite` |
| Preferences | `shared_preferences` |
| Notifications | `flutter_local_notifications`, `timezone`, `flutter_timezone` |
| Backup and restore | `flutter_file_dialog`, `path_provider`, `sqflite` database paths |
| Localization | Flutter localization generated from ARB files |
| Sharing | `share_plus` |
| App restart | `restart_app` |
| Utilities | `uuid`, `intl`, `jiffy`, `equatable`, `path`, `app_settings` |
| Generated assets | `flutter_launcher_icons`, `flutter_native_splash` |

## Project Structure

```text
.
├── android/                 Android application, Gradle, manifest, signing template, resources
├── assets/                  App icon and splash image assets
├── fonts/Tajawal/           Bundled Tajawal font files
├── lib/
│   ├── core/                Theme, shared widgets, and utilities
│   ├── l10n/                ARB files and generated localization classes
│   ├── models/              Inventory, shopping item, history, expiry, and retention models
│   ├── providers/           Riverpod providers and generated provider files
│   ├── router/              GoRouter configuration, route paths, navigation shell, error/loading screens
│   ├── screens/             Home, expiry, shopping list, item form, history, settings, and onboarding screens
│   ├── services/            Storage, backup/restore, notifications, and battery optimization services
│   └── main.dart            App initialization and root widget
├── analysis_options.yaml    Dart analyzer configuration
├── l10n.yaml                Flutter localization configuration
├── pubspec.yaml             Package metadata, dependencies, assets, fonts, icon, and splash config
└── LICENSE                  Project license
```

## Getting Started

### Requirements

- Flutter 3.44.8 or a compatible stable Flutter SDK.
- Dart 3.12.2 or the Dart SDK bundled with the compatible Flutter release.
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

### Build A Release APK

```bash
flutter build apk --release
```

### Build A Release App Bundle

```bash
flutter build appbundle --release
```

Release signing reads `android/key.properties` when present. A template is available at `android/key.properties.example`.

## Development

Useful commands:

```bash
flutter analyze
dart format .
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter test
```

Notes:

- Riverpod generated files are checked in as `*.g.dart`.
- Localization output is configured by `l10n.yaml` and generated under `lib/l10n/`.
- Launcher icon and splash configuration live in `pubspec.yaml`.
- There is no `test/` directory in the current repository; `flutter test` currently exits with `Test directory "test" not found.` until tests are added.

## Configuration

Important Android configuration:

- Package namespace and application ID: `com.home_orders_tracker.app`.
- Java source and target compatibility: 17.
- Gradle wrapper: Gradle 9.1.0.
- Release builds enable code minification and resource shrinking.
- Android permissions include notification posting, vibration, and boot-completed handling for scheduled notifications.
- Android backup is disabled in the manifest; use the app's manual backup and restore flow for database portability.

## Current Limitations

- Android is the only platform configured in this repository.
- There is no cloud sync, account system, or multi-device merge behavior.
- Backups are manual SQLite database exports.
- Automated tests are not currently included.
- Screenshots and long-form user documentation are not currently included.
- `TRADEMARK.md` exists in the repository but is currently empty.

## Contributing

Contributions are welcome. Keep pull requests focused and include a clear description of the behavior changed.

Before opening a pull request:

- Run `flutter analyze`.
- Format Dart code with `dart format .`.
- Regenerate providers or localization files when their sources change.
- Add or update tests when introducing behavior that can be tested.
- Avoid unrelated refactors in feature or bug-fix pull requests.

Useful contribution areas include tests, screenshots, accessibility review, localization improvements, and Android notification reliability.

## License

The source code is released under the Unlicense. See [LICENSE](LICENSE) for the full text.

## Trademark

The repository contains a `TRADEMARK.md` file, but it is currently empty. Until trademark guidance is added, the license covers source-code use only and does not provide separate written branding guidelines.
