import 'package:get_it/get_it.dart';

import 'data/datasources/procurement_remote_datasource.dart';
import 'data/repositories/procurement_repository.dart';

void registerProcurement(GetIt sl) {
  sl.registerLazySingleton(() => ProcurementRemoteDatasource(sl()));
  sl.registerLazySingleton(() => ProcurementRepository(sl()));
}
