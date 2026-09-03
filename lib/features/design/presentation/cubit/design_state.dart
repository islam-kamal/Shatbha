import 'package:equatable/equatable.dart';

import '../../data/models/design_models.dart';

enum DesignTab { moodBoard, floorPlans, boq }

class DesignState extends Equatable {
  const DesignState({
    this.loading = false,
    this.submitting = false,
    this.tab = DesignTab.moodBoard,
    this.designStatus = 'draft',
    this.designRejectReason,
    this.designBoards = const [],
    this.inspiration = const [],
    this.plans = const [],
    this.boqLines = const [],
    this.planTypeFilter,
    this.error,
  });

  final bool loading;
  final bool submitting;
  final DesignTab tab;
  final String designStatus;
  final String? designRejectReason;
  final List<DesignBoard> designBoards;
  final List<InspirationItem> inspiration;
  final List<DesignPlan> plans;
  final List<BoqLine> boqLines;
  final String? planTypeFilter;
  final String? error;

  bool get canEdit =>
      designStatus == 'draft' || designStatus == 'rejected';

  DesignBoard? get board =>
      designBoards.isEmpty ? null : designBoards.first;

  double get boqTotal => boqLines.fold(
        0,
        (s, l) => s + (double.tryParse(l.total) ?? 0),
      );

  List<DesignPlan> get filteredPlans {
    final f = planTypeFilter;
    if (f == null || f.isEmpty) return plans;
    return plans.where((p) => p.type == f).toList();
  }

  Map<String, List<InspirationItem>> get inspirationByRoom {
    final map = <String, List<InspirationItem>>{};
    for (final room in kDesignRooms) {
      map[room] = [];
    }
    for (final item in inspiration) {
      final room = item.room ?? 'Other';
      map.putIfAbsent(room, () => []);
      map[room]!.add(item);
    }
    return map;
  }

  DesignState copyWith({
    bool? loading,
    bool? submitting,
    DesignTab? tab,
    String? designStatus,
    String? designRejectReason,
    bool clearRejectReason = false,
    List<DesignBoard>? designBoards,
    List<InspirationItem>? inspiration,
    List<DesignPlan>? plans,
    List<BoqLine>? boqLines,
    String? planTypeFilter,
    bool clearPlanTypeFilter = false,
    String? error,
  }) {
    return DesignState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      tab: tab ?? this.tab,
      designStatus: designStatus ?? this.designStatus,
      designRejectReason: clearRejectReason
          ? null
          : (designRejectReason ?? this.designRejectReason),
      designBoards: designBoards ?? this.designBoards,
      inspiration: inspiration ?? this.inspiration,
      plans: plans ?? this.plans,
      boqLines: boqLines ?? this.boqLines,
      planTypeFilter:
          clearPlanTypeFilter ? null : (planTypeFilter ?? this.planTypeFilter),
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        submitting,
        tab,
        designStatus,
        designRejectReason,
        designBoards,
        inspiration,
        plans,
        boqLines,
        planTypeFilter,
        error,
      ];
}
