import 'package:flutter_bloc/flutter_bloc.dart';

import '../logging/app_log.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    AppLog.d('create ${bloc.runtimeType}', tag: 'bloc');
    super.onCreate(bloc);
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    AppLog.d('${bloc.runtimeType} ← $event', tag: 'bloc');
    super.onEvent(bloc, event);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    AppLog.d(
      '${bloc.runtimeType} ${change.currentState} → ${change.nextState}',
      tag: 'bloc',
    );
    super.onChange(bloc, change);
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    AppLog.t(
      '${bloc.runtimeType} ${transition.event} → ${transition.nextState}',
      tag: 'bloc',
    );
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLog.e(
      '${bloc.runtimeType}',
      tag: 'bloc',
      error: error,
      stack: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    AppLog.d('close ${bloc.runtimeType}', tag: 'bloc');
    super.onClose(bloc);
  }
}
