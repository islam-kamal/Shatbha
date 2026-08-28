import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/failures.dart';
import '../local/app_database.dart';
import '../models/models.dart';
import '../remote/api_datasource.dart';

class JobRepository {
  JobRepository(this._api, this._db);
  final ApiDatasource _api;
  final AppDatabase _db;

  Future<List<ContractorJob>> list() async {
    try {
      final rows = await _api.jobs();
      for (final row in rows) {
        await _upsert(row);
      }
      return rows;
    } on Failure {
      final local = await _db.select(_db.cachedJobs).get();
      return local.map(_fromRow).toList();
    }
  }

  Future<ContractorJob> create(Map<String, dynamic> body) async {
    try {
      final row = await _api.createJob(body);
      await _upsert(row);
      return row;
    } on Failure catch (e) {
      if (e is! OfflineFailure) rethrow;
      await _db.enqueue('POST', '/jobs', jsonEncode(body));
      final qty = double.tryParse(body['qty'].toString()) ?? 0;
      final price = double.tryParse(body['unit_price'].toString()) ?? 0;
      final total = qty * price;
      final row = ContractorJob(
        id: DateTime.now().millisecondsSinceEpoch,
        title: body['title'] as String,
        qty: qty.toStringAsFixed(2),
        unitPrice: price.toStringAsFixed(2),
        total: total.toStringAsFixed(2),
        paid: '0.00',
        remaining: total.toStringAsFixed(2),
      );
      await _upsert(row);
      return row;
    }
  }

  Future<ContractorJob> pay(int jobId, Map<String, dynamic> body) async {
    try {
      final row = await _api.payJob(jobId, body);
      await _upsert(row);
      return row;
    } on Failure catch (e) {
      if (e is! OfflineFailure) rethrow;
      await _db.enqueue('POST', '/jobs/$jobId/payments', jsonEncode(body));
      final jobs = await list();
      final job = jobs.firstWhere((j) => j.id == jobId);
      final paid = (double.tryParse(job.paid) ?? 0) +
          (double.tryParse(body['amount'].toString()) ?? 0);
      final total = double.tryParse(job.total) ?? 0;
      final updated = ContractorJob(
        id: job.id,
        title: job.title,
        qty: job.qty,
        unitPrice: job.unitPrice,
        total: job.total,
        paid: paid.toStringAsFixed(2),
        remaining: (total - paid).toStringAsFixed(2),
        contractor: job.contractor,
        payments: job.payments,
      );
      await _upsert(updated);
      return updated;
    }
  }

  Future<void> _upsert(ContractorJob row) {
    return _db.into(_db.cachedJobs).insertOnConflictUpdate(
          CachedJobsCompanion.insert(
            id: Value(row.id),
            title: row.title,
            qty: row.qty,
            unitPrice: row.unitPrice,
            total: row.total,
            paid: row.paid,
            remaining: row.remaining,
            contractorName: Value(row.contractor?.name),
            contractorId: Value(row.contractor?.id),
          ),
        );
  }

  ContractorJob _fromRow(CachedJob row) => ContractorJob(
        id: row.id,
        title: row.title,
        qty: row.qty,
        unitPrice: row.unitPrice,
        total: row.total,
        paid: row.paid,
        remaining: row.remaining,
        contractor: row.contractorId == null
            ? null
            : Party(
                id: row.contractorId!,
                type: 'contractor',
                name: row.contractorName ?? '',
              ),
      );
}
