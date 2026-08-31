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

  Future<List<ProjectMaterial>> projectMaterials(int projectId) =>
      _api.projectMaterials(projectId);

  Future<ProjectMaterial> addToProject(
    int projectId,
    Map<String, dynamic> body,
  ) =>
      _api.addProjectMaterial(projectId, body);
}
