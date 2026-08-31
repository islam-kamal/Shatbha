import '../../../../core/utils/json.dart';

class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    this.projectId,
    this.vendorId,
    this.poNumber,
    this.status = 'draft',
    this.total = '0.00',
    this.orderedAt,
    this.vendorName,
    this.projectName,
    this.lines = const [],
  });

  final int id;
  final int? projectId;
  final int? vendorId;
  final String? poNumber;
  final String status;
  final String total;
  final String? orderedAt;
  final String? vendorName;
  final String? projectName;
  final List<PoLine> lines;

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) => PurchaseOrder(
        id: json['id'] as int,
        projectId: json['project_id'] as int?,
        vendorId: json['vendor_id'] as int?,
        poNumber: json['po_number'] as String?,
        status: json['status'] as String? ?? 'draft',
        total: jsonMoney(json['total']),
        orderedAt: json['ordered_at'] != null
            ? jsonDate(json['ordered_at'])
            : null,
        vendorName: json['vendor'] is Map
            ? json['vendor']['name'] as String?
            : json['vendor_name'] as String?,
        projectName: json['project'] is Map
            ? json['project']['name'] as String?
            : json['project_name'] as String?,
        lines: (json['lines'] as List<dynamic>? ?? const [])
            .map((e) => PoLine.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PoLine {
  const PoLine({
    required this.id,
    this.productId,
    this.description,
    this.quantity = '0',
    this.unitPrice = '0.00',
    this.receivedQty = '0',
  });

  final int id;
  final int? productId;
  final String? description;
  final String quantity;
  final String unitPrice;
  final String receivedQty;

  factory PoLine.fromJson(Map<String, dynamic> json) => PoLine(
        id: json['id'] as int,
        productId: json['product_id'] as int?,
        description: json['description'] as String? ??
            (json['product'] is Map ? json['product']['name'] as String? : null),
        quantity: json['quantity']?.toString() ?? '0',
        unitPrice: jsonMoney(json['unit_price']),
        receivedQty: json['received_qty']?.toString() ?? '0',
      );
}

class GoodsReceipt {
  const GoodsReceipt({
    required this.id,
    required this.purchaseOrderId,
    this.receivedAt,
    this.notes,
  });

  final int id;
  final int purchaseOrderId;
  final String? receivedAt;
  final String? notes;

  factory GoodsReceipt.fromJson(Map<String, dynamic> json) => GoodsReceipt(
        id: json['id'] as int,
        purchaseOrderId: json['purchase_order_id'] as int,
        receivedAt: json['received_at'] != null
            ? jsonDate(json['received_at'])
            : null,
        notes: json['notes'] as String?,
      );
}
