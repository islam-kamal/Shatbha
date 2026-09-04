import '../datasources/project_remote_datasource.dart';
import '../models/project_models.dart';

class ProjectRepository {
  ProjectRepository(this._api);
  final ProjectRemoteDatasource _api;

  Future<List<Project>> list() => _api.list();

  Future<Project> get(int id) => _api.get(id);

  Future<Project> create(Map<String, dynamic> body) =>
      _api.create(Project.toApiBody(body));

  Future<Project> update(int id, Map<String, dynamic> body) =>
      _api.update(id, Project.toApiBody(body));

  Future<Map<String, dynamic>> financialSummary(int id) =>
      _api.financialSummary(id);

  Future<List<Map<String, dynamic>>> members(int projectId) =>
      _api.members(projectId);

  Future<Map<String, dynamic>> addMember(
    int projectId,
    Map<String, dynamic> body,
  ) =>
      _api.addMember(projectId, body);

  Future<void> removeMember(int projectId, int memberId) =>
      _api.removeMember(projectId, memberId);

  Future<Map<String, dynamic>> inviteClient(
    int customerId,
    Map<String, dynamic> body,
  ) =>
      _api.inviteClient(customerId, body);

  Future<List<Map<String, dynamic>>> requests(int projectId) =>
      _api.requests(projectId);

  Future<Map<String, dynamic>> createRequest(
    int projectId,
    Map<String, dynamic> body,
  ) =>
      _api.createRequest(projectId, body);

  Future<Map<String, dynamic>> getRequest(int projectId, int requestId) =>
      _api.getRequest(projectId, requestId);

  Future<void> decideRequest(
    int projectId,
    int requestId, {
    required bool approve,
    String? note,
  }) =>
      _api.decideRequest(projectId, requestId, approve: approve, note: note);

  Future<void> commentRequest(int projectId, int requestId, String body) =>
      _api.commentRequest(projectId, requestId, body);
}
