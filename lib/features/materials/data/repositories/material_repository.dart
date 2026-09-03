import '../datasources/material_remote_datasource.dart';
import '../models/material_models.dart';

class MaterialRepository {
  MaterialRepository(this._api);
  final MaterialRemoteDatasource _api;

  Future<List<Product>> products({int? supplierId}) =>
      _api.products(supplierId: supplierId);

  Future<List<Product>> search(String query) => _api.search(query);

  Future<Product> createProduct(Map<String, dynamic> body) =>
      _api.createProduct(body);

  Future<List<Product>> vendorProducts() => _api.vendorProducts();

  Future<Product> createVendorProduct(Map<String, dynamic> body) =>
      _api.createVendorProduct(body);

  Future<Product> updateVendorProduct(int id, Map<String, dynamic> body) =>
      _api.updateVendorProduct(id, body);

  Future<void> deleteVendorProduct(int id) => _api.deleteVendorProduct(id);

  Future<Map<String, dynamic>> generatePo(int projectId) =>
      _api.generatePo(projectId);

  Future<List<ProjectMaterial>> projectMaterials(int projectId) =>
      _api.projectMaterials(projectId);

  Future<ProjectMaterial> addToProject(
    int projectId,
    Map<String, dynamic> body,
  ) =>
      _api.addProjectMaterial(projectId, body);
}
