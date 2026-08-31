import '../../../../core/utils/json.dart';

class Project {
  const Project({
    required this.id,
    required this.name,
    this.description,
    this.status = 'draft',
    this.address,
    this.budget = '0.00',
    this.clientName,
    this.areaSqm,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String? description;
  final String status;
  final String? address;
  final String budget;
  final String? clientName;
  final String? areaSqm;
  final String? createdAt;
  final String? updatedAt;

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as int,
        name: (json['title'] ?? json['name']) as String,
        description: json['description'] as String?,
        status: json['status'] as String? ?? 'draft',
        address: json['address'] as String?,
        budget: jsonMoney(json['budget']),
        clientName: json['client_name'] as String?,
        areaSqm: json['area_sqm']?.toString(),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );

  /// Maps app-facing create/update fields to the API contract.
  static Map<String, dynamic> toApiBody(Map<String, dynamic> body) {
    final api = Map<String, dynamic>.from(body);
    final name = api.remove('name');
    if (name != null && !api.containsKey('title')) {
      api['title'] = name;
    }
    final status = api['status'];
    if (status == 'active') {
      api['status'] = 'in_progress';
    }
    return api;
  }
}
