import '../../../design/data/models/design_models.dart';
import '../../../projects/data/models/project_models.dart';
import '../../../../core/utils/json.dart';

class ClientProject extends Project {
  const ClientProject({
    required super.id,
    required super.name,
    super.description,
    super.status = 'planning',
    super.address,
    super.budget = '0.00',
    super.clientName,
    super.areaSqm,
    super.createdAt,
    super.updatedAt,
    this.designStatus = 'draft',
    this.designRejectReason,
    this.progressPercent = 0,
    this.tasksDone = 0,
    this.tasksTotal = 0,
  });

  final String designStatus;
  final String? designRejectReason;
  final int progressPercent;
  final int tasksDone;
  final int tasksTotal;

  factory ClientProject.fromJson(Map<String, dynamic> json) {
    final base = Project.fromJson(json);
    return ClientProject(
      id: base.id,
      name: base.name,
      description: base.description,
      status: base.status,
      address: base.address,
      budget: base.budget,
      clientName: base.clientName,
      areaSqm: base.areaSqm,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      designStatus: json['design_status'] as String? ?? 'draft',
      designRejectReason: json['design_reject_reason'] as String?,
      progressPercent: (json['progress_percent'] as num?)?.round() ?? 0,
      tasksDone: json['tasks_done'] as int? ?? 0,
      tasksTotal: json['tasks_total'] as int? ?? 0,
    );
  }
}

class ClientDesignPackage {
  const ClientDesignPackage({
    required this.project,
    required this.designStatus,
    this.designRejectReason,
    this.boards = const [],
    this.plans = const [],
    this.boqLines = const [],
    this.boqTotal = '0.00',
    this.inspirationByRoom = const {},
  });

  final ClientProject project;
  final String designStatus;
  final String? designRejectReason;
  final List<DesignBoard> boards;
  final List<DesignPlan> plans;
  final List<BoqLine> boqLines;
  final String boqTotal;
  final Map<String, List<InspirationItem>> inspirationByRoom;

  factory ClientDesignPackage.fromJson(Map<String, dynamic> json) {
    final projectJson = json['project'] is Map<String, dynamic>
        ? json['project'] as Map<String, dynamic>
        : json;
    final boards = (json['boards'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(DesignBoard.fromJson)
            .toList() ??
        const <DesignBoard>[];
    final plans = (json['plans'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(DesignPlan.fromJson)
            .toList() ??
        const <DesignPlan>[];
    final boq = (json['boq_lines'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(BoqLine.fromJson)
            .toList() ??
        const <BoqLine>[];

    final byRoom = <String, List<InspirationItem>>{};
    final rawRooms = json['inspiration_by_room'];
    if (rawRooms is Map) {
      rawRooms.forEach((key, value) {
        if (value is List) {
          byRoom[key.toString()] = value
              .whereType<Map<String, dynamic>>()
              .map(InspirationItem.fromJson)
              .toList();
        }
      });
    } else {
      for (final board in boards) {
        for (final item in board.inspiration) {
          final room = item.room ?? 'Other';
          byRoom.putIfAbsent(room, () => []).add(item);
        }
      }
    }

    return ClientDesignPackage(
      project: ClientProject.fromJson(projectJson),
      designStatus: json['design_status'] as String? ??
          projectJson['design_status'] as String? ??
          'draft',
      designRejectReason: json['design_reject_reason'] as String?,
      boards: boards,
      plans: plans,
      boqLines: boq,
      boqTotal: jsonMoney(json['boq_total']),
      inspirationByRoom: byRoom,
    );
  }
}
