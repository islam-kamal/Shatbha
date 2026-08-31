import 'package:get_it/get_it.dart';

import 'data/datasources/handover_remote_datasource.dart';
import 'data/repositories/handover_repository.dart';

void registerHandover(GetIt sl) {
  sl.registerLazySingleton(() => HandoverRemoteDatasource(sl()));
  sl.registerLazySingleton(() => HandoverRepository(sl()));
}
