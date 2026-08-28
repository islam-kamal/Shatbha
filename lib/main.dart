import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/app_log.dart';
import 'core/bloc_observer.dart';
import 'core/di.dart';
import 'core/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  AppLog.d('boot API_BASE_URL=${Env.apiBaseUrl} target=${defaultTargetPlatform.name}');
  if (defaultTargetPlatform == TargetPlatform.android &&
      Env.apiBaseUrl.contains('127.0.0.1')) {
    AppLog.e(
      'Android emulator cannot reach 127.0.0.1 — use '
      '--dart-define=API_BASE_URL=http://10.0.2.2:8000',
    );
  }
  await initializeDateFormatting('ar');
  await setupDependencies();
  AppLog.d('dependencies ready');
  runApp(const ShatbhaApp());
}
