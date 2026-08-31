import 'package:equatable/equatable.dart';

import '../../data/models/pm_models.dart';
import '../../../media/data/models/media_models.dart';

class PmState extends Equatable {
  const PmState({
    this.loading = false,
    this.tasks = const [],
    this.milestones = const [],
    this.timeline = const [],
    this.budget = const [],
    this.photos = const [],
    this.error,
    this.uploadingPhoto = false,
  });

  final bool loading;
  final List<ProjectTask> tasks;
  final List<ProjectMilestone> milestones;
  final List<TimelineEvent> timeline;
  final List<BudgetLine> budget;
  final List<MediaFile> photos;
  final String? error;
  final bool uploadingPhoto;

  double get plannedTotal => budget.fold(
        0,
        (s, b) => s + (double.tryParse(b.plannedAmount) ?? 0),
      );

  double get actualTotal => budget.fold(
        0,
        (s, b) => s + (double.tryParse(b.actualAmount) ?? 0),
      );

  PmState copyWith({
    bool? loading,
    List<ProjectTask>? tasks,
    List<ProjectMilestone>? milestones,
    List<TimelineEvent>? timeline,
    List<BudgetLine>? budget,
    List<MediaFile>? photos,
    String? error,
    bool? uploadingPhoto,
  }) {
    return PmState(
      loading: loading ?? this.loading,
      tasks: tasks ?? this.tasks,
      milestones: milestones ?? this.milestones,
      timeline: timeline ?? this.timeline,
      budget: budget ?? this.budget,
      photos: photos ?? this.photos,
      error: error,
      uploadingPhoto: uploadingPhoto ?? this.uploadingPhoto,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        tasks,
        milestones,
        timeline,
        budget,
        photos,
        error,
        uploadingPhoto,
      ];
}
