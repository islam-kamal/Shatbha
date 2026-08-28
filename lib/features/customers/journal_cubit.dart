import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/failures.dart';
import '../../data/models/models.dart';
import '../../data/repositories/journal_repository.dart';

class JournalState extends Equatable {
  const JournalState({
    this.loading = false,
    this.entries = const [],
    this.error,
  });

  final bool loading;
  final List<JournalEntry> entries;
  final String? error;

  bool get isEmpty => !loading && error == null && entries.isEmpty;

  JournalState copyWith({
    bool? loading,
    List<JournalEntry>? entries,
    String? error,
  }) {
    return JournalState(
      loading: loading ?? this.loading,
      entries: entries ?? this.entries,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, entries, error];
}

class JournalCubit extends Cubit<JournalState> {
  JournalCubit(this._repo) : super(const JournalState());
  final JournalRepository _repo;

  Future<void> load({String? from, String? to, int? customerId}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final rows = await _repo.entries(from: from, to: to, customerId: customerId);
      emit(state.copyWith(loading: false, entries: rows));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }
}
