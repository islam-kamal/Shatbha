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
}
