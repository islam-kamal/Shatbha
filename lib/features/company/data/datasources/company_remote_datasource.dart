import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/auth_models.dart';

class CompanyRemoteDatasource {
  CompanyRemoteDatasource(this._dio);
  final Dio _dio;

  Future<CompanyInfo> get() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/company');
      return CompanyInfo.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<CompanyInfo> update(Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.put<Map<String, dynamic>>('/company', data: body);
      return CompanyInfo.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }
}
