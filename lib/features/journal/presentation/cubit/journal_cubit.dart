import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';
import 'package:shatbha/features/journal/data/repositories/journal_repository.dart';

import 'journal_state.dart';

export 'journal_state.dart';

class JournalCubit extends Cubit<JournalState> {
  JournalCubit(this._repo) : super(const JournalState());
  final JournalRepository _repo;

  Future<void> load({String? from, String? to, int? customerId}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final rows = await _repo.entries(
        from: from,
        to: to,
        customerId: customerId,
      );
      emit(state.copyWith(loading: false, entries: rows));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }
}
