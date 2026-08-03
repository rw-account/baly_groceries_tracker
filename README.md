# Home Orders Tracker

[![License](https://img.shields.io/badge/license-MIT-4CAF50.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)](android/)
[![Flutter](https://img.shields.io/badge/flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![State](https://img.shields.io/badge/state-Riverpod-00599C)](https://riverpod.dev)
[![Database](https://img.shields.io/badge/database-SQLite-003B57?logo=sqlite&logoColor=white)](https://www.sqlite.org)
[![100% Local First](https://img.shields.io/badge/privacy-100%25%20Local--First-2E7D32?logo=shield&logoColor=white)](README.md)
[![No Ads](https://img.shields.io/badge/ads-Free%20%26%20No%20Ads-FF9800)](README.md)
[![Languages](https://img.shields.io/badge/languages-Arabic%20%7C%20English-7952B3)](lib/l10n/)

Home Orders Tracker is a local-first Flutter app for managing household supplies. It helps you track what you have at home, estimate when each item needs to be replaced, and turn low-stock items into a practical shopping list.

The app is designed for an offline Android workflow. Data stays on the device in SQLite, with manual backup and restore for portability.

## Highlights

- Local-first inventory tracking for recurring household items.
- Smart item statuses based on remaining days: safe, warning, and urgent.
- Shopping list generated from inventory items or created manually.
- Item history with restock, correction, update, delete, and restore support.
- Daily Android notifications for warning and urgent items.
- Arabic and English interface with RTL/LTR support.
- Manual SQLite database backup and restore.
- Dark theme and bundled Tajawal font family.

## Screenshots

### English

<table>
  <tr>
    <td><img src="assets/screenshots/en/home_en.png" alt="English home screen"></td>
    <td><img src="assets/screenshots/en/expiry_en.png" alt="English expiry screen"></td>
  </tr>
  <tr>
    <td><img src="assets/screenshots/en/shopping_list_en.png" alt="English shopping list screen"></td>
    <td><img src="assets/screenshots/en/edit_item_en.png" alt="English edit item screen"></td>
  </tr>
</table>

## Features

### Inventory

- Add, edit, search, restock, correct, and delete items.
- Track expected duration, refresh date, remaining days, notes, and prices.
- Set custom warning and urgent thresholds per item.
- View grouped item states for safe, warning, and urgent supplies.
- Share item reports with optional remaining-day and renewal-date details.

### Expiry And Attention

- Dedicated view for items that need attention.
- Clear grouping for urgent and soon-to-run-out supplies.
- Localized remaining-time labels in Arabic and English.

### Shopping List

- Add items manually or from inventory.
- Prevent duplicate shopping entries for the same inventory item.
- Mark items as bought, search the list, swipe to delete, undo deletion, and bulk delete.
- Track optional prices and show the shopping total.
- Share the shopping list.

### History And Data

- Log item creation, updates, restocks, corrections, and deletions.
- Restore inventory items from previous logged snapshots.
- Configure history retention and clean old logs manually.
- Export and restore the local SQLite database.

### Onboarding And Localization

- First-run language selection.
- Introductory onboarding flow.
- Arabic and English localization, including notification text.
- RTL and LTR layouts.

## Tech Stack

- [Flutter](https://flutter.dev) and [Dart](https://dart.dev)
- [Riverpod](https://riverpod.dev) with generated providers
- [Flutter Bloc](https://bloclibrary.dev) for the add-shopping-item flow
- [GoRouter](https://pub.dev/packages/go_router) for navigation
- [sqflite](https://pub.dev/packages/sqflite) for SQLite storage
- [shared_preferences](https://pub.dev/packages/shared_preferences) for app preferences
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) for Android notifications
- [timezone](https://pub.dev/packages/timezone) and [flutter_timezone](https://pub.dev/packages/flutter_timezone)
- [flutter_file_dialog](https://pub.dev/packages/flutter_file_dialog) for backup and restore files
- [share_plus](https://pub.dev/packages/share_plus) for sharing reports and lists
- [intl](https://pub.dev/packages/intl) and [jiffy](https://pub.dev/packages/jiffy) for localized dates
- [introduction_screen](https://pub.dev/packages/introduction_screen) for onboarding

## Getting Started

### Requirements

- Flutter 3.x or a compatible stable Flutter SDK.
- Dart 3.x, usually bundled with Flutter.
- Android SDK with a configured Android device or emulator.
- JDK 17 or newer for Android builds.

This repository currently includes Android platform files only.

### Install

```bash
flutter pub get
```

### Run

```bash
flutter run
```

### Build Android Release

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

## Contributing

Contributions are welcome. Please keep pull requests focused and include a clear description of the behavior changed.

Before opening a pull request:

- Run `flutter analyze`.
- Format Dart code with `dart format .`.
- Regenerate providers or localization files when their sources change.
- Add or update tests for behavior that can be tested.
- Avoid unrelated refactors in feature or bug-fix pull requests.

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.
