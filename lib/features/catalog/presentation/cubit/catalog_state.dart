import 'package:equatable/equatable.dart';

import '../../data/models/catalog_models.dart';

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
  List<Object?> get props =>
      [loading, customers, contractors, workTypes, categories, error];
}
