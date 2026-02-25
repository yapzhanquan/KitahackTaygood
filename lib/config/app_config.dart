// App-wide configuration for data mode and emulator settings.

enum DataMode {
  /// Use local mock data (no Firebase required). Default for demos.
  mock,

  /// Use Firebase Firestore + Auth + Storage.
  firebase,
}

class AppConfig {
  // Configure via --dart-define flags for demo flexibility.
  static const String _dataModeFlag =
      String.fromEnvironment('DATA_MODE', defaultValue: 'mock');

  /// Toggle between mock and firebase mode.
  static final DataMode dataMode = _dataModeFlag.toLowerCase() == 'firebase'
      ? DataMode.firebase
      : DataMode.mock;

  /// When true and dataMode == firebase, connect to local Firebase emulators.
  static const bool useEmulators =
      bool.fromEnvironment('USE_EMULATORS', defaultValue: false);

  // Emulator settings.
  /// Host for Firebase emulators (use 10.0.2.2 for Android emulator).
  static const String emulatorHost =
      String.fromEnvironment('EMULATOR_HOST', defaultValue: 'localhost');
  static const int firestorePort =
      int.fromEnvironment('FIRESTORE_PORT', defaultValue: 8080);
  static const int authPort =
      int.fromEnvironment('AUTH_PORT', defaultValue: 9099);
  static const int storagePort =
      int.fromEnvironment('STORAGE_PORT', defaultValue: 9199);

  // Google Maps.
  /// Set to true once you've added a valid Google Maps API key.
  static const bool googleMapsEnabled =
      bool.fromEnvironment('GOOGLE_MAPS_ENABLED', defaultValue: false);
}
