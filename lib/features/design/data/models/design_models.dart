import '../../../../core/config/env.dart';
import '../../../../core/utils/json.dart';

String? _mediaUrl(Map<String, dynamic> json) {
  final direct = json['image_url'] as String?;
  if (direct != null && direct.isNotEmpty) return direct;
  final media = json['media'];
  final map = media is Map<String, dynamic> ? media : json;
  final url = map['url'] as String?;
  if (url != null && url.isNotEmpty) return url;
  final path = map['path'] as String?;
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) return path;
  return '${Env.apiBaseUrl}/storage/$path';
}

bool _isPdf(Map<String, dynamic> json) {
  String? mime = json['mime'] as String? ?? json['mime_type'] as String?;
  String? path = json['path'] as String?;
  final media = json['media'];
  if (media is Map<String, dynamic>) {
    mime ??= media['mime'] as String? ?? media['mime_type'] as String?;
    path ??= media['path'] as String?;
  }
  return (mime?.contains('pdf') ?? false) ||
      (path?.toLowerCase().endsWith('.pdf') ?? false);
}

const kDesignRooms = [
  'Living',
  'Bedroom',
  'Kitchen',
  'Bathroom',
  'Corridor',
  'Balcony',
  'Other',
];

const kRoomLabels = {
  'Living': 'المعيشة',
  'Bedroom': 'غرفة نوم',
  'Kitchen': 'مطبخ',
  'Bathroom': 'حمام',
  'Corridor': 'ممر',
  'Balcony': 'بلكونة',
  'Other': 'أخرى',
};

const kInspirationCategories = [
  'reference',
  'color',
  'material',
  'furniture',
  'lighting',
  'doors_floors',
  'other',
];

const kCategoryLabels = {
  'reference': 'مرجع',
  'color': 'ألوان',
  'material': 'خامات',
  'furniture': 'أثاث',
  'lighting': 'إضاءة',
  'doors_floors': 'أبواب وأرضيات',
  'other': 'أخرى',
};

const kPlanTypes = [
  'floor',
  'furniture',
  'electrical',
  'lighting',
  'plumbing',
  'ceiling',
  'flooring',
  'elevation',
  'render_3d',
];

const kPlanTypeLabels = {
  'floor': 'مخطط أرضي',
  'furniture': 'أثاث',
  'electrical': 'كهرباء',
  'lighting': 'إضاءة',
  'plumbing': 'سباكة',
  'ceiling': 'أسقف',
  'flooring': 'أرضيات',
  'elevation': 'واجهات',
  'render_3d': 'ثلاثي الأبعاد',
};

const kBoardStyles = [
  'modern',
  'classic',
  'minimal',
  'neoclassic',
  'industrial',
  'other',
];

const kStyleLabels = {
  'modern': 'مودرن',
  'classic': 'كلاسيك',
  'minimal': 'مينيمال',
  'neoclassic': 'نيوكلاسيك',
  'industrial': 'صناعي',
  'other': 'أخرى',
};

String designStatusLabel(String status) {
  switch (status) {
    case 'approved':
      return 'معتمد';
    case 'rejected':
      return 'مرفوض';
    case 'pending':
      return 'بانتظار العميل';
    case 'draft':
      return 'مسودة';
    default:
      return status;
  }
}

String planStatusLabel(String status) {
  switch (status) {
    case 'approved':
      return 'معتمد';
    case 'rejected':
      return 'مرفوض';
    case 'in_review':
      return 'قيد المراجعة';
    case 'draft':
      return 'مسودة';
    default:
      return status;
  }
}

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
        id: jsonInt(json['id']),
        url: _mediaUrl(json) ?? '',
        filename: json['filename'] as String?,
        mimeType: json['mime_type'] as String? ?? json['mime'] as String?,
      );
}

class DesignBoard {
  const DesignBoard({
    required this.id,
    required this.projectId,
    required this.title,
    this.style,
    this.designerNotes,
    this.inspiration = const [],
  });

  final int id;
  final int projectId;
  final String title;
  final String? style;
  final String? designerNotes;
  final List<InspirationItem> inspiration;

  factory DesignBoard.fromJson(Map<String, dynamic> json) {
    final items = json['inspiration_items'];
    return DesignBoard(
      id: jsonInt(json['id']),
      projectId: jsonInt(json['project_id']),
      title: json['title'] as String? ?? '',
      style: json['style'] as String?,
      designerNotes: json['designer_notes'] as String? ?? json['notes'] as String?,
      inspiration: items is List
          ? items
              .whereType<Map<String, dynamic>>()
              .map(InspirationItem.fromJson)
              .toList()
          : const [],
    );
  }
}

