import '../../../../core/utils/json.dart';

class DeliveryMilestone {
  const DeliveryMilestone({
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

  factory DeliveryMilestone.fromJson(Map<String, dynamic> json) {
    final isDone = json['is_done'] as bool? ?? false;
    return DeliveryMilestone(
      id: jsonInt(json['id']),
      projectId: jsonInt(json['project_id']),
      title: json['title'] as String? ?? '',
      targetDate: json['target_date'] != null
          ? jsonDate(json['target_date'])
          : null,
      status: json['status'] as String? ?? (isDone ? 'done' : 'pending'),
    );
  }
}

class SnagItem {
  const SnagItem({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.status = 'open',
    this.location,
  });

  final int id;
  final int projectId;
  final String title;
  final String? description;
  final String status;
  final String? location;

  factory SnagItem.fromJson(Map<String, dynamic> json) => SnagItem(
        id: jsonInt(json['id']),
        projectId: jsonInt(json['project_id']),
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        status: json['status'] as String? ?? 'open',
        location: json['location'] as String?,
      );
}

class HandoverChecklistItem {
  const HandoverChecklistItem({
    required this.id,
    required this.projectId,
    required this.label,
    this.isChecked = false,
    this.notes,
  });

  final int id;
  final int projectId;
  final String label;
  final bool isChecked;
  final String? notes;

  factory HandoverChecklistItem.fromJson(Map<String, dynamic> json) =>
      HandoverChecklistItem(
        id: jsonInt(json['id']),
        projectId: jsonInt(json['project_id']),
        label: json['item'] as String? ??
            json['label'] as String? ??
            json['title'] as String? ??
            '',
        isChecked: json['is_checked'] as bool? ?? false,
        notes: json['notes'] as String?,
      );
}

class SignOff {
  const SignOff({
    required this.id,
    required this.projectId,
    required this.partyName,
    this.role,
    this.signedAt,
    this.notes,
  });

  final int id;
  final int projectId;
  final String partyName;
  final String? role;
  final String? signedAt;
  final String? notes;

  factory SignOff.fromJson(Map<String, dynamic> json) => SignOff(
        id: jsonInt(json['id']),
        projectId: jsonInt(json['project_id']),
        partyName: json['signed_by'] as String? ??
            json['party_name'] as String? ??
            json['name'] as String? ??
            '',
        role: json['role'] as String?,
        signedAt: json['signed_at'] != null
            ? jsonDate(json['signed_at'])
            : null,
        notes: json['notes'] as String?,
      );
}

class HandoverSummary {
  const HandoverSummary({
    required this.projectId,
    this.completedAt,
    this.status = 'pending',
  });

  final int projectId;
  final String? completedAt;
  final String status;

  bool get isComplete =>
      status == 'handed_over' ||
      status == 'completed' ||
      status == 'done';

  factory HandoverSummary.fromJson(Map<String, dynamic> json) =>
      HandoverSummary(
        projectId: jsonInt(json['project_id'] ?? json['id']),
        completedAt: json['completed_at'] != null
            ? jsonDate(json['completed_at'])
            : (json['updated_at'] != null ? jsonDate(json['updated_at']) : null),
        status: json['status'] as String? ?? 'pending',
      );
}
