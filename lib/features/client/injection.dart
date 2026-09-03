import 'package:get_it/get_it.dart';

import 'data/datasources/client_remote_datasource.dart';
import 'data/repositories/client_repository.dart';

void registerClient(GetIt sl) {
  sl.registerLazySingleton(() => ClientRemoteDatasource(sl()));
  sl.registerLazySingleton(() => ClientRepository(sl()));
}
