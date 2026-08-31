import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/media_models.dart';

class MediaRemoteDatasource {
  MediaRemoteDatasource(this._dio);
  final Dio _dio;

  Future<MediaFile> upload(String filePath, {String? filename, int? projectId}) {
    return guardDio(() async {
      final form = FormData.fromMap({
        if (projectId != null) 'project_id': projectId,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filename,
        ),
      });
      final res = await _dio.post<Map<String, dynamic>>('/media', data: form);
      return MediaFile.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }
}
