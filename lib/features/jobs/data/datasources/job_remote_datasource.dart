import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/job_models.dart';

class JobRemoteDatasource {
  JobRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<ContractorJob>> jobs() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/jobs');
      return jsonList(res.data, ContractorJob.fromJson);
    });
  }

  Future<ContractorJob> createJob(Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>('/jobs', data: body);
      return ContractorJob.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<ContractorJob> payJob(int jobId, Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/jobs/$jobId/payments',
        data: body,
      );
      return ContractorJob.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }
}
