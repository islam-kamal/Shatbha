import 'package:get_it/get_it.dart';

import 'data/datasources/vendor_remote_datasource.dart';
import 'data/repositories/vendor_repository.dart';

void registerVendors(GetIt sl) {
  sl.registerLazySingleton(() => VendorRemoteDatasource(sl()));
  sl.registerLazySingleton(() => VendorRepository(sl()));
}
