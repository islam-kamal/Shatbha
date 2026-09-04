import '../datasources/notification_remote_datasource.dart';
import '../models/notification_models.dart';

class NotificationRepository {
  NotificationRepository(this._api);
  final NotificationRemoteDatasource _api;

  Future<List<AppNotificationItem>> list() async {
    final rows = await _api.list();
    return rows.map(AppNotificationItem.fromJson).toList();
  }

  Future<int> unreadCount() => _api.unreadCount();

  Future<void> markRead(int id) => _api.markRead(id);

  Future<void> markAllRead() => _api.markAllRead();

  Future<void> registerToken(String token, String platform) =>
      _api.registerToken(token, platform);

  Future<void> revokeToken(String token) => _api.revokeToken(token);
}
