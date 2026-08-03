# Home Orders Tracker

[![License](https://img.shields.io/badge/license-MIT-4CAF50.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)](android/)
[![Flutter](https://img.shields.io/badge/flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![State](https://img.shields.io/badge/state-Riverpod-00599C)](https://riverpod.dev)
[![Database](https://img.shields.io/badge/database-SQLite-003B57?logo=sqlite&logoColor=white)](https://www.sqlite.org)
![100% Local First](https://img.shields.io/badge/privacy-100%25%20Local--First-2E7D32?logo=shield&logoColor=white)
![No Ads](https://img.shields.io/badge/ads-Free%20%26%20No%20Ads-FF9800)
[![Languages](https://img.shields.io/badge/languages-Arabic%20%7C%20English-7952B3)](lib/l10n/)

**Home Orders Tracker** helps you keep track of your household essentials, letting you see at a glance how much you have left of eggs, flour, rice, and other everyday items, so you always know what's running low and what's still well stocked.

This helps you prioritize your shopping, giving you greater control over your household budget. By notifying you before essential items run out, the app gives you a chance to set aside part of your budget for them before spending it on non-essential purchases. It also reduces the worry of unexpectedly running out of everyday necessities, giving you peace of mind by always keeping you informed about what you have at home.

The app also includes a wide range of useful features, including:

- The **"Expiry"** screen automatically lists all items that are close to running out, sorted by priority with clear visual indicators, so you instantly know what needs to be bought first.

- Receive notifications before household essentials run low, giving you plenty of time to plan your shopping. You can also disable notifications for any individual item whenever you want.

- No need to keep your shopping list somewhere else. The built-in shopping list lets you add items that are running low, along with anything else you don't track in the app, so you buy only what you actually need and avoid unnecessary impulse purchases. You can also share the list easily via WhatsApp with anyone who can shop for you.

- Want to let a family member know what's available at home? Generate a summary showing all your tracked items and the remaining days for each one, then share it instantly via WhatsApp.

- Made a mistake while updating an item, or unsure about a value you entered before? No problem. You can review the complete change history to see exactly what was changed and when, and restore any previous version whenever you need.

- Your data is stored locally on your device to protect your privacy. The app works completely offline and also lets you create and restore backups whenever needed.

- Completely free of ads, so you can use the app without distractions.

- Full support for both Arabic and English.

## Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Home Screen</b></td>
      <td align="center"><b>Expiry Screen</b></td>
    </tr>
    <tr>
      <td align="center">
        <img src="assets/screenshots/en/home_en.png" alt="English home screen" width="260">
      </td>
      <td align="center">
        <img src="assets/screenshots/en/expiry_en.png" alt="English expiry screen" width="260">
      </td>
    </tr>
    <tr>
      <td align="center"><b>Shopping List</b></td>
      <td align="center"><b>Edit Item</b></td>
    </tr>
    <tr>
      <td align="center">
        <img src="assets/screenshots/en/shopping_list_en.png" alt="English shopping list screen" width="260">
      </td>
      <td align="center">
        <img src="assets/screenshots/en/edit_item_en.png" alt="English edit item screen" width="260">
      </td>
    </tr>
  </table>
</div>

## Building from Source

### Prerequisites

- **Flutter SDK:** `>= 3.44.0` (Stable Channel)

- **Dart SDK:** `>= 3.12.0`

- **Android SDK**

- **Java Development Kit (JDK):** `17` or later

- **Git**

---

### 1. Set Up the Project

Clone the repository and download the project dependencies:

```bash
git clone https://github.com/rw-account/home_orders_tracker.git
cd home_orders_tracker
flutter pub get
```

---

### 2. Choose a Build Method

Choose **one** of the following build methods based on your needs.

---

#### Standard Release Build

Suitable for building and testing the app in **Release** mode.

This method does not require any signing keys or secret configuration files. Simply run:

```bash
flutter build apk --release
```

**Output file:**

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

#### Signed Release Build

Suitable for creating an official release signed with your own **Keystore (.jks)**, whether you plan to publish it on an app store or distribute it yourself.

1. Copy the signing configuration template:

```bash
cp android/key.properties.example android/key.properties
```

2. Open `android/key.properties`, then enter the path to your **Keystore (.jks)** file along with its passwords.

3. Build the app:

```bash
flutter build apk --release
```

**Output file:**

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## Contributing

Contributions are welcome. To help keep the review process smooth, please keep pull requests focused and include a clear description of the changes.

### Before submitting a pull request

- Run `flutter analyze` and ensure it reports no errors or warnings.

- Regenerate localization and other generated files if you updated their source files:

  ```bash
  dart run build_runner build
  ```

- Keep each pull request focused on a single feature or fix. Avoid combining unrelated changes into the same pull request.

---

## License & Trademark

The source code of this project is licensed under the **MIT License**. For the full license text, see the [LICENSE](LICENSE) file.

The application name, logo, app icon, and other branding assets are **not** covered by the MIT License. Their use is governed by the [Trademark Policy](TRADEMARK.md).
