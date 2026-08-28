# 🚀 Next Release

## 💡 Feature: Settings Backup & Restore via SQLite

> **Goal:** Include `SharedPreferences` settings (e.g., notification time, log retention duration) inside the exported SQLite `.db` backup file without altering the existing app architecture or modifying UI screens.

### 📋 How It Works & Required Tasks

- **Backup Table:** Create a dedicated `settings_backup` table (`key TEXT PRIMARY KEY, value TEXT`) in SQLite to act as a bridge during backup and restore operations.
- **Export Process (Backup):** Automatically read selected keys from `SharedPreferences` and copy them as key-value pairs into the `settings_backup` table right before exporting the `.db` file.
- **Import Process (Restore):** After restoring the `.db` file on a new device, read the `settings_backup` table and re-inject the values into local `SharedPreferences` with proper type casting (String, int, bool).
- **Architecture Continuity:** Continue using `SharedPreferences` across all UI screens as normal, avoiding complex refactoring while achieving seamless settings migration.

---

## 💡 Feature: Organizing the Shopping List by Categories

> **Goal:** Simplify the shopping experience for the user by grouping items based on the shopping location (e.g., supermarket, restaurant, electronics store), saving time when present at a specific location instead of going through the entire list.

### 📋 How It Works & Required Tasks

- **Default Category:** All new items are added by default under the "Uncategorized" category.
- **Category Management:** Provide a dedicated option/button to create and manage categories.
- **Assigning Categories:** The user can move any item from "Uncategorized" to any category they select at any time.
- **Displaying and Filtering Items:** The ability to filter or view items by category, so the user only sees items specific to their current location (e.g., opening the "Restaurant" category when there).

---

## 💭 Ideas Under Consideration (Unconfirmed)

> **Note:** The following points are tentative ideas currently under evaluation and have not been finalized or guaranteed for implementation.

### 🔄 Keeping the User on the "Add Item" Screen

- **Concept:** Instead of redirecting the user back to the main shopping list screen immediately after adding an item, keep them on the "Add Item" screen with reset fields.
- **Purpose:** Saves effort and reduces repetitive steps when users need to enter multiple items in a single session.

### 📲 Interactive List Sharing via File Import (e.g., JSON)

- **Concept:** Export and share the shopping list as an importable file format (such as `.json`) rather than plain static text.
- **Purpose:** Allows the recipient (e.g., a spouse) to import the list into their own app instance and check off (`checked`) items interactively while shopping.
