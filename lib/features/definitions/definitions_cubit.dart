import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/failures.dart';
import '../../data/models/models.dart';
import '../../data/repositories/catalog_repository.dart';

class DefinitionsState extends Equatable {
  const DefinitionsState({
    this.loading = false,
    this.customers = const [],
    this.contractors = const [],
    this.workTypes = const [],
    this.categories = const [],
    this.error,
  });

  final bool loading;
  final List<Party> customers;
  final List<Party> contractors;
  final List<NamedItem> workTypes;
  final List<NamedItem> categories;
  final String? error;

  DefinitionsState copyWith({
    bool? loading,
    List<Party>? customers,
    List<Party>? contractors,
    List<NamedItem>? workTypes,
    List<NamedItem>? categories,
    String? error,
  }) {
    return DefinitionsState(
      loading: loading ?? this.loading,
      customers: customers ?? this.customers,
      contractors: contractors ?? this.contractors,
      workTypes: workTypes ?? this.workTypes,
      categories: categories ?? this.categories,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, customers, contractors, workTypes, categories, error];
}

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
