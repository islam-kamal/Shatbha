import '../../../../core/utils/json.dart';

class ProjectTask {
  const ProjectTask({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.status = 'pending',
    this.assignee,
    this.dueDate,
    this.priority,
  });

  final int id;
  final int projectId;
  final String title;
  final String? description;
  final String status;
  final String? assignee;
  final String? dueDate;
  final String? priority;

  factory ProjectTask.fromJson(Map<String, dynamic> json) => ProjectTask(
        id: json['id'] as int,
        projectId: json['project_id'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        status: json['status'] as String? ?? 'pending',
        assignee: json['assignee'] as String?,
        dueDate: json['due_date'] != null ? jsonDate(json['due_date']) : null,
        priority: json['priority'] as String?,
      );
}

class ProjectMilestone {
  const ProjectMilestone({
    required this.id,
    required this.projectId,
    required this.title,
    this.targetDate,
    this.status = 'pending',
  });

  final int id;
  final int projectId;
  final String title;
  final String? targetDate;
  final String status;

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) =>
      ProjectMilestone(
        id: json['id'] as int,
        projectId: json['project_id'] as int,
        title: json['title'] as String,
        targetDate: json['target_date'] != null
            ? jsonDate(json['target_date'])
            : null,
        status: json['status'] as String? ?? 'pending',
      );
}

class TimelineEvent {
  const TimelineEvent({
    required this.id,
    required this.projectId,
    required this.title,
    this.eventDate,
    this.description,
    this.eventType,
    this.mediaUrl,
  });

  final int id;
  final int projectId;
  final String title;
  final String? eventDate;
  final String? description;
  final String? eventType;
  final String? mediaUrl;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) => TimelineEvent(
        id: json['id'] as int,
        projectId: json['project_id'] as int,
        title: json['title'] as String,
        eventDate:
            json['event_date'] != null ? jsonDate(json['event_date']) : null,
        description: json['description'] as String?,
        eventType: json['event_type'] as String?,
        mediaUrl: json['media_url'] as String? ??
            (json['media'] is Map ? json['media']['url'] as String? : null),
      );
}

class BudgetLine {
  const BudgetLine({
    required this.id,
    required this.projectId,
    required this.category,
    this.description,
    this.plannedAmount = '0.00',
    this.actualAmount = '0.00',
  });

  final int id;
  final int projectId;
  final String category;
  final String? description;
  final String plannedAmount;
  final String actualAmount;

  factory BudgetLine.fromJson(Map<String, dynamic> json) => BudgetLine(
        id: json['id'] as int,
        projectId: json['project_id'] as int,
        category: json['category'] as String,
        description: json['description'] as String?,
        plannedAmount: jsonMoney(json['planned_amount'] ?? json['amount']),
        actualAmount: jsonMoney(json['actual_amount']),
      );
}
