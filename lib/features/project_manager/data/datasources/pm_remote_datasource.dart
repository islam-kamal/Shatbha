import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/pm_models.dart';

class PmRemoteDatasource {
  PmRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<ProjectTask>> tasks(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/tasks',
      );
      return jsonList(res.data, ProjectTask.fromJson);
    });
  }

  Future<ProjectTask> createTask(int projectId, Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/tasks',
        data: body,
      );
      return ProjectTask.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<ProjectTask> updateTask(
    int projectId,
    int taskId,
    Map<String, dynamic> body,
  ) {
    return guardDio(() async {
      final res = await _dio.put<Map<String, dynamic>>(
        '/projects/$projectId/pm/tasks/$taskId',
        data: body,
      );
      return ProjectTask.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<List<ProjectMilestone>> milestones(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/milestones',
      );
      return jsonList(res.data, ProjectMilestone.fromJson);
    });
  }

  Future<List<TimelineEvent>> timelineEvents(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/timeline-events',
      );
      return jsonList(res.data, TimelineEvent.fromJson);
    });
  }

  Future<TimelineEvent> createTimelineEvent(
    int projectId,
    Map<String, dynamic> body,
  ) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/timeline-events',
        data: body,
      );
      return TimelineEvent.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<List<BudgetLine>> budget(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId/budget',
      );
      return jsonList(res.data, BudgetLine.fromJson);
    });
  }

  Future<BudgetLine> createBudgetLine(int projectId, Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/projects/$projectId/budget',
        data: body,
      );
      return BudgetLine.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }
}
