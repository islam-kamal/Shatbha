import 'package:get_it/get_it.dart';

import 'data/datasources/sync_remote_datasource.dart';
import 'data/repositories/sync_repository.dart';

void registerSync(GetIt sl) {
  sl.registerLazySingleton(() => SyncRemoteDatasource(sl()));
  sl.registerLazySingleton(() => SyncRepository(sl(), sl()));
}
