import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';

import '../../../media/data/models/media_models.dart';
import '../../data/models/pm_models.dart';
import '../../data/repositories/pm_repository.dart';
import 'pm_state.dart';

export 'pm_state.dart';

class PmCubit extends Cubit<PmState> {
  PmCubit(this._repo) : super(const PmState());
  final PmRepository _repo;

  Future<void> load(int projectId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final results = await Future.wait([
        _repo.tasks(projectId),
        _repo.milestones(projectId),
        _repo.timelineEvents(projectId),
        _repo.budget(projectId),
      ]);
      final timeline = results[2] as List<TimelineEvent>;
      final photoEvents = timeline
          .where((e) => e.eventType == 'photo' && e.mediaUrl != null)
          .map(
            (e) => MediaFile(
              id: e.id,
              url: e.mediaUrl!,
              filename: e.title,
              projectId: projectId,
            ),
          )
          .toList();
      emit(
        state.copyWith(
          loading: false,
          tasks: results[0] as List<ProjectTask>,
          milestones: results[1] as List<ProjectMilestone>,
          timeline: timeline,
          budget: results[3] as List<BudgetLine>,
          photos: photoEvents,
        ),
      );
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<void> addTask(int projectId, Map<String, dynamic> body) async {
    try {
      final task = await _repo.createTask(projectId, body);
      emit(state.copyWith(tasks: [...state.tasks, task]));
    } on Failure catch (e) {
      emit(state.copyWith(error: e.message));
    }
  }

  Future<void> addBudgetLine(int projectId, Map<String, dynamic> body) async {
    try {
      final line = await _repo.createBudgetLine(projectId, body);
      emit(state.copyWith(budget: [...state.budget, line]));
    } on Failure catch (e) {
      emit(state.copyWith(error: e.message));
    }
  }

  Future<void> addPhotoEvent(int projectId, MediaFile media) async {
    emit(state.copyWith(uploadingPhoto: true));
    try {
      await _repo.createTimelineEvent(projectId, {
        'title': media.filename ?? 'صورة موقع',
        'event_type': 'photo',
        'media_id': media.id,
        'event_date': formatDate(DateTime.now()),
      });
      emit(
        state.copyWith(
          uploadingPhoto: false,
          photos: [...state.photos, media],
        ),
      );
    } on Failure catch (e) {
      emit(state.copyWith(uploadingPhoto: false, error: e.message));
    }
  }
}
