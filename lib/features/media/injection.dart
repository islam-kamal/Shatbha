import 'package:get_it/get_it.dart';

import 'data/datasources/media_remote_datasource.dart';
import 'data/repositories/media_repository.dart';

void registerMedia(GetIt sl) {
  sl.registerLazySingleton(() => MediaRemoteDatasource(sl()));
  sl.registerLazySingleton(() => MediaRepository(sl()));
}
