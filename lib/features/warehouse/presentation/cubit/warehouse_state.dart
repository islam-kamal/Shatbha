import 'package:equatable/equatable.dart';

import '../../data/models/warehouse_models.dart';

class WarehouseState extends Equatable {
  const WarehouseState({
    this.loading = false,
    this.warehouses = const [],
    this.stock = const [],
    this.error,
    this.saving = false,
    this.selectedWarehouseId,
  });

  final bool loading;
  final List<Warehouse> warehouses;
  final List<StockLevel> stock;
  final String? error;
  final bool saving;
  final int? selectedWarehouseId;

  WarehouseState copyWith({
    bool? loading,
    List<Warehouse>? warehouses,
    List<StockLevel>? stock,
    String? error,
    bool? saving,
    int? selectedWarehouseId,
  }) {
    return WarehouseState(
      loading: loading ?? this.loading,
      warehouses: warehouses ?? this.warehouses,
      stock: stock ?? this.stock,
      error: error,
      saving: saving ?? this.saving,
      selectedWarehouseId: selectedWarehouseId ?? this.selectedWarehouseId,
    );
  }

  @override
  List<Object?> get props =>
      [loading, warehouses, stock, error, saving, selectedWarehouseId];
}
