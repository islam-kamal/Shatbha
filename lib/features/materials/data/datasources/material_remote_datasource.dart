import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/material_models.dart';

class MaterialRemoteDatasource {
  MaterialRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<Product>> products({int? supplierId}) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/products',
        queryParameters: {if (supplierId != null) 'supplier_id': supplierId},
      );
      return jsonList(res.data, Product.fromJson);
    });
  }

  Future<List<Product>> search(String query) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/products/search',
        queryParameters: {'q': query},
      );
      return jsonList(res.data, Product.fromJson);
    });
  }

  Future<Product> createProduct(Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>('/products', data: body);
      return Product.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<List<ProjectMaterial>> projectMaterials(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/materials',
      );
      return jsonList(res.data, ProjectMaterial.fromJson);
    });
  }

  Future<ProjectMaterial> addProjectMaterial(
    int projectId,
    Map<String, dynamic> body,
  ) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/materials',
        data: body,
      );
      return ProjectMaterial.fromJson(
        res.data!['data'] as Map<String, dynamic>,
      );
    });
  }
}
