import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/logging/app_log.dart';
import 'core/routing/app_router.dart';
import 'core/theme/atelier_theme.dart';
import 'features/auth/presentation/cubit/auth_bloc.dart';
import 'features/shell/presentation/cubit/date_range_cubit.dart';
import 'features/sync/presentation/cubit/sync_cubit.dart';

class ShatbhaApp extends StatefulWidget {
  const ShatbhaApp({super.key});

  @override
  State<ShatbhaApp> createState() => _ShatbhaAppState();
}

class _ShatbhaAppState extends State<ShatbhaApp> {
  late final AuthBloc _authBloc;
  late final DateRangeCubit _dates;
  late final SyncCubit _sync;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(sl())..add(const AuthStarted());
    _dates = DateRangeCubit();
    _sync = SyncCubit(sl())..refresh();
    _router = createRouter(_authBloc);
    AppLog.i('app shell ready', tag: 'app');
  }

  @override
  void dispose() {
    _authBloc.close();
    _dates.close();
    _sync.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _dates),
        BlocProvider.value(value: _sync),
      ],
      child: MaterialApp.router(
        title: 'شطبها',
        debugShowCheckedModeBanner: false,
        theme: buildAtelierTheme(),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: _router,
      ),
    );
  }
}
