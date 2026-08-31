import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/warehouse_models.dart';

class WarehouseRemoteDatasource {
  WarehouseRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<Warehouse>> warehouses() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/warehouses');
      return jsonList(res.data, Warehouse.fromJson);
    });
  }

  Future<Warehouse> createWarehouse(Map<String, dynamic> body) {
    return guardDio(() async {
      final res =
          await _dio.post<Map<String, dynamic>>('/warehouses', data: body);
      return Warehouse.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<List<StockLevel>> stock({int? warehouseId}) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/stock',
        queryParameters: {
          if (warehouseId != null) 'warehouse_id': warehouseId,
        },
      );
      return jsonList(res.data, StockLevel.fromJson);
    });
  }

  Future<StockMovement> createMovement(Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/stock/movements',
        data: body,
      );
      return StockMovement.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<DeliveryNote> createDeliveryNote(Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/delivery-notes',
        data: body,
      );
      return DeliveryNote.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }
}
