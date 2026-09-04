import 'package:dio/dio.dart';

class NotificationRemoteDatasource {
  NotificationRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _dio.get('/notifications');
    return ((res.data['data'] as List?) ?? []).cast<Map<String, dynamic>>();
  }

  Future<int> unreadCount() async {
    final res = await _dio.get('/notifications/unread-count');
    return (res.data['data']?['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(int id) => _dio.post('/notifications/$id/read');

  Future<void> markAllRead() => _dio.post('/notifications/read-all');

  Future<void> registerToken(String token, String platform) =>
      _dio.post('/device-tokens', data: {'token': token, 'platform': platform});

  Future<void> revokeToken(String token) =>
      _dio.delete('/device-tokens', data: {'token': token});
}
