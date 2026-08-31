import 'package:equatable/equatable.dart';

import '../../data/models/quote_models.dart';
import '../../../vendors/data/models/vendor_models.dart';

class QuoteState extends Equatable {
  const QuoteState({
    this.loading = false,
    this.quotes = const [],
    this.contractors = const [],
    this.error,
  });

  final bool loading;
  final List<QuoteRequest> quotes;
  final List<Vendor> contractors;
  final String? error;

  QuoteState copyWith({
    bool? loading,
    List<QuoteRequest>? quotes,
    List<Vendor>? contractors,
    String? error,
  }) {
    return QuoteState(
      loading: loading ?? this.loading,
      quotes: quotes ?? this.quotes,
      contractors: contractors ?? this.contractors,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, quotes, contractors, error];
}
