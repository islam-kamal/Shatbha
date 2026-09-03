import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/auth_models.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> login(String email, String password) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/login',
        data: {'email': email, 'password': password},
      );
      return res.data!;
    });
  }

  Future<Map<String, dynamic>> vendorLogin(String email, String password) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/vendor/login',
        data: {'email': email, 'password': password},
      );
      return res.data!;
    });
  }

  Future<Map<String, dynamic>> clientLogin(String email, String password) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/client/login',
        data: {'email': email, 'password': password},
      );
      return res.data!;
    });
  }

  Future<AuthUser> clientMe() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/client/me');
      return AuthUser.fromClientJson(
        res.data!['client'] as Map<String, dynamic>,
      );
    });
  }

  Future<List<Map<String, dynamic>>> clientProjects() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/client/projects');
      final data = res.data!['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return const [];
    });
  }

  Future<AuthUser> me() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/me');
      return AuthUser.fromJson(res.data!['user'] as Map<String, dynamic>);
    });
  }

  Future<void> logout() {
    return guardDio(() => _dio.post<void>('/logout'));
  }
}
