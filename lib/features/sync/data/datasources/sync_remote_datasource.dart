import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

class SyncRemoteDatasource {
  SyncRemoteDatasource(this._dio);
  final Dio _dio;

  Future<void> replay(String method, String path, Map<String, dynamic> body) {
    return guardDio(
      () => _dio.request<void>(
        path,
        data: body,
        options: Options(method: method),
      ),
    );
  }
}
