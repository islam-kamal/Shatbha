import 'package:get_it/get_it.dart';

import 'data/datasources/catalog_remote_datasource.dart';
import 'data/repositories/catalog_repository.dart';

void registerCatalog(GetIt sl) {
  sl.registerLazySingleton(() => CatalogRemoteDatasource(sl()));
  sl.registerLazySingleton(() => CatalogRepository(sl(), sl()));
}
