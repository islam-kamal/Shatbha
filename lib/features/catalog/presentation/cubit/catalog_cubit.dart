import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';
import 'package:shatbha/features/catalog/data/repositories/catalog_repository.dart';

import 'catalog_state.dart';

export 'catalog_state.dart';

class DefinitionsCubit extends Cubit<DefinitionsState> {
  DefinitionsCubit(this._repo) : super(const DefinitionsState());
  final CatalogRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final customers = await _repo.parties('customer');
      final contractors = await _repo.parties('contractor');
      final workTypes = await _repo.workTypes();
      final categories = await _repo.expenseCategories();
      emit(
        state.copyWith(
          loading: false,
          customers: customers,
          contractors: contractors,
          workTypes: workTypes,
          categories: categories,
        ),
      );
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<void> addParty(Map<String, dynamic> body) async {
    await _repo.createParty(body);
    await load();
  }

  Future<void> addWorkType(String name) async {
    await _repo.createWorkType(name);
    await load();
  }

  Future<void> addCategory(String name) async {
    await _repo.createExpenseCategory(name);
    await load();
  }
}
