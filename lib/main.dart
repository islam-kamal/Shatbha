import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/di/injection.dart';
import 'core/logging/app_log.dart';
import 'core/observers/bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorHooks();
  Bloc.observer = AppBlocObserver();
  AppLog.i(
    'boot API_BASE_URL=${Env.apiBaseUrl} '
    'target=${defaultTargetPlatform.name} '
    'debug=$kDebugMode',
  );
  if (defaultTargetPlatform == TargetPlatform.android &&
      Env.apiBaseUrl.contains('127.0.0.1')) {
    AppLog.w(
      'Android emulator cannot reach 127.0.0.1 — use '
      '--dart-define=API_BASE_URL=http://10.0.2.2:8000',
    );
  }
  await initializeDateFormatting('ar');
  await setupDependencies();
  AppLog.i('dependencies ready');
  runApp(const ShatbhaApp());
}

void _installErrorHooks() {
  FlutterError.onError = (details) {
    AppLog.e(
      details.exceptionAsString(),
      tag: 'flutter',
      error: details.exception,
      stack: details.stack,
    );
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLog.e('uncaught', tag: 'flutter', error: error, stack: stack);
    return !kDebugMode;
  };
  ErrorWidget.builder = (details) {
    AppLog.e(
      'ErrorWidget ${details.exceptionAsString()}',
      tag: 'flutter',
      error: details.exception,
      stack: details.stack,
    );
    return ErrorWidget(details.exception);
  };
}
