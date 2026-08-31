import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';

import '../../data/models/handover_models.dart';
import '../../data/repositories/handover_repository.dart';
import 'handover_state.dart';

export 'handover_state.dart';

class HandoverCubit extends Cubit<HandoverState> {
  HandoverCubit(this._repo) : super(const HandoverState());
  final HandoverRepository _repo;

  Future<void> load(int projectId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final results = await Future.wait([
        _repo.deliveryMilestones(projectId),
        _repo.snagItems(projectId),
        _repo.checklist(projectId),
        _repo.signOffs(projectId),
      ]);
      emit(
        state.copyWith(
          loading: false,
          milestones: results[0] as List<DeliveryMilestone>,
          snags: results[1] as List<SnagItem>,
          checklist: results[2] as List<HandoverChecklistItem>,
          signOffs: results[3] as List<SignOff>,
        ),
      );
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<void> toggleChecklist(int projectId, HandoverChecklistItem item) async {
    try {
      final updated = await _repo.updateChecklist(projectId, {
        'id': item.id,
        'is_checked': !item.isChecked,
      });
      final list = state.checklist.map((c) => c.id == item.id ? updated : c).toList();
      emit(state.copyWith(checklist: list));
    } on Failure catch (e) {
      emit(state.copyWith(error: e.message));
    }
  }

  Future<void> addSnag(int projectId, Map<String, dynamic> body) async {
    try {
      final snag = await _repo.createSnag(projectId, body);
      emit(state.copyWith(snags: [...state.snags, snag]));
    } on Failure catch (e) {
      emit(state.copyWith(error: e.message));
    }
  }

  Future<void> addSignOff(int projectId, Map<String, dynamic> body) async {
    try {
      final sign = await _repo.signOff(projectId, body);
      emit(state.copyWith(signOffs: [...state.signOffs, sign]));
    } on Failure catch (e) {
      emit(state.copyWith(error: e.message));
    }
  }

  Future<bool> completeHandover(int projectId) async {
    if (!state.canComplete) return false;
    emit(state.copyWith(saving: true, error: null));
    try {
      final summary = await _repo.complete(projectId, {
        'completed_at': formatDate(DateTime.now()),
      });
      emit(state.copyWith(saving: false, summary: summary));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(saving: false, error: e.message));
      return false;
    }
  }
}
