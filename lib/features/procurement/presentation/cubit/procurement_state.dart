import 'package:equatable/equatable.dart';

import '../../data/models/procurement_models.dart';

class ProcurementState extends Equatable {
  const ProcurementState({
    this.loading = false,
    this.orders = const [],
    this.error,
    this.saving = false,
  });

  final bool loading;
  final List<PurchaseOrder> orders;
  final String? error;
  final bool saving;

  double get pendingTotal => orders
      .where((o) => o.status != 'received')
      .fold(0, (s, o) => s + (double.tryParse(o.total) ?? 0));

  ProcurementState copyWith({
    bool? loading,
    List<PurchaseOrder>? orders,
    String? error,
    bool? saving,
  }) {
    return ProcurementState(
      loading: loading ?? this.loading,
      orders: orders ?? this.orders,
      error: error,
      saving: saving ?? this.saving,
    );
  }

  @override
  List<Object?> get props => [loading, orders, error, saving];
}
