import 'package:get_it/get_it.dart';

import 'data/datasources/design_remote_datasource.dart';
import 'data/repositories/design_repository.dart';

void registerDesign(GetIt sl) {
  sl.registerLazySingleton(() => DesignRemoteDatasource(sl()));
  sl.registerLazySingleton(() => DesignRepository(sl()));
}
