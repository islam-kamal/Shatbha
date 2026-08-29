import 'dart:convert';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_log.dart';
import '../datasources/sync_remote_datasource.dart';

class SyncRepository {
  SyncRepository(this._api, this._db);
  final SyncRemoteDatasource _api;
  final AppDatabase _db;

  Future<int> pendingCount() async {
    final rows = await _db.pendingOutbox();
    return rows.length;
  }

  Future<int> flush() async {
    final pending = await _db.pendingOutbox();
    AppLog.i('flush ${pending.length} outbox rows', tag: 'sync');
    var synced = 0;
    for (final row in pending) {
      try {
        final body = row.payload.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(row.payload) as Map<String, dynamic>;
        await _api.replay(row.method, row.path, body);
        await _db.markOutbox(row.id, 'synced');
        synced++;
        AppLog.d('synced ${row.method} ${row.path}', tag: 'sync');
      } on Failure catch (e) {
        await _db.markOutbox(row.id, 'failed');
        AppLog.e(
          'failed ${row.method} ${row.path}',
          tag: 'sync',
          error: e,
        );
      }
    }
    AppLog.i('flush done synced=$synced failed=${pending.length - synced}', tag: 'sync');
    return synced;
  }
}
