import '../../../../core/utils/json.dart';

class Warehouse {
  const Warehouse({
    required this.id,
    required this.name,
    this.location,
    this.isDefault = false,
  });

  final int id;
  final String name;
  final String? location;
  final bool isDefault;

  factory Warehouse.fromJson(Map<String, dynamic> json) => Warehouse(
        id: json['id'] as int,
        name: json['name'] as String,
        location: json['location'] as String?,
        isDefault: json['is_default'] as bool? ?? false,
      );
}

class StockLevel {
  const StockLevel({
    required this.id,
    required this.warehouseId,
    this.productId,
    this.productName,
    this.quantity = '0',
    this.unit,
  });

  final int id;
  final int warehouseId;
  final int? productId;
  final String? productName;
  final String quantity;
  final String? unit;

  factory StockLevel.fromJson(Map<String, dynamic> json) => StockLevel(
        id: json['id'] as int,
        warehouseId: json['warehouse_id'] as int,
        productId: json['product_id'] as int?,
        productName: json['product_name'] as String? ??
            (json['product'] is Map ? json['product']['name'] as String? : null),
        quantity: json['quantity']?.toString() ?? '0',
        unit: json['unit'] as String?,
      );
}

class StockMovement {
  const StockMovement({
    required this.id,
    this.movementType,
    this.fromWarehouseId,
    this.toWarehouseId,
    this.projectId,
    this.notes,
    this.createdAt,
  });

  final int id;
  final String? movementType;
  final int? fromWarehouseId;
  final int? toWarehouseId;
  final int? projectId;
  final String? notes;
  final String? createdAt;

  factory StockMovement.fromJson(Map<String, dynamic> json) => StockMovement(
        id: json['id'] as int,
        movementType: json['movement_type'] as String? ?? json['type'] as String?,
        fromWarehouseId: json['from_warehouse_id'] as int?,
        toWarehouseId: json['to_warehouse_id'] as int?,
        projectId: json['project_id'] as int?,
        notes: json['notes'] as String?,
        createdAt: json['created_at'] != null
            ? jsonDate(json['created_at'])
            : null,
      );
}

class DeliveryNote {
  const DeliveryNote({
    required this.id,
    this.projectId,
    this.warehouseId,
    this.notes,
    this.deliveredAt,
  });

  final int id;
  final int? projectId;
  final int? warehouseId;
  final String? notes;
  final String? deliveredAt;

  factory DeliveryNote.fromJson(Map<String, dynamic> json) => DeliveryNote(
        id: json['id'] as int,
        projectId: json['project_id'] as int?,
        warehouseId: json['warehouse_id'] as int?,
        notes: json['notes'] as String?,
        deliveredAt: json['delivered_at'] != null
            ? jsonDate(json['delivered_at'])
            : null,
      );
}
