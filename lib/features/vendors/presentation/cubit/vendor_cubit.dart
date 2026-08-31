import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';

import '../../data/repositories/vendor_repository.dart';
import 'vendor_state.dart';

export 'vendor_state.dart';

class VendorCubit extends Cubit<VendorState> {
  VendorCubit(this._repo) : super(const VendorState());
  final VendorRepository _repo;

  Future<void> load({String? type}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final rows = await _repo.list(type: type);
      emit(state.copyWith(
        loading: false,
        vendors: rows,
        filterType: type ?? state.filterType,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  void setFilter(String type) {
    emit(state.copyWith(filterType: type));
  }

  Future<void> loadProfile(int id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final vendor = await _repo.get(id);
      final reviews = await _repo.reviews(vendorId: id);
      emit(state.copyWith(
        loading: false,
        selected: vendor,
        reviews: reviews,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }
}
