# ProjekWatch — Developer Guide

> Community-powered construction project tracker for Malaysia.  
> **Stack**: Flutter 3 · Firebase (Auth · Firestore · Storage) · Google Maps · Provider

---

## Quick Start

```bash
# 1. Install dependencies
flutter pub get

# 2. Run in mock-data mode (no Firebase setup needed)
flutter run            # launches with local mock data by default

# 3. Run tests
flutter test
```

In **mock mode** (`DataMode.mock`) the app uses hardcoded sample projects from  
`lib/mock_data.dart`. No Firebase project is needed.

---

## Project Structure

```
lib/
├── config/
│   ├── app_config.dart          # DataMode toggle + emulator settings
│   └── firebase_options.dart    # Auto-generated Firebase config (placeholder)
├── models/
│   ├── project_model.dart       # Project, enums, fromJson/toJson
│   ├── checkin_model.dart       # CheckIn model + serialization
│   └── user_model.dart          # AppUser model + serialization
├── providers/
│   ├── project_provider.dart    # Projects state, filters, check-ins
│   └── auth_provider.dart       # Auth state, bookmarks
├── repositories/
│   ├── project_repository.dart  # Project data access
│   ├── checkin_repository.dart  # Check-in data access
│   └── user_repository.dart     # User + bookmarks data access
├── services/
│   ├── auth_service.dart        # Firebase Auth + Google Sign-In wrapper
│   ├── firestore_service.dart   # Typed Firestore CRUD helpers
│   └── storage_service.dart     # Image upload + compression
├── screens/
│   ├── main_page.dart           # Home: Projects / Categories / Insights tabs
│   ├── project_detail_page.dart # Project detail (Airbnb-inspired layout)
│   ├── add_checkin_page.dart    # Check-in form with image picker
│   └── sign_in_page.dart        # Google Sign-In bottom sheet
├── widgets/
│   ├── hero_search_bar.dart     # Search + filter bar
│   ├── project_card.dart        # Horizontal scroll card
│   ├── project_image.dart       # Network/asset image with fallback
│   ├── project_map.dart         # Google Maps widget (placeholder fallback)
│   ├── status_badge.dart        # Coloured status pill
│   ├── confidence_badge.dart    # Confidence level pill
│   └── section_header.dart      # Section title widget
├── mock_data.dart               # 12 sample projects for demo mode
└── main.dart                    # App entry + Firebase init + MultiProvider
```

---

## Data Mode

Controlled by `lib/config/app_config.dart`:

| Constant             | Default     | Purpose |
|----------------------|-------------|---------|
| `dataMode`           | `DataMode.mock` | Requested mode from `--dart-define=DATA_MODE=...` |
| `runtimeDataMode`    | `DataMode.mock` | Effective mode after startup checks/fallback |
| `useEmulators`       | `false`     | Connect to Firebase Emulator Suite |
| `googleMapsEnabled`  | `false`     | Show real map vs styled placeholder |
| `geminiApiKey`       | `''`        | Gemini API key from `--dart-define=GEMINI_API_KEY` |
| `geminiModel`        | `gemini-2.0-flash` | Preferred Gemini model from `--dart-define=GEMINI_MODEL` |

To switch to Firebase:
1. Run `flutterfire configure` to generate real `firebase_options.dart`.
2. Run with `--dart-define=DATA_MODE=firebase`.
3. Deploy Firestore rules: `firebase deploy --only firestore:rules,storage`.

---

## Firestore Data Model

```
projects/{projectId}
  ├── name, category, status, confidence, location, ...
  └── checkins/{checkinId}
        ├── status, note, photoUrl, photoUrls
        ├── timestamp, reporterName, userId

users/{userId}
  ├── displayName, email, photoURL, role, contributionCount
  └── bookmarks/{projectId}
        └── createdAt
```

Security rules: `firestore.rules` and `storage.rules` in project root.

---

## Architecture Layers

```
UI (Screens / Widgets)
        │
        ▼
  Providers (ChangeNotifier + Provider)
        │
        ▼
  Repositories (clean data API)
        │
        ▼
  Services (Firebase SDK wrappers)
```

- **Providers** own state and call repositories for persistence.
- **Repositories** delegate to services — can be swapped for tests.
- **Services** (`AuthService`, `FirestoreService`, `StorageService`) are thin
  wrappers around Firebase SDKs.
- In **mock mode**, providers skip repository calls and use `mock_data.dart`.

---

## Auth Flow

1. User taps **Contribute** or **Bookmark** → checked via `AuthProvider.isSignedIn`.
2. If not signed in → `SignInPage.show(context)` opens a bottom sheet.
3. In firebase mode: Google Sign-In → Firebase Auth credential → Firestore user doc upserted.
4. In mock mode: local demo user is created so gated flows can still be tested.
5. On success, the gated action proceeds.

---

## Check-in Flow

1. User selects a project → `AddCheckinPage`.
2. Picks observed status (active / slowing / stalled / unverified).
3. Adds a text note (required) and optional photo.
4. Photo is compressed (`flutter_image_compress`) and uploaded to Firebase Storage.
5. `ProjectProvider.addCheckIn()` performs an **optimistic local update** and then
   persists to Firestore asynchronously.
6. Confidence level is **recalculated** based on the last 5 check-ins.

---

## Tests

```bash
flutter test                    # run all tests
flutter test test/project_provider_test.dart   # provider unit tests only
flutter test test/model_test.dart              # model serialization tests
```

| Test file | Count | What it covers |
|-----------|-------|----------------|
| `project_provider_test.dart` | 21 | Init, filters, section getters, check-in logic, confidence recalculation |
| `model_test.dart` | 9 | `Project`, `CheckIn`, `AppUser` round-trip serialization + missing-field edge cases |
| `widget_test.dart` | 6 | MainPage rendering, tab switching, contribute button |

---

## Useful Commands

```bash
flutter pub get                # resolve dependencies
dart analyze lib/              # static analysis
flutter run -d chrome          # run on web
flutter run -d windows         # run on Windows desktop
flutter build apk              # Android release build
firebase deploy --only firestore:rules,storage   # deploy security rules
```

---

## Environment Requires

- Flutter SDK ≥ 3.5.0
- Dart SDK ≥ 3.5.0
- For Firebase mode: a configured Firebase project
- For Google Maps: a valid API key in platform configs
