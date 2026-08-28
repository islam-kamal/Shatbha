import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Debug-console + DevTools logging. No-ops in release.
class AppLog {
  static void d(String message, {String tag = 'shatbha'}) {
    if (!kDebugMode) return;
    final line = '[$tag] $message';
    debugPrint(line);
    developer.log(message, name: tag);
  }

  static void e(
    String message, {
    String tag = 'shatbha',
    Object? error,
    StackTrace? stack,
  }) {
    if (!kDebugMode) return;
    final line = '[$tag] ERROR $message${error != null ? ': $error' : ''}';
    debugPrint(line);
    developer.log(
      message,
      name: tag,
      error: error,
      stackTrace: stack,
      level: 1000,
    );
  }
}
