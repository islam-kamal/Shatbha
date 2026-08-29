import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Project-wide logger. Pretty console in debug; warnings+ in release.
/// Never pass tokens or passwords — use [redact] for maps/headers.
class AppLog {
  AppLog._();

  static final Logger _log = Logger(
    level: kDebugMode ? Level.trace : Level.warning,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 90,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static const _secrets = {
    'password',
    'token',
    'authorization',
    'access_token',
    'refresh_token',
    'secret',
    'api_key',
    'apikey',
  };

  static void t(String message, {String tag = 'shatbha'}) =>
      _log.t(_line(tag, message));

  static void d(String message, {String tag = 'shatbha'}) =>
      _log.d(_line(tag, message));

  static void i(String message, {String tag = 'shatbha'}) =>
      _log.i(_line(tag, message));

  static void w(String message, {String tag = 'shatbha', Object? error}) =>
      _log.w(_line(tag, message), error: error);

  static void e(
    String message, {
    String tag = 'shatbha',
    Object? error,
    StackTrace? stack,
  }) {
    _log.e(_line(tag, message), error: error, stackTrace: stack);
  }

  static void f(
    String message, {
    String tag = 'shatbha',
    Object? error,
    StackTrace? stack,
  }) {
    _log.f(_line(tag, message), error: error, stackTrace: stack);
  }

  static String _line(String tag, String message) => '[$tag] $message';

  static Object? redact(Object? value) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key: _secrets.contains(entry.key.toString().toLowerCase())
              ? '***'
              : redact(entry.value),
      };
    }
    if (value is List) return [for (final item in value) redact(item)];
    return value;
  }

  static Map<String, dynamic> redactHeaders(Map<String, dynamic> headers) {
    return {
      for (final entry in headers.entries)
        entry.key: _secrets.contains(entry.key.toLowerCase())
            ? '***'
            : entry.value,
    };
  }
}
