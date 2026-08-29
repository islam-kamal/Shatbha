import 'package:get_it/get_it.dart';

import 'data/datasources/company_remote_datasource.dart';
import 'data/repositories/company_repository.dart';

void registerCompany(GetIt sl) {
  sl.registerLazySingleton(() => CompanyRemoteDatasource(sl()));
  sl.registerLazySingleton(() => CompanyRepository(sl(), sl()));
}
