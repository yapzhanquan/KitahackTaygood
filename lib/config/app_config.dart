// App-wide configuration for data mode and emulator settings.

enum DataMode {
  /// Use local mock data (no Firebase required). Default for demos.
  mock,

  /// Use Firebase Firestore + Auth + Storage.
  firebase,
}

class AppConfig {
  // ── Change these to switch modes ──────────────────────────────
  /// Toggle between mock and firebase mode.
  static const DataMode dataMode = DataMode.mock;

  /// When true and dataMode == firebase, connect to local Firebase emulators.
  static const bool useEmulators = false;

  // ── Emulator settings ────────────────────────────────────────
  /// Host for Firebase emulators (use 10.0.2.2 for Android emulator).
  static const String emulatorHost = 'localhost';
  static const int firestorePort = 8080;
  static const int authPort = 9099;
  static const int storagePort = 9199;

  // ── Google Maps ──────────────────────────────────────────────
  /// Set to true once you've added a valid Google Maps API key.
  static const bool googleMapsEnabled = false;
}
