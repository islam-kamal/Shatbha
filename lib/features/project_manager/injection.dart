import 'package:get_it/get_it.dart';

import 'data/datasources/pm_remote_datasource.dart';
import 'data/repositories/pm_repository.dart';

void registerProjectManager(GetIt sl) {
  sl.registerLazySingleton(() => PmRemoteDatasource(sl()));
  sl.registerLazySingleton(() => PmRepository(sl()));
}
