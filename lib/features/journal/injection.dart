import 'package:get_it/get_it.dart';

import 'data/datasources/journal_remote_datasource.dart';
import 'data/repositories/journal_repository.dart';

void registerJournal(GetIt sl) {
  sl.registerLazySingleton(() => JournalRemoteDatasource(sl()));
  sl.registerLazySingleton(() => JournalRepository(sl(), sl()));
}
