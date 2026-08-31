import '../../../../core/utils/json.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    this.sku,
    this.category,
    this.unit,
    this.price = '0.00',
    this.supplierId,
    this.supplierName,
    this.imageUrl,
    this.description,
  });

  final int id;
  final String name;
  final String? sku;
  final String? category;
  final String? unit;
  final String price;
  final int? supplierId;
  final String? supplierName;
  final String? imageUrl;
  final String? description;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        name: json['name'] as String,
        sku: json['sku'] as String?,
        category: json['category'] as String?,
        unit: json['unit'] as String?,
        price: jsonMoney(json['price']),
        supplierId: json['supplier_id'] as int?,
        supplierName: json['supplier_name'] as String?,
        imageUrl: json['image_url'] as String?,
        description: json['description'] as String?,
      );
}

class ProjectMaterial {
  const ProjectMaterial({
    required this.id,
    required this.projectId,
    required this.productId,
    this.productName,
    this.qty = '1',
    this.unit,
    this.unitPrice = '0.00',
    this.total = '0.00',
    this.notes,
  });

  final int id;
  final int projectId;
  final int productId;
  final String? productName;
  final String qty;
  final String? unit;
  final String unitPrice;
  final String total;
  final String? notes;

  factory ProjectMaterial.fromJson(Map<String, dynamic> json) =>
      ProjectMaterial(
        id: json['id'] as int,
        projectId: json['project_id'] as int,
        productId: json['product_id'] as int,
        productName: json['product_name'] as String?,
        qty: json['qty']?.toString() ?? '1',
        unit: json['unit'] as String?,
        unitPrice: jsonMoney(json['unit_price']),
        total: jsonMoney(json['total']),
        notes: json['notes'] as String?,
      );
}
