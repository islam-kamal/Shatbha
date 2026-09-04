import 'package:get_it/get_it.dart';

import 'data/project_os_api.dart';

void registerProjectOs(GetIt sl) {
  sl.registerLazySingleton(() => ProjectOsApi(sl()));
}
