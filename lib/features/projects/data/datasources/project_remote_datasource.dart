import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/project_models.dart';

class ProjectRemoteDatasource {
  ProjectRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<Project>> list() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/projects');
      return jsonList(res.data, Project.fromJson);
    });
  }

  Future<Project> get(int id) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/projects/$id');
      return Project.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<Project> create(Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>('/projects', data: body);
      return Project.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<Project> update(int id, Map<String, dynamic> body) {
    return guardDio(() async {
      final res =
          await _dio.put<Map<String, dynamic>>('/projects/$id', data: body);
      return Project.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<Map<String, dynamic>> financialSummary(int id) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$id/reports/summary',
      );
      return res.data!['data'] as Map<String, dynamic>;
    });
  }
}
