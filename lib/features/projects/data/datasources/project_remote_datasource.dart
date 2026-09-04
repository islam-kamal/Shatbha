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

  Future<List<Map<String, dynamic>>> members(int projectId) {
    return guardDio(() async {
      final res =
          await _dio.get<Map<String, dynamic>>('/projects/$projectId/members');
      return ((res.data!['data'] as List?) ?? []).cast<Map<String, dynamic>>();
    });
  }

  Future<Map<String, dynamic>> addMember(
    int projectId,
    Map<String, dynamic> body,
  ) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/members',
        data: body,
      );
      return res.data!['data'] as Map<String, dynamic>;
    });
  }

  Future<void> removeMember(int projectId, int memberId) {
    return guardDio(() async {
      await _dio.delete('/projects/$projectId/members/$memberId');
    });
  }

  Future<Map<String, dynamic>> inviteClient(
    int customerId,
    Map<String, dynamic> body,
  ) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/customers/$customerId/invite-client',
        data: body,
      );
      return res.data!['data'] as Map<String, dynamic>;
    });
  }

  Future<List<Map<String, dynamic>>> requests(int projectId) {
    return guardDio(() async {
      final res = await _dio
          .get<Map<String, dynamic>>('/projects/$projectId/requests');
      return ((res.data!['data'] as List?) ?? []).cast<Map<String, dynamic>>();
    });
  }

  Future<Map<String, dynamic>> createRequest(
    int projectId,
    Map<String, dynamic> body,
  ) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/requests',
        data: body,
      );
      return res.data!['data'] as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> getRequest(int projectId, int requestId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/requests/$requestId',
      );
      return res.data!['data'] as Map<String, dynamic>;
    });
  }

  Future<void> decideRequest(
    int projectId,
    int requestId, {
    required bool approve,
    String? note,
  }) {
    return guardDio(() async {
      final path = approve ? 'approve' : 'reject';
      await _dio.post(
        '/projects/$projectId/requests/$requestId/$path',
        data: {if (note != null) 'note': note},
      );
    });
  }

  Future<void> commentRequest(int projectId, int requestId, String body) {
    return guardDio(() async {
      await _dio.post(
        '/projects/$projectId/requests/$requestId/comments',
        data: {'body': body},
      );
    });
  }
}
