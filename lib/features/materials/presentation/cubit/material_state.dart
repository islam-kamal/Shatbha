import 'package:equatable/equatable.dart';

import '../../data/models/material_models.dart';

class MaterialsState extends Equatable {
  const MaterialsState({
    this.loading = false,
    this.products = const [],
    this.projectMaterials = const [],
    this.searchQuery = '',
    this.error,
  });

  final bool loading;
  final List<Product> products;
  final List<ProjectMaterial> projectMaterials;
  final String searchQuery;
  final String? error;

  MaterialsState copyWith({
    bool? loading,
    List<Product>? products,
    List<ProjectMaterial>? projectMaterials,
    String? searchQuery,
    String? error,
  }) {
    return MaterialsState(
      loading: loading ?? this.loading,
      products: products ?? this.products,
      projectMaterials: projectMaterials ?? this.projectMaterials,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [loading, products, projectMaterials, searchQuery, error];
}
