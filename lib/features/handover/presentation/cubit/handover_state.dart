import 'package:equatable/equatable.dart';

import '../../data/models/handover_models.dart';

class HandoverState extends Equatable {
  const HandoverState({
    this.loading = false,
    this.milestones = const [],
    this.snags = const [],
    this.checklist = const [],
    this.signOffs = const [],
    this.summary,
    this.error,
    this.saving = false,
  });

  final bool loading;
  final List<DeliveryMilestone> milestones;
  final List<SnagItem> snags;
  final List<HandoverChecklistItem> checklist;
  final List<SignOff> signOffs;
  final HandoverSummary? summary;
  final String? error;
  final bool saving;

  int get openSnags => snags.where((s) => s.status == 'open').length;

  int get checkedItems => checklist.where((c) => c.isChecked).length;

  bool get canComplete =>
      checklist.isNotEmpty &&
      checklist.every((c) => c.isChecked) &&
      openSnags == 0 &&
      signOffs.isNotEmpty;

  HandoverState copyWith({
    bool? loading,
    List<DeliveryMilestone>? milestones,
    List<SnagItem>? snags,
    List<HandoverChecklistItem>? checklist,
    List<SignOff>? signOffs,
    HandoverSummary? summary,
    String? error,
    bool? saving,
  }) {
    return HandoverState(
      loading: loading ?? this.loading,
      milestones: milestones ?? this.milestones,
      snags: snags ?? this.snags,
      checklist: checklist ?? this.checklist,
      signOffs: signOffs ?? this.signOffs,
      summary: summary ?? this.summary,
      error: error,
      saving: saving ?? this.saving,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        milestones,
        snags,
        checklist,
        signOffs,
        summary,
        error,
        saving,
      ];
}
