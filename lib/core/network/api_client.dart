import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/env.dart';
import '../error/failures.dart';
import '../logging/app_log.dart';

Dio createDio(FlutterSecureStorage storage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${Env.apiBaseUrl}/api/v1',
      headers: {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );
  dio.interceptors.add(_HttpLogInterceptor());
  return dio;
}

class _HttpLogInterceptor extends Interceptor {
  static const _started = 'shatbha_started_ms';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_started] = DateTime.now().millisecondsSinceEpoch;
    AppLog.i('→ ${options.method} ${options.uri}', tag: 'http');
    AppLog.d(
      'headers ${AppLog.redactHeaders(Map<String, dynamic>.from(options.headers))}',
      tag: 'http',
    );
    if (options.data != null) {
      AppLog.d('body ${AppLog.redact(options.data)}', tag: 'http');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final ms = _elapsed(response.requestOptions);
    AppLog.i(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri} (${ms}ms)',
      tag: 'http',
    );
    AppLog.t('body ${AppLog.redact(response.data)}', tag: 'http');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ms = _elapsed(err.requestOptions);
    AppLog.e(
      '${err.requestOptions.method} ${err.requestOptions.uri} '
      '(${err.type.name}, status=${err.response?.statusCode}, ${ms}ms)',
      tag: 'http',
      error: err.message,
    );
    if (err.response?.data != null) {
      AppLog.d('error body ${AppLog.redact(err.response?.data)}', tag: 'http');
    }
    handler.next(err);
  }

  int _elapsed(RequestOptions options) {
    final started = options.extra[_started];
    if (started is! int) return 0;
    return DateTime.now().millisecondsSinceEpoch - started;
  }
}

Failure mapDio(DioException error) {
  AppLog.w('mapDio ${error.type.name} → ${error.response?.statusCode}', tag: 'http');
  if (error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.unknown) {
    return const OfflineFailure();
  }
  final status = error.response?.statusCode;
  if (status == 401) return const UnauthorizedFailure();
  if (status == 403) {
    final message = error.response?.data is Map
        ? (error.response!.data['message'] as String? ??
            'هذا التقرير متاح للمدير فقط')
        : 'هذا التقرير متاح للمدير فقط';
    return ForbiddenFailure(message);
  }
  if (status == 422) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return ValidationFailure(data['message'].toString());
    }
    return const ValidationFailure('تحقق من الحقول المدخلة');
  }
  final message = error.response?.data is Map
      ? (error.response!.data['message'] as String? ?? 'تعذر إكمال الطلب')
      : 'تعذر إكمال الطلب';
  return ServerFailure(message);
}

Future<T> guardDio<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on DioException catch (e) {
    throw mapDio(e);
  }
}
