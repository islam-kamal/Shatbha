import '../datasources/design_remote_datasource.dart';
import '../models/design_models.dart';

class DesignRepository {
  DesignRepository(this._api);
  final DesignRemoteDatasource _api;

  Future<MediaAsset> uploadMedia(String filePath) => _api.uploadMedia(filePath);

  Future<List<DesignBoard>> designBoards(int projectId) =>
      _api.designBoards(projectId);

  Future<DesignBoard> createDesignBoard(
    int projectId,
    Map<String, dynamic> body,
  ) =>
      _api.createDesignBoard(projectId, body);

  Future<List<InspirationItem>> inspiration(int projectId) =>
      _api.inspiration(projectId);

  Future<InspirationItem> createInspiration(
    int projectId,
    Map<String, dynamic> body,
  ) =>
      _api.createInspiration(projectId, body);

  Future<List<FloorPlan>> floorPlans(int projectId) =>
      _api.floorPlans(projectId);

  Future<FloorPlan> createFloorPlan(
    int projectId,
    Map<String, dynamic> body,
  ) =>
      _api.createFloorPlan(projectId, body);

  Future<List<BoqLine>> boqLines(int projectId) => _api.boqLines(projectId);

  Future<BoqLine> createBoqLine(int projectId, Map<String, dynamic> body) =>
      _api.createBoqLine(projectId, body);
}
