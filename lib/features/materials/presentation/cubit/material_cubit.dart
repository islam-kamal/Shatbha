import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';

import '../../data/repositories/material_repository.dart';
import 'material_state.dart';

export 'material_state.dart';

class MaterialCubit extends Cubit<MaterialsState> {
  MaterialCubit(this._repo) : super(const MaterialsState());
  final MaterialRepository _repo;

  Future<void> loadCatalog({int? supplierId}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final rows = await _repo.products(supplierId: supplierId);
      emit(state.copyWith(loading: false, products: rows));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<void> search(String query) async {
    emit(state.copyWith(loading: true, error: null, searchQuery: query));
    try {
      final rows =
          query.trim().isEmpty ? await _repo.products() : await _repo.search(query);
      emit(state.copyWith(loading: false, products: rows));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<void> loadProjectMaterials(int projectId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final rows = await _repo.projectMaterials(projectId);
      emit(state.copyWith(loading: false, projectMaterials: rows));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<bool> addToProject(int projectId, Map<String, dynamic> body) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final row = await _repo.addToProject(projectId, body);
      emit(state.copyWith(
        loading: false,
        projectMaterials: [...state.projectMaterials, row],
      ));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return false;
    }
  }
}
