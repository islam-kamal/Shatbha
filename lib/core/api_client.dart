import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/app_log.dart';
import '../core/env.dart';
import '../core/failures.dart';

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
        AppLog.d(
          '→ ${options.method} ${options.uri}',
          tag: 'http',
        );
        handler.next(options);
      },
      onResponse: (response, handler) {
        AppLog.d(
          '← ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
          tag: 'http',
        );
        handler.next(response);
      },
      onError: (error, handler) {
        AppLog.e(
          '${error.requestOptions.method} ${error.requestOptions.uri} '
          '(${error.type.name}, status=${error.response?.statusCode})',
          tag: 'http',
          error: error.message,
        );
        handler.next(error);
      },
    ),
  );
  return dio;
}

Failure mapDio(DioException error) {
  AppLog.e('mapDio ${error.type.name}', tag: 'http', error: error.message);
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
