import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/models/auth_models.dart';
import '../datasources/company_remote_datasource.dart';

class CompanyRepository {
  CompanyRepository(this._api, this._db);
  final CompanyRemoteDatasource _api;
  final AppDatabase _db;

  Future<CompanyInfo?> get() async {
    try {
      final company = await _api.get();
      await _cache(company);
      return company;
    } on Failure {
      final rows = await _db.select(_db.cachedCompanies).get();
      if (rows.isEmpty) return null;
      final row = rows.first;
      return CompanyInfo(
        id: row.id,
        name: row.name,
        subtitle: row.subtitle,
        pack: row.pack,
      );
    }
  }

  Future<CompanyInfo> update(Map<String, dynamic> body) async {
    final company = await _api.update(body);
    await _cache(company);
    return company;
  }

  Future<void> _cache(CompanyInfo company) {
    return _db.into(_db.cachedCompanies).insertOnConflictUpdate(
          CachedCompaniesCompanion.insert(
            id: Value(company.id),
            name: company.name,
            subtitle: Value(company.subtitle),
            pack: Value(company.pack),
          ),
        );
  }
}
