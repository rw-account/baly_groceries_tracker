# Home Orders Tracker

> **Home Orders Tracker (متابعة طلبات البيت)** is an offline-first Android application for managing household inventory, predicting depletion, tracking purchase priorities, and preserving a full history of item changes.

[![License](https://img.shields.io/badge/license-MIT--0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android%20Only-3DDC84?logo=android)](https://www.android.com)
[![Flutter](https://img.shields.io/badge/flutter-3.44.8-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-3.12.2-0175C2?logo=dart)](https://dart.dev)
[![State Management](https://img.shields.io/badge/state-Riverpod-00599C)](https://riverpod.dev)
[![Database](https://img.shields.io/badge/database-SQLite-003B57?logo=sqlite)](https://www.sqlite.org)

---

## Overview

Home Orders Tracker is a local-first household inventory management system built for Android.

It is designed to reduce the cognitive burden of managing consumable items at home. Instead of relying on memory or manually checking stock, the app records item durations, estimates when items will run out, classifies urgency visually, and keeps a complete audit trail of changes.

All data stays on the device. There is no cloud sync, no account system, and no external server dependency.

---

## Why this project?

Household supplies are often managed by guesswork.

That leads to:

* duplicate purchases
* forgotten essentials
* late replenishment
* unnecessary spending
* confusion about what changed and when

Home Orders Tracker replaces guesswork with structured inventory data.

Each item can have:

* a depletion estimate
* a visual status
* a shopping priority
* a change history
* a restore point
* a backup and recovery path

---

## Key Features

* **Local-first storage**: everything is stored in a private SQLite database on the device.
* **Smart depletion tracking**: estimate when an item will need replenishment.
* **Urgency-based UI**: clearly distinguish safe, warning, and urgent items.
* **Shopping list integration**: keep purchasing decisions aligned with inventory state.
* **Item history log**: track item creation, updates, restocks, corrections, and deletions.
* **State reversion**: restore an item to a previous state when mistakes happen.
* **Backup and restore**: export and import the local database.
* **Daily notifications**: notify the user about items that need attention.
* **Arabic and English support**: full RTL/LTR localization.
* **Offline operation**: works without internet access.

---

## Screenshots

Add screenshots here to show the main flows:

* Home dashboard
* Item details
* Add / edit item
* Shopping list
* History log
* Settings

Example:

```md
![Home screen](docs/screenshots/home.png)
![Item details](docs/screenshots/item-details.png)
![History log](docs/screenshots/history.png)
```

---

## Tech Stack

| Layer            | Technology                    |
| ---------------- | ----------------------------- |
| Framework        | Flutter                       |
| Language         | Dart                          |
| State Management | Riverpod                      |
| Routing          | GoRouter                      |
| Database         | SQLite (`sqflite`)            |
| Notifications    | `flutter_local_notifications` |
| Localization     | Flutter internationalization  |
| Platform         | Android                       |

---

## Requirements

* Flutter `3.44.8`
* Dart `3.12.2`
* Android Studio or VS Code
* Java JDK 17 or newer
* Android SDK configured

Recommended target:

* Android API 21+ (Lollipop and above)

---

## Getting Started

```bash
git clone https://github.com/[your-username]/home-orders-tracker.git
cd home-orders-tracker
flutter pub get
flutter run
```

---

## Build

### Debug run

```bash
flutter run
```

### Release APK

```bash
flutter build apk --release
```

### Release App Bundle

```bash
flutter build appbundle --release
```

---

## Project Structure

A typical structure may look like this:

```text
lib/
├── models/
├── providers/
├── screens/
├── services/
├── widgets/
└── main.dart
```

Core responsibilities:

* **UI**: screens and reusable widgets
* **State**: Riverpod providers and controllers
* **Services**: storage, notifications, backup, retention, and history
* **Database**: SQLite persistence layer

---

## Architecture

The app follows a simple layered flow:

```text
UI
↓
Riverpod State
↓
Services
↓
SQLite Database
```

This keeps the application predictable, testable, and easy to extend.

---

## Contributing

Contributions are welcome.

You can help by:

* fixing bugs
* improving translations
* refining UI behavior
* improving the history and restore logic
* adding tests
* improving documentation

Before opening a pull request, please keep changes focused and avoid unrelated refactors.

---

## License

The source code is distributed under the **MIT-0 License**. See the [LICENSE](LICENSE) file for details.

---

## Trademark

The name **Home Orders Tracker / متابعة طلبات البيت**, the app icon, and the branding assets are part of the project identity.

See [TRADEMARK.md](TRADEMARK.md) for usage rules and distribution guidelines.
