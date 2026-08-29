import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_log.dart';
import '../datasources/expense_remote_datasource.dart';
import '../models/expense_models.dart';

class ExpenseRepository {
  ExpenseRepository(this._api, this._db);
  final ExpenseRemoteDatasource _api;
  final AppDatabase _db;

  Future<(List<ExpenseItem>, String)> list({String? from, String? to}) async {
    try {
      final result = await _api.expenses(from: from, to: to);
      for (final row in result.$1) {
        await _upsert(row);
      }
      return result;
    } on Failure catch (e) {
      AppLog.w('expenses fallback to cache', tag: 'expense', error: e);
      final local = await _db.select(_db.cachedExpenses).get();
      final filtered = local.map(_fromRow).where((e) {
        if (from != null && e.entryDate.compareTo(from) < 0) return false;
        if (to != null && e.entryDate.compareTo(to) > 0) return false;
        return true;
      }).toList();
      final total = filtered.fold<double>(
        0,
        (s, e) => s + (double.tryParse(e.amount) ?? 0),
      );
      return (filtered, total.toStringAsFixed(2));
    }
  }

  Future<ExpenseItem> create(Map<String, dynamic> body) async {
    try {
      final row = await _api.createExpense(body);
      await _upsert(row);
      return row;
    } on Failure catch (e) {
      if (e is! OfflineFailure) rethrow;
      AppLog.i('enqueue expense offline', tag: 'expense');
      await _db.enqueue('POST', '/expenses', jsonEncode(body));
      final row = ExpenseItem(
        id: DateTime.now().millisecondsSinceEpoch,
        entryDate: body['entry_date'] as String,
        title: body['title'] as String,
        amount: body['amount'].toString(),
        categoryId: body['category_id'] as int?,
      );
      await _upsert(row);
      return row;
    }
  }

  Future<List<CategoryTotal>> byCategory() async {
    try {
      return await _api.expensesByCategory();
    } on Failure catch (e) {
      AppLog.w('expense report fallback to cache', tag: 'expense', error: e);
      final local = await _db.select(_db.cachedExpenses).get();
      final map = <String, double>{};
      for (final row in local) {
        final key = row.categoryName ?? 'أخرى';
        map[key] = (map[key] ?? 0) + (double.tryParse(row.amount) ?? 0);
      }
      return map.entries
          .map(
            (e) => CategoryTotal(
              category: e.key,
              total: e.value.toStringAsFixed(2),
            ),
          )
          .toList();
    }
  }

  Future<void> _upsert(ExpenseItem row) {
    return _db.into(_db.cachedExpenses).insertOnConflictUpdate(
          CachedExpensesCompanion.insert(
            id: Value(row.id),
            categoryId: Value(row.categoryId),
            entryDate: row.entryDate,
            title: row.title,
            amount: row.amount,
            notes: Value(row.notes),
            categoryName: Value(row.categoryName),
          ),
        );
  }

  ExpenseItem _fromRow(CachedExpense row) => ExpenseItem(
        id: row.id,
        entryDate: row.entryDate,
        title: row.title,
        amount: row.amount,
        categoryId: row.categoryId,
        categoryName: row.categoryName,
        notes: row.notes,
      );
}
