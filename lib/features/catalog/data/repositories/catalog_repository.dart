import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_log.dart';
import '../datasources/catalog_remote_datasource.dart';
import '../models/catalog_models.dart';

class CatalogRepository {
  CatalogRepository(this._api, this._db);
  final CatalogRemoteDatasource _api;
  final AppDatabase _db;

  Future<List<Party>> parties(String type) async {
    try {
      final rows = await _api.parties(type);
      for (final party in rows) {
        await _upsertParty(party);
      }
      return rows;
    } on Failure catch (e) {
      AppLog.w('parties($type) fallback to cache', tag: 'catalog', error: e);
      final local = await (_db.select(_db.cachedParties)
            ..where((t) => t.type.equals(type)))
          .get();
      return local.map(_partyFromRow).toList();
    }
  }

  Future<Party> createParty(Map<String, dynamic> body) async {
    try {
      final party = await _api.createParty(body);
      await _upsertParty(party);
      return party;
    } on Failure catch (e) {
      if (e is! OfflineFailure) rethrow;
      AppLog.i('enqueue party offline', tag: 'catalog');
      await _db.enqueue(
        'POST',
        body['type'] == 'contractor' ? '/contractors' : '/customers',
        jsonEncode(body),
      );
      final party = Party(
        id: DateTime.now().millisecondsSinceEpoch,
        type: body['type'] as String? ?? 'customer',
        name: body['name'] as String,
        phone: body['phone'] as String?,
        kind: body['kind'] as String?,
        openingBalance: body['opening_balance']?.toString() ?? '0.00',
        agreementEstimate: body['agreement_estimate']?.toString(),
        supervisionPercent: body['supervision_percent'] as int? ?? 0,
      );
      await _upsertParty(party);
      return party;
    }
  }

  Future<List<NamedItem>> workTypes() async {
    try {
      final rows = await _api.workTypes();
      for (final item in rows) {
        await _db.into(_db.cachedWorkTypes).insertOnConflictUpdate(
              CachedWorkTypesCompanion.insert(
                id: Value(item.id),
                name: item.name,
              ),
            );
      }
      return rows;
    } on Failure catch (e) {
      AppLog.w('workTypes fallback to cache', tag: 'catalog', error: e);
      final local = await _db.select(_db.cachedWorkTypes).get();
      return local.map((e) => NamedItem(id: e.id, name: e.name)).toList();
    }
  }

  Future<NamedItem> createWorkType(String name) async {
    try {
      final item = await _api.createWorkType(name);
      await _db.into(_db.cachedWorkTypes).insertOnConflictUpdate(
            CachedWorkTypesCompanion.insert(id: Value(item.id), name: item.name),
          );
      return item;
    } on Failure catch (e) {
      if (e is! OfflineFailure) rethrow;
      AppLog.i('enqueue work-type offline', tag: 'catalog');
      await _db.enqueue('POST', '/work-types', jsonEncode({'name': name}));
      final item =
          NamedItem(id: DateTime.now().millisecondsSinceEpoch, name: name);
      await _db.into(_db.cachedWorkTypes).insertOnConflictUpdate(
            CachedWorkTypesCompanion.insert(id: Value(item.id), name: item.name),
          );
      return item;
    }
  }

  Future<List<NamedItem>> expenseCategories() async {
    try {
      final rows = await _api.expenseCategories();
      for (final item in rows) {
        await _db.into(_db.cachedExpenseCategories).insertOnConflictUpdate(
              CachedExpenseCategoriesCompanion.insert(
                id: Value(item.id),
                name: item.name,
              ),
            );
      }
      return rows;
    } on Failure catch (e) {
      AppLog.w('expenseCategories fallback to cache', tag: 'catalog', error: e);
      final local = await _db.select(_db.cachedExpenseCategories).get();
      return local.map((e) => NamedItem(id: e.id, name: e.name)).toList();
    }
  }

  Future<NamedItem> createExpenseCategory(String name) async {
    try {
      final item = await _api.createExpenseCategory(name);
      await _db.into(_db.cachedExpenseCategories).insertOnConflictUpdate(
            CachedExpenseCategoriesCompanion.insert(
              id: Value(item.id),
              name: item.name,
            ),
          );
      return item;
    } on Failure catch (e) {
      if (e is! OfflineFailure) rethrow;
      AppLog.i('enqueue expense-category offline', tag: 'catalog');
      await _db.enqueue(
        'POST',
        '/expense-categories',
        jsonEncode({'name': name}),
      );
      final item =
          NamedItem(id: DateTime.now().millisecondsSinceEpoch, name: name);
      await _db.into(_db.cachedExpenseCategories).insertOnConflictUpdate(
            CachedExpenseCategoriesCompanion.insert(
              id: Value(item.id),
              name: item.name,
            ),
          );
      return item;
    }
  }

  Future<void> _upsertParty(Party party) {
    return _db.into(_db.cachedParties).insertOnConflictUpdate(
          CachedPartiesCompanion.insert(
            id: Value(party.id),
            type: party.type,
            name: party.name,
            phone: Value(party.phone),
            kind: Value(party.kind),
            openingBalance: Value(party.openingBalance),
            agreementEstimate: Value(party.agreementEstimate),
            supervisionPercent: Value(party.supervisionPercent),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Party _partyFromRow(CachedParty row) => Party(
        id: row.id,
        type: row.type,
        name: row.name,
        phone: row.phone,
        kind: row.kind,
        openingBalance: row.openingBalance,
        agreementEstimate: row.agreementEstimate,
        supervisionPercent: row.supervisionPercent,
      );
}
