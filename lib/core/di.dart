import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'api_client.dart';
import '../data/local/app_database.dart';
import '../data/remote/api_datasource.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/job_repository.dart';
import '../data/repositories/journal_repository.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/sync_repository.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  if (sl.isRegistered<AppDatabase>()) return;

  const storage = FlutterSecureStorage();
  final db = AppDatabase();
  final dio = createDio(storage);
  final api = ApiDatasource(dio);

  sl.registerSingleton<FlutterSecureStorage>(storage);
  sl.registerSingleton<AppDatabase>(db);
  sl.registerSingleton<Dio>(dio);
  sl.registerSingleton<ApiDatasource>(api);
  sl.registerSingleton<AuthRepository>(AuthRepository(api, db, storage));
  sl.registerSingleton<CatalogRepository>(CatalogRepository(api, db));
  sl.registerSingleton<JournalRepository>(JournalRepository(api, db));
  sl.registerSingleton<ExpenseRepository>(ExpenseRepository(api, db));
  sl.registerSingleton<JobRepository>(JobRepository(api, db));
  sl.registerSingleton<ReportRepository>(ReportRepository(api));
  sl.registerSingleton<SyncRepository>(SyncRepository(api, db));
}
