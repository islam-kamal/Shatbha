import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';

import '../../data/models/warehouse_models.dart';
import '../../data/repositories/warehouse_repository.dart';
import 'warehouse_state.dart';

export 'warehouse_state.dart';

class WarehouseCubit extends Cubit<WarehouseState> {
  WarehouseCubit(this._repo) : super(const WarehouseState());
  final WarehouseRepository _repo;

  Future<void> load({int? warehouseId}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final results = await Future.wait([
        _repo.warehouses(),
        _repo.stock(warehouseId: warehouseId),
      ]);
      emit(
        state.copyWith(
          loading: false,
          warehouses: results[0] as List<Warehouse>,
          stock: results[1] as List<StockLevel>,
          selectedWarehouseId: warehouseId,
        ),
      );
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<bool> issueToProject({
    required int warehouseId,
    required int projectId,
    required int productId,
    required String quantity,
    String? notes,
  }) async {
    emit(state.copyWith(saving: true, error: null));
    try {
      await _repo.moveStock({
        'movement_type': 'issue',
        'from_warehouse_id': warehouseId,
        'project_id': projectId,
        'lines': [
          {'product_id': productId, 'quantity': quantity},
        ],
        if (notes != null) 'notes': notes,
      });
      await load(warehouseId: warehouseId);
      emit(state.copyWith(saving: false));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(saving: false, error: e.message));
      return false;
    }
  }

  Future<bool> transfer({
    required int fromWarehouseId,
    required int toWarehouseId,
    required int productId,
    required String quantity,
    String? notes,
  }) async {
    emit(state.copyWith(saving: true, error: null));
    try {
      await _repo.moveStock({
        'movement_type': 'transfer',
        'from_warehouse_id': fromWarehouseId,
        'to_warehouse_id': toWarehouseId,
        'lines': [
          {'product_id': productId, 'quantity': quantity},
        ],
        if (notes != null) 'notes': notes,
      });
      await load(warehouseId: fromWarehouseId);
      emit(state.copyWith(saving: false));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(saving: false, error: e.message));
      return false;
    }
  }
}
