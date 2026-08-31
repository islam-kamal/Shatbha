import 'package:get_it/get_it.dart';

import 'data/datasources/project_remote_datasource.dart';
import 'data/repositories/project_repository.dart';

void registerProjects(GetIt sl) {
  sl.registerLazySingleton(() => ProjectRemoteDatasource(sl()));
  sl.registerLazySingleton(() => ProjectRepository(sl()));
}
