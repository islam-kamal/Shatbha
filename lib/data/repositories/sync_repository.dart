import 'dart:convert';

import '../../core/failures.dart';
import '../local/app_database.dart';
import '../remote/api_datasource.dart';

class SyncRepository {
  SyncRepository(this._api, this._db);
  final ApiDatasource _api;
  final AppDatabase _db;

  Future<int> pendingCount() async {
    final rows = await _db.pendingOutbox();
    return rows.length;
  }

  Future<int> flush() async {
    final pending = await _db.pendingOutbox();
    var synced = 0;
    for (final row in pending) {
      try {
        final body = row.payload.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(row.payload) as Map<String, dynamic>;
        await _api.replay(row.method, row.path, body);
        await _db.markOutbox(row.id, 'synced');
        synced++;
      } on Failure {
        await _db.markOutbox(row.id, 'failed');
      }
    }
    return synced;
  }
}
