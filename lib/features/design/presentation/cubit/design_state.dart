import 'package:equatable/equatable.dart';

import '../../data/models/design_models.dart';

enum DesignTab { moodBoard, floorPlans, boq }

class DesignState extends Equatable {
  const DesignState({
    this.loading = false,
    this.tab = DesignTab.moodBoard,
    this.designBoards = const [],
    this.inspiration = const [],
    this.floorPlans = const [],
    this.boqLines = const [],
    this.error,
  });

  final bool loading;
  final DesignTab tab;
  final List<DesignBoard> designBoards;
  final List<InspirationItem> inspiration;
  final List<FloorPlan> floorPlans;
  final List<BoqLine> boqLines;
  final String? error;

  double get boqTotal => boqLines.fold(
        0,
        (s, l) => s + (double.tryParse(l.total) ?? 0),
      );

  DesignState copyWith({
    bool? loading,
    DesignTab? tab,
    List<DesignBoard>? designBoards,
    List<InspirationItem>? inspiration,
    List<FloorPlan>? floorPlans,
    List<BoqLine>? boqLines,
    String? error,
  }) {
    return DesignState(
      loading: loading ?? this.loading,
      tab: tab ?? this.tab,
      designBoards: designBoards ?? this.designBoards,
      inspiration: inspiration ?? this.inspiration,
      floorPlans: floorPlans ?? this.floorPlans,
      boqLines: boqLines ?? this.boqLines,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [loading, tab, designBoards, inspiration, floorPlans, boqLines, error];
}
