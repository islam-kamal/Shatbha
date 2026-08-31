import '../datasources/media_remote_datasource.dart';
import '../models/media_models.dart';

class MediaRepository {
  MediaRepository(this._api);
  final MediaRemoteDatasource _api;

  Future<MediaFile> upload(
    String filePath, {
    String? filename,
    int? projectId,
  }) =>
      _api.upload(filePath, filename: filename, projectId: projectId);
}
