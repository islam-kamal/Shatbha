import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';

import '../../data/repositories/client_repository.dart';
import 'client_state.dart';

export 'client_state.dart';

class ClientCubit extends Cubit<ClientState> {
  ClientCubit(this._repo) : super(const ClientState());
  final ClientRepository _repo;

  Future<void> loadProjects() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final rows = await _repo.projects();
      emit(state.copyWith(loading: false, projects: rows));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<void> loadProject(int id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final project = await _repo.project(id);
      emit(state.copyWith(loading: false, selected: project));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<void> loadDesignPackage(int projectId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final package = await _repo.designPackage(projectId);
      emit(state.copyWith(
        loading: false,
        designPackage: package,
        selected: package.project,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<bool> approveDesign(int projectId) async {
    emit(state.copyWith(approving: true, error: null));
    try {
      final project = await _repo.approveDesign(projectId);
      emit(state.copyWith(approving: false, selected: project));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(approving: false, error: e.message));
      return false;
    }
  }

  Future<bool> rejectDesign(int projectId, String reason) async {
    emit(state.copyWith(approving: true, error: null));
    try {
      final project = await _repo.rejectDesign(projectId, reason);
      emit(state.copyWith(approving: false, selected: project));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(approving: false, error: e.message));
      return false;
    }
  }
}
