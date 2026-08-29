import 'package:get_it/get_it.dart';

import 'data/datasources/report_remote_datasource.dart';
import 'data/repositories/report_repository.dart';

void registerReports(GetIt sl) {
  sl.registerLazySingleton(() => ReportRemoteDatasource(sl()));
  sl.registerLazySingleton(() => ReportRepository(sl()));
}
