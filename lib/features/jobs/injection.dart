import 'package:get_it/get_it.dart';

import 'data/datasources/job_remote_datasource.dart';
import 'data/repositories/job_repository.dart';

void registerJobs(GetIt sl) {
  sl.registerLazySingleton(() => JobRemoteDatasource(sl()));
  sl.registerLazySingleton(() => JobRepository(sl(), sl()));
}
