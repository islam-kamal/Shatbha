import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_log.dart';
import '../../../catalog/data/models/catalog_models.dart';
import '../datasources/journal_remote_datasource.dart';
import '../models/journal_models.dart';

class JournalRepository {
  JournalRepository(this._api, this._db);
  final JournalRemoteDatasource _api;
  final AppDatabase _db;

  Future<List<JournalEntry>> entries({
    String? from,
    String? to,
    int? customerId,
  }) async {
    try {
      final rows = await _api.customerEntries(
        from: from,
        to: to,
        customerId: customerId,
      );
      for (final row in rows) {
        await _upsert(row);
      }
      return rows;
    } on Failure catch (e) {
      AppLog.w('entries fallback to cache', tag: 'journal', error: e);
      final query = _db.select(_db.cachedEntries);
      if (customerId != null) {
        query.where((t) => t.customerId.equals(customerId));
      }
      final local = await query.get();
      return local.map(_fromRow).where((e) {
        if (from != null && e.entryDate.compareTo(from) < 0) return false;
        if (to != null && e.entryDate.compareTo(to) > 0) return false;
        return true;
      }).toList();
    }
  }

  Future<JournalEntry> create(Map<String, dynamic> body) async {
    try {
      final row = await _api.createEntry(body);
      await _upsert(row);
      return row;
    } on Failure catch (e) {
      if (e is! OfflineFailure) rethrow;
      AppLog.i('enqueue customer-entry offline', tag: 'journal');
      await _db.enqueue('POST', '/customer-entries', jsonEncode(body));
      final row = JournalEntry(
        id: DateTime.now().millisecondsSinceEpoch,
        customerId: body['customer_id'] as int,
        entryDate: body['entry_date'] as String,
        entryType: body['entry_type'] as String,
        title: body['title'] as String,
        amount: body['amount']?.toString() ?? '0.00',
        laborAmount: body['labor_amount']?.toString() ?? '0.00',
        returnAmount: body['return_amount']?.toString() ?? '0.00',
        notes: body['notes'] as String?,
      );
      await _upsert(row);
      return row;
    }
  }

  Future<StatementData> statement(
    int customerId, {
    String? from,
    String? to,
  }) async {
    try {
      return await _api.statement(customerId, from: from, to: to);
    } on Failure catch (e) {
      AppLog.w('statement fallback to cache', tag: 'journal', error: e);
      final entries = await this.entries(
        from: from,
        to: to,
        customerId: customerId,
      );
      final parties = await (_db.select(_db.cachedParties)
            ..where((t) => t.id.equals(customerId)))
          .get();
      if (parties.isEmpty) rethrow;
      final p = parties.first;
      final sales = entries.fold<double>(
        0,
        (s, e) =>
            s +
            (double.tryParse(e.amount) ?? 0) +
            (double.tryParse(e.laborAmount) ?? 0),
      );
      final collect = entries
          .where((e) => e.entryType == 'cash')
          .fold<double>(0, (s, e) => s + (double.tryParse(e.amount) ?? 0));
      final returns = entries.fold<double>(
        0,
        (s, e) => s + (double.tryParse(e.returnAmount) ?? 0),
      );
      final opening = double.tryParse(p.openingBalance) ?? 0;
      return StatementData(
        customer: Party(
          id: p.id,
          type: p.type,
          name: p.name,
          phone: p.phone,
          kind: p.kind,
          openingBalance: p.openingBalance,
          agreementEstimate: p.agreementEstimate,
          supervisionPercent: p.supervisionPercent,
        ),
        entries: entries,
        opening: opening.toStringAsFixed(2),
        sales: sales.toStringAsFixed(2),
        collect: collect.toStringAsFixed(2),
        returns: returns.toStringAsFixed(2),
        closing: (opening + sales - collect - returns).toStringAsFixed(2),
      );
    }
  }

  Future<void> _upsert(JournalEntry row) {
    return _db.into(_db.cachedEntries).insertOnConflictUpdate(
          CachedEntriesCompanion.insert(
            id: Value(row.id),
            customerId: row.customerId,
            entryDate: row.entryDate,
            entryType: row.entryType,
            title: row.title,
            amount: Value(row.amount),
            laborAmount: Value(row.laborAmount),
            returnAmount: Value(row.returnAmount),
            notes: Value(row.notes),
            customerName: Value(row.customerName),
          ),
        );
  }

  JournalEntry _fromRow(CachedEntry row) => JournalEntry(
        id: row.id,
        customerId: row.customerId,
        entryDate: row.entryDate,
        entryType: row.entryType,
        title: row.title,
        amount: row.amount,
        laborAmount: row.laborAmount,
        returnAmount: row.returnAmount,
        notes: row.notes,
        customerName: row.customerName,
      );
}