class InspirationItem {
  const InspirationItem({
    required this.id,
    required this.boardId,
    required this.title,
    this.room,
    this.category,
    this.imageUrl,
    this.notes,
    this.isPdf = false,
  });

  final int id;
  final int boardId;
  final String title;
  final String? room;
  final String? category;
  final String? imageUrl;
  final String? notes;
  final bool isPdf;

  factory InspirationItem.fromJson(Map<String, dynamic> json) =>
      InspirationItem(
        id: jsonInt(json['id']),
        boardId: jsonInt(json['design_board_id'] ?? json['project_id']),
        title: json['title'] as String? ?? '',
        room: json['room'] as String?,
        category: json['category'] as String?,
        imageUrl: _mediaUrl(json),
        notes: json['notes'] as String? ?? json['tags'] as String?,
        isPdf: _isPdf(json),
      );
}

class DesignPlanComment {
  const DesignPlanComment({
    required this.id,
    required this.body,
    this.authorLabel,
    this.createdAt,
  });

  final int id;
  final String body;
  final String? authorLabel;
  final String? createdAt;

  factory DesignPlanComment.fromJson(Map<String, dynamic> json) =>
      DesignPlanComment(
        id: jsonInt(json['id']),
        body: json['body'] as String? ?? '',
        authorLabel: json['author_label'] as String?,
        createdAt: json['created_at']?.toString(),
      );
}

class DesignPlan {
  const DesignPlan({
    required this.id,
    required this.projectId,
    required this.title,
    this.type = 'floor',
    this.room,
    this.version = 1,
    this.status = 'draft',
    this.imageUrl,
    this.isPdf = false,
    this.inspirationItemId,
    this.comments = const [],
  });

  final int id;
  final int projectId;
  final String title;
  final String type;
  final String? room;
  final int version;
  final String status;
  final String? imageUrl;
  final bool isPdf;
  final int? inspirationItemId;
  final List<DesignPlanComment> comments;

  factory DesignPlan.fromJson(Map<String, dynamic> json) {
    final comments = json['comments'];
    return DesignPlan(
      id: jsonInt(json['id']),
      projectId: jsonInt(json['project_id']),
      title: json['title'] as String? ?? json['room'] as String? ?? '',
      type: json['type'] as String? ?? 'floor',
      room: json['room'] as String?,
      version: jsonInt(json['version'] ?? 1),
      status: json['status'] as String? ?? 'draft',
      imageUrl: _mediaUrl(json),
      isPdf: _isPdf(json),
      inspirationItemId: jsonIntOrNull(json['inspiration_item_id']),
      comments: comments is List
          ? comments
              .whereType<Map<String, dynamic>>()
              .map(DesignPlanComment.fromJson)
              .toList()
          : const [],
    );
  }
}

/// Back-compat alias used by older call sites.
typedef FloorPlan = DesignPlan;

class BoqLine {
  const BoqLine({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.room,
    this.qty = '1',
    this.unit,
    this.unitPrice = '0.00',
    this.total = '0.00',
    this.category,
    this.inspirationItemId,
  });

  final int id;
  final int projectId;
  final String title;
  final String? description;
  final String? room;
  final String qty;
  final String? unit;
  final String unitPrice;
  final String total;
  final String? category;
  final int? inspirationItemId;

  factory BoqLine.fromJson(Map<String, dynamic> json) {
    final qty = json['qty']?.toString() ?? '1';
    final unitPrice = jsonMoney(json['unit_price'] ?? json['rate']);
    final qtyNum = double.tryParse(qty) ?? 1;
    final priceNum = double.tryParse(unitPrice) ?? 0;
    final total = json['total'] != null
        ? jsonMoney(json['total'])
        : (qtyNum * priceNum).toStringAsFixed(2);
    return BoqLine(
      id: jsonInt(json['id']),
      projectId: jsonInt(json['project_id']),
      title: json['title'] as String? ?? json['description'] as String? ?? '',
      description: json['description'] as String?,
      room: json['room'] as String?,
      qty: qty,
      unit: json['unit'] as String?,
      unitPrice: unitPrice,
      total: total,
      category: json['category'] as String? ?? json['trade'] as String?,
      inspirationItemId: jsonIntOrNull(json['inspiration_item_id']),
    );
  }
}
