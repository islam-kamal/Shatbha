import 'package:get_it/get_it.dart';

import 'data/datasources/quote_remote_datasource.dart';
import 'data/repositories/quote_repository.dart';

void registerContractorsMarketplace(GetIt sl) {
  sl.registerLazySingleton(() => QuoteRemoteDatasource(sl()));
  sl.registerLazySingleton(() => QuoteRepository(sl()));
}
