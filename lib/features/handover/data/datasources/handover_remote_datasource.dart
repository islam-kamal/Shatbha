import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/handover_models.dart';

class HandoverRemoteDatasource {
  HandoverRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<DeliveryMilestone>> deliveryMilestones(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/delivery-milestones',
      );
      return jsonList(res.data, DeliveryMilestone.fromJson);
    });
  }

  Future<List<SnagItem>> snagItems(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/snag-items',
      );
      return jsonList(res.data, SnagItem.fromJson);
    });
  }

  Future<SnagItem> createSnagItem(int projectId, Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/snag-items',
        data: body,
      );
      return SnagItem.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<List<HandoverChecklistItem>> checklist(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/handover-checklist',
      );
      return jsonList(res.data, HandoverChecklistItem.fromJson);
    });
  }

  Future<HandoverChecklistItem> updateChecklistItem(
    int projectId,
    Map<String, dynamic> body,
  ) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/handover-checklist',
        data: body,
      );
      return HandoverChecklistItem.fromJson(
        res.data!['data'] as Map<String, dynamic>,
      );
    });
  }

  Future<List<SignOff>> signOffs(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/sign-offs',
      );
      return jsonList(res.data, SignOff.fromJson);
    });
  }

  Future<SignOff> createSignOff(int projectId, Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/sign-offs',
        data: body,
      );
      return SignOff.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<HandoverSummary> completeHandover(int projectId, Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/handover',
        data: body,
      );
      return HandoverSummary.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }
}
