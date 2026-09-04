import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../../../projects/data/models/project_models.dart';

class VendorProjectRemoteDatasource {
  VendorProjectRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<Project>> list() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/vendor/projects');
      return jsonList(res.data, Project.fromJson);
    });
  }

  Future<Map<String, dynamic>> show(int id) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/vendor/projects/$id');
      return res.data!['data'] as Map<String, dynamic>;
    });
  }

  Future<List<Map<String, dynamic>>> requests(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/vendor/projects/$projectId/requests',
      );
      return ((res.data!['data'] as List?) ?? []).cast<Map<String, dynamic>>();
    });
  }

  Future<void> submitResponse(int projectId, int requestId, String? note) {
    return guardDio(() async {
      await _dio.post(
        '/vendor/projects/$projectId/requests/$requestId/submit',
        data: {if (note != null) 'note': note},
      );
    });
  }

  Future<void> comment(int projectId, int requestId, String body) {
    return guardDio(() async {
      await _dio.post(
        '/vendor/projects/$projectId/requests/$requestId/comments',
        data: {'body': body},
      );
    });
  }
}
