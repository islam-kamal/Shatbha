import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_log.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart';

class AuthRepository {
  AuthRepository(this._api, this._db, this._storage);

  static const _tokenKey = 'token';
  static const _authKindKey = 'auth_kind';
  static const _companyKind = 'company';
  static const _vendorKind = 'vendor';
  static const _clientKind = 'client';

  final AuthRemoteDatasource _api;
  final AppDatabase _db;
  final FlutterSecureStorage _storage;

  Future<AuthUser?> restore() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      AppLog.d('no stored token', tag: 'auth');
      return null;
    }
    final kind = await _storage.read(key: _authKindKey) ?? _companyKind;
    if (kind == _vendorKind) {
      AppLog.d('stored vendor token, restoring from cache', tag: 'auth');
      return cachedUser();
    }
    if (kind == _clientKind) {
      AppLog.d('stored client token, calling /client/me', tag: 'auth');
      try {
        final user = await _api.clientMe();
        await cacheUser(user);
        return user;
      } on Failure catch (e) {
        AppLog.e('restore /client/me failed, using cache', tag: 'auth', error: e);
        return cachedUser();
      }
    }
    AppLog.d('stored token present, calling /me', tag: 'auth');
    try {
      final user = await _api.me();
      await cacheUser(user);
      return user;
    } on Failure catch (e) {
      AppLog.e('restore /me failed, using cache', tag: 'auth', error: e);
      return cachedUser();
    }
  }

  Future<AuthUser> login(String email, String password) async {
    AppLog.d('POST /login $email', tag: 'auth');
    try {
      return await _loginCompany(email, password);
    } on ValidationFailure {
      AppLog.d('company login failed, trying /vendor/login', tag: 'auth');
      try {
        return await _loginVendor(email, password);
      } on ValidationFailure {
        AppLog.d('vendor login failed, trying /client/login', tag: 'auth');
        return _loginClient(email, password);
      }
    }
  }

  Future<AuthUser> _loginCompany(String email, String password) async {
    final payload = await _api.login(email, password);
    final token = payload['token'] as String;
    final user = AuthUser.fromJson(payload['user'] as Map<String, dynamic>);
    await _persistSession(token: token, kind: _companyKind, user: user);
    return user;
  }

  Future<AuthUser> _loginVendor(String email, String password) async {
    AppLog.d('POST /vendor/login $email', tag: 'auth');
    final payload = await _api.vendorLogin(email, password);
    final token = payload['token'] as String;
    final user =
        AuthUser.fromVendorJson(payload['vendor'] as Map<String, dynamic>);
    await _persistSession(token: token, kind: _vendorKind, user: user);
    return user;
  }

  Future<AuthUser> _loginClient(String email, String password) async {
    AppLog.d('POST /client/login $email', tag: 'auth');
    final payload = await _api.clientLogin(email, password);
    final token = payload['token'] as String;
    final user =
        AuthUser.fromClientJson(payload['client'] as Map<String, dynamic>);
    await _persistSession(token: token, kind: _clientKind, user: user);
    return user;
  }

  Future<List<Map<String, dynamic>>> clientProjects() => _api.clientProjects();

  Future<void> _persistSession({
    required String token,
    required String kind,
    required AuthUser user,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _authKindKey, value: kind);
    await cacheUser(user);
    AppLog.d('token saved for ${user.email} ($kind)', tag: 'auth');
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } on Failure {
      // still clear local session
    }
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _authKindKey);
  }

  Future<AuthUser?> cachedUser() async {
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

  Future<void> cacheUser(AuthUser user) async {
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
