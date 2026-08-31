import '../../../../core/utils/json.dart';

class MediaAsset {
  const MediaAsset({
    required this.id,
    required this.url,
    this.filename,
    this.mimeType,
  });

  final int id;
  final String url;
  final String? filename;
  final String? mimeType;

  factory MediaAsset.fromJson(Map<String, dynamic> json) => MediaAsset(
        id: json['id'] as int,
        url: json['url'] as String,
        filename: json['filename'] as String?,
        mimeType: json['mime_type'] as String?,
      );
}

class DesignBoard {
  const DesignBoard({
    required this.id,
    required this.projectId,
    required this.title,
    this.imageUrl,
    this.notes,
    this.sortOrder = 0,
  });

  final int id;
  final int projectId;
  final String title;
  final String? imageUrl;
  final String? notes;
  final int sortOrder;

  factory DesignBoard.fromJson(Map<String, dynamic> json) => DesignBoard(
        id: json['id'] as int,
        projectId: json['project_id'] as int,
        title: json['title'] as String,
        imageUrl: json['image_url'] as String?,
        notes: json['notes'] as String?,
        sortOrder: json['sort_order'] as int? ?? 0,
      );
}

class InspirationItem {
  const InspirationItem({
    required this.id,
    required this.projectId,
    required this.title,
    this.imageUrl,
    this.notes,
    this.sourceUrl,
  });

  final int id;
  final int projectId;
  final String title;
  final String? imageUrl;
  final String? notes;
  final String? sourceUrl;

  factory InspirationItem.fromJson(Map<String, dynamic> json) =>
      InspirationItem(
        id: json['id'] as int,
        projectId: json['project_id'] as int,
        title: json['title'] as String,
        imageUrl: json['image_url'] as String?,
        notes: json['notes'] as String?,
        sourceUrl: json['source_url'] as String?,
      );
}

class FloorPlan {
  const FloorPlan({
    required this.id,
    required this.projectId,
    required this.title,
    this.imageUrl,
    this.scale,
    this.notes,
  });

  final int id;
  final int projectId;
  final String title;
  final String? imageUrl;
  final String? scale;
  final String? notes;

  factory FloorPlan.fromJson(Map<String, dynamic> json) => FloorPlan(
        id: json['id'] as int,
        projectId: json['project_id'] as int,
        title: json['title'] as String,
        imageUrl: json['image_url'] as String?,
        scale: json['scale'] as String?,
        notes: json['notes'] as String?,
      );
}

class BoqLine {
  const BoqLine({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.qty = '1',
    this.unit,
    this.unitPrice = '0.00',
    this.total = '0.00',
    this.category,
  });

  final int id;
  final int projectId;
  final String title;
  final String? description;
  final String qty;
  final String? unit;
  final String unitPrice;
  final String total;
  final String? category;

  factory BoqLine.fromJson(Map<String, dynamic> json) => BoqLine(
        id: json['id'] as int,
        projectId: json['project_id'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        qty: json['qty']?.toString() ?? '1',
        unit: json['unit'] as String?,
        unitPrice: jsonMoney(json['unit_price']),
        total: jsonMoney(json['total']),
        category: json['category'] as String?,
      );
}
