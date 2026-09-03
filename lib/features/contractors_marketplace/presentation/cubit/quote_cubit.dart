import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shatbha/core/core.dart';

import '../../../vendors/data/repositories/vendor_repository.dart';
import '../../data/models/quote_models.dart';
import '../../data/repositories/quote_repository.dart';
import 'quote_state.dart';

export 'quote_state.dart';

class QuoteCubit extends Cubit<QuoteState> {
  QuoteCubit(this._quotes, this._vendors) : super(const QuoteState());
  final QuoteRepository _quotes;
  final VendorRepository _vendors;

  Future<void> loadQuotes({int? projectId}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final rows = await _quotes.list(projectId: projectId);
      emit(state.copyWith(loading: false, quotes: rows));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<void> loadContractors() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final rows = await _vendors.list(type: 'contractor');
      emit(state.copyWith(loading: false, contractors: rows));
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    }
  }

  Future<bool> requestQuote(Map<String, dynamic> body) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final row = await _quotes.create(body);
      emit(state.copyWith(
        loading: false,
        quotes: [row, ...state.quotes],
      ));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return false;
    }
  }

  Future<bool> acceptQuote(int id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final row = await _quotes.accept(id);
      final updated = state.quotes
          .map((q) => q.id == id ? row : q)
          .toList(growable: false);
      emit(state.copyWith(loading: false, quotes: updated));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return false;
    }
  }

  Future<bool> rejectQuote(int id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final row = await _quotes.reject(id);
      final updated = state.quotes
          .map((q) => q.id == id ? row : q)
          .toList(growable: false);
      emit(state.copyWith(loading: false, quotes: updated));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return false;
    }
  }

  Future<QuoteRequest?> loadQuote(int id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final row = await _quotes.get(id);
      emit(state.copyWith(loading: false, selectedQuote: row));
      return row;
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return null;
    }
  }

  Future<bool> respondQuote(int id, Map<String, dynamic> body) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final row = await _quotes.respond(id, body);
      emit(state.copyWith(
        loading: false,
        selectedQuote: row,
        quotes: state.quotes
            .map((q) => q.id == id ? row : q)
            .toList(growable: false),
      ));
      return true;
    } on Failure catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return false;
    }
  }
}
