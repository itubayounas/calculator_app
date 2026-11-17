# Calculator App

A calculator built with Flutter, with user accounts and cloud-synced calculation history.

## Features

- Addition, subtraction, multiplication, division, percentage, sign toggle
- Chained calculations (4 + 5 x 2 evaluates left to right, like a standard calculator)
- Error handling for divide by zero, overflow, and other invalid input, each with a clear message
- Email/password sign up and login, plus Google sign-in
- Password visibility toggle and forgot-password flow
- Calculation history stored per user in Firestore, with a local copy so it still works offline
- Light and dark theme, follows the system setting

## Tech stack

- Flutter (Dart)
- Firebase Authentication (email/password and Google)
- Cloud Firestore for history
- shared_preferences for local/offline storage

## Project structure

```
lib/
  models/     data classes
  services/   calculator logic, auth, history - no UI code
  utils/      exceptions and input validation
  widgets/    reusable UI pieces
  screens/    full app screens
test/         unit tests for the calculator logic and validators
```

The calculator logic in `services/calculator_engine.dart` has no Flutter dependencies, which is what makes it possible to unit test directly.

## Running it

```
flutter pub get
flutter run
```

Firebase is already configured for this project. To point it at your own Firebase project instead, run `flutterfire configure` and replace `lib/firebase_options.dart`.

## Tests

```
flutter test
```

