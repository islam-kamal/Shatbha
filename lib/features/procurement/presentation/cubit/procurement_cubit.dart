import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';

import '../../data/models/procurement_models.dart';
import '../../data/repositories/procurement_repository.dart';
import 'procurement_state.dart';

export 'procurement_state.dart';

class ProcurementCubit extends Cubit<ProcurementState> {
  ProcurementCubit(this._repo) : super(const ProcurementState());
  final ProcurementRepository _repo;

  Future<void> load({int? projectId}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final orders = await _repo.list(projectId: projectId);
      emit(state.copyWith(loading: false, orders: orders));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<bool> createPo(Map<String, dynamic> body) async {
    emit(state.copyWith(saving: true, error: null));
    try {
      final po = await _repo.create(body);
      emit(state.copyWith(saving: false, orders: [po, ...state.orders]));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(saving: false, error: e.message));
      return false;
    }
  }

  Future<bool> receive(int poId, {String? notes}) async {
    emit(state.copyWith(saving: true, error: null));
    try {
      await _repo.receive(poId, {
        if (notes != null) 'notes': notes,
        'received_at': formatDate(DateTime.now()),
      });
      final updated = state.orders.map((o) {
        if (o.id == poId) {
          return PurchaseOrder(
            id: o.id,
            projectId: o.projectId,
            vendorId: o.vendorId,
            poNumber: o.poNumber,
            status: 'received',
            total: o.total,
            orderedAt: o.orderedAt,
            vendorName: o.vendorName,
            projectName: o.projectName,
            lines: o.lines,
          );
        }
        return o;
      }).toList();
      emit(state.copyWith(saving: false, orders: updated));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(saving: false, error: e.message));
      return false;
    }
  }
}
