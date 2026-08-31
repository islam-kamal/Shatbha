import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';

import '../../data/models/project_models.dart';
import '../../data/repositories/project_repository.dart';
import 'project_state.dart';

export 'project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  ProjectCubit(this._repo) : super(const ProjectState());
  final ProjectRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final rows = await _repo.list();
      emit(state.copyWith(loading: false, projects: rows));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<void> loadDetail(int id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final project = await _repo.get(id);
      emit(state.copyWith(loading: false, selected: project));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<Project?> create(Map<String, dynamic> body) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final project = await _repo.create(body);
      emit(state.copyWith(
        loading: false,
        projects: [project, ...state.projects],
      ));
      return project;
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return null;
    }
  }

  Future<Project?> update(int id, Map<String, dynamic> body) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final project = await _repo.update(id, body);
      final updated = state.projects
          .map((p) => p.id == id ? project : p)
          .toList(growable: false);
      emit(state.copyWith(
        loading: false,
        projects: updated,
        selected: project,
      ));
      return project;
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return null;
    }
  }
}
