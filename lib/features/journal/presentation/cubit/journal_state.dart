import 'package:equatable/equatable.dart';

import '../../data/models/journal_models.dart';

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
