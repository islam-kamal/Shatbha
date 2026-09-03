import '../../../../core/config/env.dart';
import '../../../../core/utils/json.dart';

class MediaFile {
  const MediaFile({
    required this.id,
    required this.url,
    this.filename,
    this.mimeType,
    this.projectId,
  });

  final int id;
  final String url;
  final String? filename;
  final String? mimeType;
  final int? projectId;

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    final path = json['path'] as String?;
    final url = json['url'] as String? ?? _storageUrl(path) ?? path ?? '';
    return MediaFile(
      id: jsonInt(json['id']),
      url: url,
      filename: json['filename'] as String? ?? path?.split('/').last,
      mimeType: json['mime_type'] as String? ?? json['mime'] as String?,
      projectId: jsonIntOrNull(json['project_id']),
    );
  }
}

String? _storageUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) return path;
  return '${Env.apiBaseUrl}/storage/$path';
}
