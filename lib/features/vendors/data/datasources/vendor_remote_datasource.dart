import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/vendor_models.dart';

class VendorRemoteDatasource {
  VendorRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<Vendor>> list({String? type}) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/vendors',
        queryParameters: {if (type != null) 'type': type},
      );
      return jsonList(res.data, Vendor.fromJson);
    });
  }

  Future<Vendor> get(int id) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/vendors/$id');
      return Vendor.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<List<Review>> reviews({int? vendorId}) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/reviews',
        queryParameters: {if (vendorId != null) 'vendor_id': vendorId},
      );
      return jsonList(res.data, Review.fromJson);
    });
  }

  Future<Review> createReview(Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>('/reviews', data: body);
      return Review.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }
}
