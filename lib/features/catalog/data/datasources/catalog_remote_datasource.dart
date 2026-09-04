import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/catalog_models.dart';

class CatalogRemoteDatasource {
  CatalogRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<Party>> parties(String type) {
    return guardDio(() async {
      final path = type == 'contractor' ? '/contractors' : '/customers';
      final res = await _dio.get<Map<String, dynamic>>(path);
      return jsonList(res.data, Party.fromJson);
    });
  }

  Future<Party> createParty(Map<String, dynamic> body) {
    return guardDio(() async {
      final path = body['type'] == 'contractor' ? '/contractors' : '/customers';
      final res = await _dio.post<Map<String, dynamic>>(path, data: body);
      return Party.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<Party> updateParty(int id, Map<String, dynamic> body) {
    return guardDio(() async {
      final res =
          await _dio.put<Map<String, dynamic>>('/parties/$id', data: body);
      return Party.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<void> deleteParty(int id) {
    return guardDio(() async {
      await _dio.delete('/parties/$id');
    });
  }

  Future<List<NamedItem>> workTypes() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/work-types');
      return jsonList(res.data, NamedItem.fromJson);
    });
  }

  Future<NamedItem> createWorkType(String name) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/work-types',
        data: {'name': name},
      );
      return NamedItem.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<List<NamedItem>> expenseCategories() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/expense-categories');
      return jsonList(res.data, NamedItem.fromJson);
    });
  }

  Future<NamedItem> createExpenseCategory(String name) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/expense-categories',
        data: {'name': name},
      );
      return NamedItem.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }
}
