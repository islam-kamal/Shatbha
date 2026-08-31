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

  factory MediaFile.fromJson(Map<String, dynamic> json) => MediaFile(
        id: json['id'] as int,
        url: json['url'] as String? ?? json['path'] as String? ?? '',
        filename: json['filename'] as String?,
        mimeType: json['mime_type'] as String?,
        projectId: json['project_id'] as int?,
      );
}
