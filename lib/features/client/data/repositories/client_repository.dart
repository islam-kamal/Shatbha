import '../../../design/data/models/design_models.dart';
import '../datasources/client_remote_datasource.dart';
import '../models/client_models.dart';

class ClientRepository {
  ClientRepository(this._api);
  final ClientRemoteDatasource _api;

  Future<List<ClientProject>> projects() => _api.projects();

  Future<ClientProject> project(int id) => _api.project(id);

  Future<ClientDesignPackage> designPackage(int projectId) =>
      _api.designPackage(projectId);

  Future<ClientProject> approveDesign(int projectId) =>
      _api.approveDesign(projectId);

  Future<ClientProject> rejectDesign(int projectId, String reason) =>
      _api.rejectDesign(projectId, reason);

  Future<DesignPlanComment> addPlanComment(
    int projectId,
    int planId,
    String body,
  ) =>
      _api.addPlanComment(projectId, planId, body);
}
