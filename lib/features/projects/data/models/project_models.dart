import '../../../../core/utils/json.dart';

class Project {
  const Project({
    required this.id,
    required this.name,
    this.description,
    this.status = 'planning',
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

  /// API statuses: planning | in_progress | delivered | handed_over
  static const _statusToApi = {
    'draft': 'planning',
    'planning': 'planning',
    'active': 'in_progress',
    'in_progress': 'in_progress',
    'delivered': 'delivered',
    'completed': 'handed_over',
    'handed_over': 'handed_over',
  };

  factory Project.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'];
    String? clientName = json['client_name'] as String?;
    if (clientName == null && customer is Map) {
      clientName = customer['name'] as String?;
    }
    return Project(
      id: json['id'] as int,
      name: (json['title'] ?? json['name']) as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'planning',
      address: (json['site_address'] ?? json['address']) as String?,
      budget: jsonMoney(json['budget_planned'] ?? json['budget']),
      clientName: clientName,
      areaSqm: json['area_sqm']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// Maps app-facing create/update fields to the API contract.
  static Map<String, dynamic> toApiBody(Map<String, dynamic> body) {
    final api = <String, dynamic>{};

    final title = body['title'] ?? body['name'];
    if (title != null) api['title'] = title;

    final address = body['site_address'] ?? body['address'];
    if (address != null) api['site_address'] = address;

    final budget = body['budget_planned'] ?? body['budget'];
    if (budget != null) api['budget_planned'] = budget;

    if (body['customer_id'] != null) api['customer_id'] = body['customer_id'];
    if (body['start_date'] != null) api['start_date'] = body['start_date'];
    if (body['end_date'] != null) api['end_date'] = body['end_date'];

    final status = body['status'] as String?;
    if (status != null) {
      api['status'] = _statusToApi[status] ?? status;
    }

    return api;
  }
}
