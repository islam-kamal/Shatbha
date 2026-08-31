import 'app_flavor.dart';

class Env {
  static AppFlavor _flavor = AppFlavor.production;

  static void configure(AppFlavor flavor) {
    _flavor = flavor;
  }

  static AppFlavor get flavor => _flavor;

  /// Raw value from `--dart-define=API_BASE_URL=...` (compile-time).
  static const apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

  /// Resolved API host. Flavor default wins unless override is a valid URL.
  static String get apiBaseUrl {
    if (_isValidApiOverride(apiBaseUrlOverride)) {
      return apiBaseUrlOverride;
    }
    return _flavor.apiBaseUrl;
  }

  /// Non-null when a dart-define was set but rejected (e.g. README placeholder).
  static String? get rejectedApiBaseUrlOverride {
    if (apiBaseUrlOverride.isEmpty) return null;
    if (_isValidApiOverride(apiBaseUrlOverride)) return null;
    return apiBaseUrlOverride;
  }

  static bool _isValidApiOverride(String value) {
    if (value.isEmpty) return false;
    final lower = value.toLowerCase();
    if (lower.contains('x.x') ||
        lower.contains('<') ||
        lower.contains('your-lan') ||
        lower.contains('example.com')) {
      return false;
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;
    return uri.scheme == 'http' || uri.scheme == 'https';
  }
}
