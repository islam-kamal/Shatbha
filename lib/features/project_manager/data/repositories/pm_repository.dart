import '../datasources/pm_remote_datasource.dart';
import '../models/pm_models.dart';

class PmRepository {
  PmRepository(this._api);
  final PmRemoteDatasource _api;

  Future<List<ProjectTask>> tasks(int projectId) => _api.tasks(projectId);

  Future<ProjectTask> createTask(int projectId, Map<String, dynamic> body) =>
      _api.createTask(projectId, body);

  Future<ProjectTask> updateTask(
    int projectId,
    int taskId,
    Map<String, dynamic> body,
  ) =>
      _api.updateTask(projectId, taskId, body);

  Future<List<ProjectMilestone>> milestones(int projectId) =>
      _api.milestones(projectId);

  Future<List<TimelineEvent>> timelineEvents(int projectId) =>
      _api.timelineEvents(projectId);

  Future<TimelineEvent> createTimelineEvent(
    int projectId,
    Map<String, dynamic> body,
  ) =>
      _api.createTimelineEvent(projectId, body);

  Future<List<BudgetLine>> budget(int projectId) => _api.budget(projectId);

  Future<BudgetLine> createBudgetLine(
    int projectId,
    Map<String, dynamic> body,
  ) =>
      _api.createBudgetLine(projectId, body);
}
