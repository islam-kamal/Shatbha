import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/quote_models.dart';

class QuoteRemoteDatasource {
  QuoteRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<QuoteRequest>> list({int? projectId}) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/quotes',
        queryParameters: {if (projectId != null) 'project_id': projectId},
      );
      return jsonList(res.data, QuoteRequest.fromJson);
    });
  }

  Future<QuoteRequest> create(Map<String, dynamic> body) {
    return guardDio(() async {
      final res =
          await _dio.post<Map<String, dynamic>>('/quotes', data: body);
      return QuoteRequest.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<QuoteRequest> respond(int id, Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/quotes/$id/respond',
        data: body,
      );
      return QuoteRequest.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<QuoteRequest> accept(int id) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/quotes/$id/accept',
      );
      return QuoteRequest.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<QuoteRequest> reject(int id) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/quotes/$id/reject',
      );
      return QuoteRequest.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<QuoteRequest> get(int id) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/quotes/$id');
      return QuoteRequest.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }
}
