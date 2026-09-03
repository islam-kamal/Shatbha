import '../datasources/design_remote_datasource.dart';
import '../models/design_models.dart';

class DesignRepository {
  DesignRepository(this._api);
  final DesignRemoteDatasource _api;

  Future<String> projectDesignStatus(int projectId) =>
      _api.projectDesignStatus(projectId);

  Future<String?> projectDesignRejectReason(int projectId) =>
      _api.projectDesignRejectReason(projectId);

  Future<List<DesignBoard>> designBoards(int projectId) =>
      _api.designBoards(projectId);

  Future<DesignBoard> createDesignBoard(
    int projectId,
    Map<String, dynamic> body,
  ) =>
      _api.createDesignBoard(projectId, body);

  Future<DesignBoard> updateDesignBoard(
    int projectId,
    int boardId,
    Map<String, dynamic> body,
  ) =>
      _api.updateDesignBoard(projectId, boardId, body);

  Future<InspirationItem> createInspiration(
    int projectId,
    int boardId,
    Map<String, dynamic> body,
  ) =>
      _api.createInspiration(projectId, boardId, body);

  Future<List<DesignPlan>> plans(int projectId, {String? type}) =>
      _api.plans(projectId, type: type);

  Future<DesignPlan> createPlan(int projectId, Map<String, dynamic> body) =>
      _api.createPlan(projectId, body);

  Future<DesignPlan> updatePlan(
    int projectId,
    int planId,
    Map<String, dynamic> body,
  ) =>
      _api.updatePlan(projectId, planId, body);

  Future<DesignPlan> submitPlan(int projectId, int planId) =>
      _api.submitPlan(projectId, planId);

  Future<DesignPlan> approvePlan(int projectId, int planId) =>
      _api.approvePlan(projectId, planId);

  Future<DesignPlan> rejectPlan(int projectId, int planId) =>
      _api.rejectPlan(projectId, planId);

  Future<DesignPlanComment> addPlanComment(
    int projectId,
    int planId,
    String body,
  ) =>
      _api.addPlanComment(projectId, planId, body);

  Future<List<BoqLine>> boqLines(int projectId) => _api.boqLines(projectId);

  Future<BoqLine> createBoqLine(int projectId, Map<String, dynamic> body) =>
      _api.createBoqLine(projectId, body);

  Future<BoqLine> createBoqFromInspiration(
    int projectId,
    Map<String, dynamic> body,
  ) =>
      _api.createBoqFromInspiration(projectId, body);

  Future<void> deleteBoqLine(int projectId, int lineId) =>
      _api.deleteBoqLine(projectId, lineId);

  Future<void> submitToClient(int projectId) => _api.submitToClient(projectId);

  // Back-compat aliases
  Future<List<DesignPlan>> floorPlans(int projectId) => plans(projectId);

  Future<DesignPlan> createFloorPlan(
    int projectId,
    Map<String, dynamic> body,
  ) {
    final payload = Map<String, dynamic>.from(body);
    payload.putIfAbsent('type', () => 'floor');
    if (payload['title'] == null && payload['room'] != null) {
      payload['title'] = payload['room'];
    }
    return createPlan(projectId, payload);
  }
}
