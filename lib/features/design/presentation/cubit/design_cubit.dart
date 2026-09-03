import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';

import '../../data/models/design_models.dart';
import '../../data/repositories/design_repository.dart';
import 'design_state.dart';

export 'design_state.dart';

class DesignCubit extends Cubit<DesignState> {
  DesignCubit(this._repo) : super(const DesignState());
  final DesignRepository _repo;

  void setTab(DesignTab tab) => emit(state.copyWith(tab: tab));

  void setPlanTypeFilter(String? type) {
    if (type == null) {
      emit(state.copyWith(clearPlanTypeFilter: true));
    } else {
      emit(state.copyWith(planTypeFilter: type));
    }
  }

  Future<void> load(int projectId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final status = await _repo.projectDesignStatus(projectId);
      final reason = status == 'rejected'
          ? await _repo.projectDesignRejectReason(projectId)
          : null;
      final boards = await _repo.designBoards(projectId);
      final plans = await _repo.plans(projectId);
      final boq = await _repo.boqLines(projectId);
      emit(state.copyWith(
        loading: false,
        designStatus: status,
        designRejectReason: reason,
        clearRejectReason: reason == null,
        designBoards: boards,
        inspiration: boards.expand((b) => b.inspiration).toList(),
        plans: plans,
        boqLines: boq,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<bool> updateBoard(int projectId, Map<String, dynamic> body) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      var boards = state.designBoards;
      if (boards.isEmpty) {
        final board = await _repo.createDesignBoard(projectId, {
          'title': 'لوحة الإلهام',
          ...body,
        });
        boards = [board];
      } else {
        final board =
            await _repo.updateDesignBoard(projectId, boards.first.id, body);
        boards = [board, ...boards.skip(1)];
      }
      emit(state.copyWith(
        loading: false,
        designBoards: boards,
        inspiration: boards.expand((b) => b.inspiration).toList(),
      ));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return false;
    }
  }

  Future<bool> deleteBoqLine(int projectId, int lineId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _repo.deleteBoqLine(projectId, lineId);
      emit(state.copyWith(
        loading: false,
        boqLines: state.boqLines.where((l) => l.id != lineId).toList(),
      ));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return false;
    }
  }

  Future<bool> createBoqFromInspiration(
    int projectId,
    int inspirationItemId, {
    String? qty,
    String? unit,
    String? rate,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final line = await _repo.createBoqFromInspiration(projectId, {
        'inspiration_item_id': inspirationItemId,
        if (qty != null) 'qty': qty,
        if (unit != null) 'unit': unit,
        if (rate != null) 'rate': rate,
      });
      emit(state.copyWith(
        loading: false,
        boqLines: [...state.boqLines, line],
      ));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return false;
    }
  }

  Future<bool> submitToClient(int projectId) async {
    emit(state.copyWith(submitting: true, error: null));
    try {
      await _repo.submitToClient(projectId);
      emit(state.copyWith(
        submitting: false,
        designStatus: 'pending',
        clearRejectReason: true,
      ));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(submitting: false, error: e.message));
      return false;
    }
  }

  Future<bool> submitPlan(int projectId, int planId) async {
    try {
      final plan = await _repo.submitPlan(projectId, planId);
      emit(state.copyWith(
        plans: state.plans.map((p) => p.id == planId ? plan : p).toList(),
      ));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(error: e.message));
      return false;
    }
  }

  Future<bool> approvePlan(int projectId, int planId) async {
    try {
      final plan = await _repo.approvePlan(projectId, planId);
      emit(state.copyWith(
        plans: state.plans.map((p) => p.id == planId ? plan : p).toList(),
      ));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(error: e.message));
      return false;
    }
  }

  Future<bool> rejectPlan(int projectId, int planId) async {
    try {
      final plan = await _repo.rejectPlan(projectId, planId);
      emit(state.copyWith(
        plans: state.plans.map((p) => p.id == planId ? plan : p).toList(),
      ));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(error: e.message));
      return false;
    }
  }

  Future<bool> addPlanComment(int projectId, int planId, String body) async {
    try {
      final comment = await _repo.addPlanComment(projectId, planId, body);
      emit(state.copyWith(
        plans: state.plans.map((p) {
          if (p.id != planId) return p;
          return DesignPlan(
            id: p.id,
            projectId: p.projectId,
            title: p.title,
            type: p.type,
            room: p.room,
            version: p.version,
            status: p.status,
            imageUrl: p.imageUrl,
            isPdf: p.isPdf,
            inspirationItemId: p.inspirationItemId,
            comments: [...p.comments, comment],
          );
        }).toList(),
      ));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(error: e.message));
      return false;
    }
  }
}
