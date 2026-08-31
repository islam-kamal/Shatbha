import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';

import '../../data/repositories/design_repository.dart';
import 'design_state.dart';

export 'design_state.dart';

class DesignCubit extends Cubit<DesignState> {
  DesignCubit(this._repo) : super(const DesignState());
  final DesignRepository _repo;

  void setTab(DesignTab tab) => emit(state.copyWith(tab: tab));

  Future<void> load(int projectId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final boards = await _repo.designBoards(projectId);
      final inspiration = await _repo.inspiration(projectId);
      final plans = await _repo.floorPlans(projectId);
      final boq = await _repo.boqLines(projectId);
      emit(state.copyWith(
        loading: false,
        designBoards: boards,
        inspiration: inspiration,
        floorPlans: plans,
        boqLines: boq,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<bool> addBoqLine(int projectId, Map<String, dynamic> body) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final line = await _repo.createBoqLine(projectId, body);
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

  Future<bool> addDesignBoard(int projectId, Map<String, dynamic> body) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final board = await _repo.createDesignBoard(projectId, body);
      emit(state.copyWith(
        loading: false,
        designBoards: [...state.designBoards, board],
      ));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return false;
    }
  }

  Future<bool> addFloorPlan(int projectId, Map<String, dynamic> body) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final plan = await _repo.createFloorPlan(projectId, body);
      emit(state.copyWith(
        loading: false,
        floorPlans: [...state.floorPlans, plan],
      ));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return false;
    }
  }

  Future<bool> addInspiration(int projectId, Map<String, dynamic> body) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final item = await _repo.createInspiration(projectId, body);
      emit(state.copyWith(
        loading: false,
        inspiration: [...state.inspiration, item],
      ));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return false;
    }
  }
}
