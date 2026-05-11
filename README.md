# MyMoney

A personal expense tracker built with Flutter. Keep track of where your money goes, secured behind a PIN. as required by the rubrics.

---
## Group Memebers

- Dagim Melese          ATE/4246/15   
- Eyuel Fikru           ATE/0634/15
- Haile Zigale          ATE/1860/15
- Paulos Haile-Michael  ATE/8171/15

---


# What it does

- **PIN protection** — The app asks for a 4-digit PIN every time you open it. The PIN is stored securely using `flutter_secure_storage`.
- **Add, edit, delete expenses** — Each expense has an amount, category, optional note, and date.
- **Categories** — Food, Transport, Shopping, Bills, Entertainment, Health. Each has its own icon.
- **Monthly total** — The home screen shows total spending across all expenses.
- **Dark mode** — Toggle between light and dark theme. Your preference is saved.
- **Currency** — Pick from USD, EUR, ETB, GBP. Shows on the home screen and in transaction amounts.
- **Logout** — Returns to the login screen. Does not delete anything.
- **Change PIN** — You can update your PIN from settings.
- **Factory reset** — Wipes everything: all expenses and the PIN. Takes you back to square one.

---

# How it's put together

The app uses a simple service-layer approach. No state management library — screens manage their own state and call services directly.

## Services

- **ExpensesDb** — Handles all SQLite operations. Singleton. Does insert, update, delete, get all, get monthly total, and wipe.
- **PinVault** — Wraps `flutter_secure_storage`. Stores, reads, checks existence, and deletes the PIN.
- **PrefsService** — Wraps `shared_preferences`. Saves and loads theme preference and currency code.

## Screens

- **SetupPinScreen** — Shown when no PIN exists yet, or when changing an existing PIN. Uses an `isFirstTime` flag to decide what title/icon to show and where to navigate after saving.
- **LoginScreen** — Shows a lock icon, "Welcome Back" text, four animated dots for PIN entry, and a custom number pad widget. Auto-verifies after the 4th digit.
- **HomeScreen** — Shows a gradient balance card with the monthly total, then a list of transactions. Pulls data on init and refreshes after returning from the expense form or settings.
- **ExpenseForm** — Used for both adding and editing. If an existing expense is passed in, it pre-fills the fields. Validates that the amount is a number.
- **SettingsScreen** — Dark mode toggle, currency dropdown, change PIN, logout, and the factory reset button.

## Widgets

- **NumPad** — A custom numeric keypad with numbers 0-9 and a delete button. Used on the login screen.

## Model

- **Expense** — Plain Dart class with `id`, `amount`, `category`, `note`, and `date`. Includes `toMap()` and `fromMap()` methods for SQLite serialization.

---

# Data flow

1. App starts, `main.dart` checks if a PIN exists.
2. No PIN goes to `SetupPinScreen`. User creates one, then goes to `HomeScreen`.
3. PIN exists goes to `LoginScreen`. User enters PIN. If correct, goes to `HomeScreen`.
4. `HomeScreen` loads expenses and preferences on init.
5. After adding or editing an expense, `HomeScreen` refreshes its data.
6. Logout navigates to `LoginScreen` and clears the navigation stack.
7. Factory reset clears PIN and database, then navigates to `SetupPinScreen`.

---

# Navigation flow

```text
App Launch
|
+-- No PIN saved --> SetupPinScreen (isFirstTime: true) --> HomeScreen
|
+-- PIN exists --> LoginScreen --> HomeScreen
                         ^        |
                         |        +-- Add/Edit --> ExpenseForm
                         |        |
                         |        +-- Settings --> SettingsScreen
                         |                         |
                         |                         +-- Logout --> LoginScreen
                         |                         |
                         |                         +-- Factory Reset --> SetupPinScreen
```

---

# Dependencies

| Package | Version | What it's for |
|---|---|---|
| sqflite | ^2.3.0 | Local SQLite database for storing expenses |
| path | ^1.8.0 | Building the database file path |
| flutter_secure_storage | ^9.0.0 | Encrypted storage for the PIN |
| shared_preferences | ^2.2.0 | Simple key-value storage for theme and currency |

---

# pubspec.yaml

```yaml
name: mymoney
description: A personal expense tracker

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
```

---

# Running it

## What you need

- Flutter SDK 3.0 or higher
- Android Studio or VS Code with Flutter extensions
- A device or emulator (Android or iOS)

## Steps

```bash
git clone <repo-url>
cd mymoney
flutter pub get
flutter run
```

---

# Building for release

```bash
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
```

---

# Project structure

```text
mymoney/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── expense.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   ├── setup_pin_screen.dart
│   │   ├── settings_screen.dart
│   │   └── expense_form.dart
│   ├── services/
│   │   ├── expenses_db.dart
│   │   ├── pin_vault.dart
│   │   └── prefs_service.dart
│   └── widgets/
│       └── num_pad.dart
├── test/
│   └── widget_test.dart
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

# Database schema

```sql
CREATE TABLE expenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount REAL,
  category TEXT,
  note TEXT,
  date TEXT
);
```

Dates are stored as ISO 8601 strings and converted back into `DateTime` objects when loaded from the database.

---

# Local Storage & Data Persistence

This project demonstrates local storage and persistence in Flutter using:

- **SQLite (`sqflite`)** for storing expenses permanently on the device
- **flutter_secure_storage** for securely saving the user PIN
- **shared_preferences** for lightweight app settings such as theme and currency

Data remains available even after the app is closed or restarted.

# Ai prompts used

- I am building a Flutter expense tracker for a graded lab. I need to set up the data persistence layer following a clean service-based architecture. Please generate a guide so i can follow to create the first layer of the app.
- Generate the incomplete parts of the three service files for  data persistence
- Build the authentication UI.
- Review the project structure for clean code compliance.