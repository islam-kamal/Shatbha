import 'package:get_it/get_it.dart';

import 'data/datasources/expense_remote_datasource.dart';
import 'data/repositories/expense_repository.dart';

void registerExpenses(GetIt sl) {
  sl.registerLazySingleton(() => ExpenseRemoteDatasource(sl()));
  sl.registerLazySingleton(() => ExpenseRepository(sl(), sl()));
}
