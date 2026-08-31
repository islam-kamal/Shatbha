import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/config/app_flavor.dart';
import 'core/config/env.dart';
import 'core/di/injection.dart';
import 'core/logging/app_log.dart';
import 'core/observers/bloc_observer.dart';

Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.configure(flavor);
  _installErrorHooks();
  Bloc.observer = AppBlocObserver();
  final rejected = Env.rejectedApiBaseUrlOverride;
  if (rejected != null) {
    AppLog.w(
      'Ignoring invalid API_BASE_URL dart-define: $rejected '
      '→ using ${Env.apiBaseUrl}. Remove it from your Run configuration.',
      tag: 'boot',
    );
  }
  AppLog.i(
    'boot flavor=${flavor.name} API_BASE_URL=${Env.apiBaseUrl} '
    'target=${defaultTargetPlatform.name} debug=$kDebugMode',
  );
  if (flavor == AppFlavor.local &&
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android) {
    AppLog.i(
      'Android local: ensure `adb reverse tcp:8000 tcp:8000` and '
      'Laravel on 127.0.0.1:8000 (scripts/run_local_android.sh)',
      tag: 'boot',
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
