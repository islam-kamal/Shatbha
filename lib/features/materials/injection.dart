import 'package:get_it/get_it.dart';

import 'data/datasources/material_remote_datasource.dart';
import 'data/repositories/material_repository.dart';

void registerMaterials(GetIt sl) {
  sl.registerLazySingleton(() => MaterialRemoteDatasource(sl()));
  sl.registerLazySingleton(() => MaterialRepository(sl()));
}
