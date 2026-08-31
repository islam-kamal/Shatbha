import 'package:get_it/get_it.dart';

import 'data/datasources/warehouse_remote_datasource.dart';
import 'data/repositories/warehouse_repository.dart';

void registerWarehouse(GetIt sl) {
  sl.registerLazySingleton(() => WarehouseRemoteDatasource(sl()));
  sl.registerLazySingleton(() => WarehouseRepository(sl()));
}
