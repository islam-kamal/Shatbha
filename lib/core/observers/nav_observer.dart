import 'package:flutter/material.dart';

import '../logging/app_log.dart';

class AppNavObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLog.i(
      'push ${_name(route)} ← ${_name(previousRoute)}',
      tag: 'nav',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLog.i(
      'pop ${_name(route)} → ${_name(previousRoute)}',
      tag: 'nav',
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    AppLog.i(
      'replace ${_name(oldRoute)} → ${_name(newRoute)}',
      tag: 'nav',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLog.d('remove ${_name(route)}', tag: 'nav');
  }

  String _name(Route<dynamic>? route) =>
      route?.settings.name ?? route?.settings.arguments?.toString() ?? '(unnamed)';
}
