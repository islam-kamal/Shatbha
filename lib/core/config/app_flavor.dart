/// Build mode: local Laravel vs hosted Northflank API.
enum AppFlavor {
  local,
  production;

  String get label {
    switch (this) {
      case AppFlavor.local:
        return 'Local';
      case AppFlavor.production:
        return 'Production';
    }
  }

  /// Local Laravel (`php artisan serve --host=127.0.0.1 --port=8000`).
  ///
  /// On Android (phone or emulator), run `adb reverse tcp:8000 tcp:8000` so
  /// the device’s `127.0.0.1:8000` reaches your Mac. See `scripts/run_local_android.sh`.
  static const localApiBaseUrl = 'http://127.0.0.1:8000';

  static const productionApiBaseUrl =
      'https://p02--shatbha--9lqgqlp9drrc.code.run';

  String get apiBaseUrl {
    switch (this) {
      case AppFlavor.local:
        return localApiBaseUrl;
      case AppFlavor.production:
        return productionApiBaseUrl;
    }
  }
}
