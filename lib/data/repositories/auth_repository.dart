import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/app_log.dart';
import '../../core/failures.dart';
import '../local/app_database.dart';
import '../models/models.dart';
import '../remote/api_datasource.dart';

class AuthRepository {
  AuthRepository(this._api, this._db, this._storage);

  final ApiDatasource _api;
  final AppDatabase _db;
  final FlutterSecureStorage _storage;

  Future<AuthUser?> restore() async {
    final token = await _storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      AppLog.d('no stored token', tag: 'auth');
      return null;
    }
    AppLog.d('stored token present, calling /me', tag: 'auth');
    try {
      final user = await _api.me();
      await _cacheUser(user);
      return user;
    } on Failure catch (e) {
      AppLog.e('restore /me failed, using cache', tag: 'auth', error: e);
      return _cachedUser();
    }
  }

  Future<AuthUser> login(String email, String password) async {
    AppLog.d('POST /login $email', tag: 'auth');
    final payload = await _api.login(email, password);
    final token = payload['token'] as String;
    final user = AuthUser.fromJson(payload['user'] as Map<String, dynamic>);
    await _storage.write(key: 'token', value: token);
    await _cacheUser(user);
    AppLog.d('token saved for ${user.email}', tag: 'auth');
    return user;
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } on Failure {
      // still clear local session
    }
    await _storage.delete(key: 'token');
  }

  Future<CompanyInfo?> company() async {
    try {
      final company = await _api.company();
      await _db.into(_db.cachedCompanies).insertOnConflictUpdate(
            CachedCompaniesCompanion.insert(
              id: Value(company.id),
              name: company.name,
              subtitle: Value(company.subtitle),
              pack: Value(company.pack),
            ),
          );
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

  Future<CompanyInfo> updateCompany(Map<String, dynamic> body) async {
    final company = await _api.updateCompany(body);
    await _db.into(_db.cachedCompanies).insertOnConflictUpdate(
          CachedCompaniesCompanion.insert(
            id: Value(company.id),
            name: company.name,
            subtitle: Value(company.subtitle),
            pack: Value(company.pack),
          ),
        );
    return company;
  }

  Future<AuthUser?> _cachedUser() async {
    final rows = await _db.select(_db.cachedUsers).get();
    if (rows.isEmpty) return null;
    final row = rows.first;
    final companies = await _db.select(_db.cachedCompanies).get();
    return AuthUser(
      id: row.id,
      name: row.name,
      email: row.email,
      role: row.role,
      company: companies.isEmpty
          ? null
          : CompanyInfo(
              id: companies.first.id,
              name: companies.first.name,
              subtitle: companies.first.subtitle,
              pack: companies.first.pack,
            ),
    );
  }

  Future<void> _cacheUser(AuthUser user) async {
    await _db.into(_db.cachedUsers).insertOnConflictUpdate(
          CachedUsersCompanion.insert(
            id: Value(user.id),
            companyId: user.company?.id ?? 0,
            name: user.name,
            email: user.email,
            role: user.role,
          ),
        );
    final company = user.company;
    if (company != null) {
      await _db.into(_db.cachedCompanies).insertOnConflictUpdate(
            CachedCompaniesCompanion.insert(
              id: Value(company.id),
              name: company.name,
              subtitle: Value(company.subtitle),
              pack: Value(company.pack),
            ),
          );
    }
  }
}
