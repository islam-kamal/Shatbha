import 'package:get_it/get_it.dart';

import 'data/datasources/notification_remote_datasource.dart';
import 'data/repositories/notification_repository.dart';
import 'presentation/services/push_notification_service.dart';

void registerNotifications(GetIt sl) {
  sl.registerLazySingleton(() => NotificationRemoteDatasource(sl()));
  sl.registerLazySingleton(() => NotificationRepository(sl()));
  sl.registerLazySingleton(() => PushNotificationService(sl()));
}
