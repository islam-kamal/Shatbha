import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/design_models.dart';

class DesignRemoteDatasource {
  DesignRemoteDatasource(this._dio);
  final Dio _dio;

  Future<String> projectDesignStatus(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/projects/$projectId');
      final data = res.data!['data'] as Map<String, dynamic>;
      return data['design_status'] as String? ?? 'draft';
    });
  }

  Future<String?> projectDesignRejectReason(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/projects/$projectId');
      final data = res.data!['data'] as Map<String, dynamic>;
      return data['design_reject_reason'] as String?;
    });
  }

  Future<List<DesignBoard>> designBoards(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/design/boards',
      );
      return jsonList(res.data, DesignBoard.fromJson);
    });
  }

  Future<DesignBoard> createDesignBoard(
    int projectId,
    Map<String, dynamic> body,
  ) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/design/boards',
        data: body,
      );
      return DesignBoard.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<DesignBoard> updateDesignBoard(
    int projectId,
    int boardId,
    Map<String, dynamic> body,
  ) {
    return guardDio(() async {
      final res = await _dio.put<Map<String, dynamic>>(
        '/projects/$projectId/design/boards/$boardId',
        data: body,
      );
      return DesignBoard.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<InspirationItem> createInspiration(
    int projectId,
    int boardId,
    Map<String, dynamic> body,
  ) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/design/boards/$boardId/inspiration',
        data: body,
      );
      return InspirationItem.fromJson(
        res.data!['data'] as Map<String, dynamic>,
      );
    });
  }

  Future<List<DesignPlan>> plans(int projectId, {String? type}) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/design/plans',
        queryParameters: type == null ? null : {'type': type},
      );
      return jsonList(res.data, DesignPlan.fromJson);
    });
  }

  Future<DesignPlan> createPlan(int projectId, Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/design/plans',
        data: body,
      );
      return DesignPlan.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<DesignPlan> updatePlan(
    int projectId,
    int planId,
    Map<String, dynamic> body,
  ) {
    return guardDio(() async {
      final res = await _dio.put<Map<String, dynamic>>(
        '/projects/$projectId/design/plans/$planId',
        data: body,
      );
      return DesignPlan.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<DesignPlan> submitPlan(int projectId, int planId) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/design/plans/$planId/submit',
      );
      return DesignPlan.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<DesignPlan> approvePlan(int projectId, int planId) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/design/plans/$planId/approve',
      );
      return DesignPlan.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<DesignPlan> rejectPlan(int projectId, int planId) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/design/plans/$planId/reject',
      );
      return DesignPlan.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<DesignPlanComment> addPlanComment(
    int projectId,
    int planId,
    String body,
  ) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/design/plans/$planId/comments',
        data: {'body': body},
      );
      return DesignPlanComment.fromJson(
        res.data!['data'] as Map<String, dynamic>,
      );
    });
  }

  Future<List<BoqLine>> boqLines(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/design/boq',
      );
      return jsonList(res.data, BoqLine.fromJson);
    });
  }

  Future<BoqLine> createBoqLine(int projectId, Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/design/boq',
        data: body,
      );
      return BoqLine.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<BoqLine> createBoqFromInspiration(
    int projectId,
    Map<String, dynamic> body,
  ) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/design/boq/from-inspiration',
        data: body,
      );
      return BoqLine.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<void> deleteBoqLine(int projectId, int lineId) {
    return guardDio(() async {
      await _dio.delete<void>('/projects/$projectId/design/boq/$lineId');
    });
  }

  Future<void> submitToClient(int projectId) {
    return guardDio(() async {
      await _dio.post<void>('/projects/$projectId/design/submit-to-client');
    });
  }
}
