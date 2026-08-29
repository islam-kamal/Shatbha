import 'package:get_it/get_it.dart';

import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository.dart';

void registerAuth(GetIt sl) {
  sl.registerLazySingleton(() => AuthRemoteDatasource(sl()));
  sl.registerLazySingleton(() => AuthRepository(sl(), sl(), sl()));
}
