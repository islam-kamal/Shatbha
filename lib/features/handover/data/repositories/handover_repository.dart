import '../datasources/handover_remote_datasource.dart';
import '../models/handover_models.dart';

class HandoverRepository {
  HandoverRepository(this._api);
  final HandoverRemoteDatasource _api;

  Future<List<DeliveryMilestone>> deliveryMilestones(int projectId) =>
      _api.deliveryMilestones(projectId);

  Future<List<SnagItem>> snagItems(int projectId) => _api.snagItems(projectId);

  Future<SnagItem> createSnag(int projectId, Map<String, dynamic> body) =>
      _api.createSnagItem(projectId, body);

  Future<SnagItem> resolveSnag(int projectId, int snagId) =>
      _api.resolveSnag(projectId, snagId);

  Future<List<HandoverChecklistItem>> checklist(int projectId) =>
      _api.checklist(projectId);

  Future<HandoverChecklistItem> updateChecklist(
    int projectId,
    int itemId,
    Map<String, dynamic> body,
  ) =>
      _api.updateChecklistItem(projectId, itemId, body);

  Future<List<SignOff>> signOffs(int projectId) => _api.signOffs(projectId);

  Future<SignOff> signOff(int projectId, Map<String, dynamic> body) =>
      _api.createSignOff(projectId, body);

  Future<HandoverSummary> complete(int projectId, Map<String, dynamic> body) =>
      _api.completeHandover(projectId, body);
}
