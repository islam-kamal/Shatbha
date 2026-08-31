import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/procurement_models.dart';

class ProcurementRemoteDatasource {
  ProcurementRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<PurchaseOrder>> purchaseOrders({int? projectId}) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/purchase-orders',
        queryParameters: {
          if (projectId != null) 'project_id': projectId,
        },
      );
      return jsonList(res.data, PurchaseOrder.fromJson);
    });
  }

  Future<PurchaseOrder> createPurchaseOrder(Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/purchase-orders',
        data: body,
      );
      return PurchaseOrder.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<GoodsReceipt> receiveGoods(int poId, Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/purchase-orders/$poId/receive',
        data: body,
      );
      return GoodsReceipt.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }
}
