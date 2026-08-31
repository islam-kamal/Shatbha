import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/design_models.dart';

class DesignRemoteDatasource {
  DesignRemoteDatasource(this._dio);
  final Dio _dio;

  Future<MediaAsset> uploadMedia(String filePath, {String? fieldName}) {
    return guardDio(() async {
      final form = FormData.fromMap({
        fieldName ?? 'file': await MultipartFile.fromFile(filePath),
      });
      final res = await _dio.post<Map<String, dynamic>>('/media', data: form);
      return MediaAsset.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<List<DesignBoard>> designBoards(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/design-boards',
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
        '/projects/$projectId/design-boards',
        data: body,
      );
      return DesignBoard.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<List<InspirationItem>> inspiration(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/inspiration',
      );
      return jsonList(res.data, InspirationItem.fromJson);
    });
  }

  Future<InspirationItem> createInspiration(
    int projectId,
    Map<String, dynamic> body,
  ) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/inspiration',
        data: body,
      );
      return InspirationItem.fromJson(
        res.data!['data'] as Map<String, dynamic>,
      );
    });
  }

  Future<List<FloorPlan>> floorPlans(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/floor-plans',
      );
      return jsonList(res.data, FloorPlan.fromJson);
    });
  }

  Future<FloorPlan> createFloorPlan(
    int projectId,
    Map<String, dynamic> body,
  ) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/floor-plans',
        data: body,
      );
      return FloorPlan.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<List<BoqLine>> boqLines(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/boq-lines',
      );
      return jsonList(res.data, BoqLine.fromJson);
    });
  }

  Future<BoqLine> createBoqLine(int projectId, Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/boq-lines',
        data: body,
      );
      return BoqLine.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }
}
