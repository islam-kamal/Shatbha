import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../../../design/data/models/design_models.dart';
import '../models/client_models.dart';

class ClientRemoteDatasource {
  ClientRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<ClientProject>> projects() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/client/projects');
      return jsonList(res.data, ClientProject.fromJson);
    });
  }

  Future<ClientProject> project(int id) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/client/projects/$id');
      return ClientProject.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<ClientDesignPackage> designPackage(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/client/projects/$projectId/design',
      );
      return ClientDesignPackage.fromJson(
        res.data!['data'] as Map<String, dynamic>,
      );
    });
  }

  Future<ClientProject> approveDesign(int projectId) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/client/projects/$projectId/design/approve',
      );
      return ClientProject.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<ClientProject> rejectDesign(int projectId, String reason) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/client/projects/$projectId/design/reject',
        data: {'reason': reason},
      );
      return ClientProject.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<DesignPlanComment> addPlanComment(
    int projectId,
    int planId,
    String body,
  ) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/client/projects/$projectId/design/plans/$planId/comments',
        data: {'body': body},
      );
      return DesignPlanComment.fromJson(
        res.data!['data'] as Map<String, dynamic>,
      );
    });
  }
}
