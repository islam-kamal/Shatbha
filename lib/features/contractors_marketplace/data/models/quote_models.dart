import '../../../../core/utils/json.dart';

class QuoteRequest {
  const QuoteRequest({
    required this.id,
    required this.projectId,
    required this.contractorId,
    this.projectName,
    this.contractorName,
    this.status = 'pending',
    this.description,
    this.amount,
    this.notes,
    this.createdAt,
    this.responseNotes,
  });

  final int id;
  final int projectId;
  final int contractorId;
  final String? projectName;
  final String? contractorName;
  final String status;
  final String? description;
  final String? amount;
  final String? notes;
  final String? createdAt;
  final String? responseNotes;

  bool get isPending => status == 'pending' || status == 'draft';
  bool get isResponded => status == 'responded' || status == 'sent';
  bool get isAccepted => status == 'accepted';

  factory QuoteRequest.fromJson(Map<String, dynamic> json) {
    final project = json['project'];
    final vendor = json['vendor'];
    final lines = json['lines'];
    String? amount;
    if (lines is List && lines.isNotEmpty) {
      var total = 0.0;
      for (final line in lines) {
        if (line is Map<String, dynamic>) {
          final qty = double.tryParse('${line['qty']}') ?? 0;
          final price = double.tryParse('${line['unit_price']}') ?? 0;
          total += qty * price;
        }
      }
      if (total > 0) amount = total.toStringAsFixed(2);
    }

    return QuoteRequest(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      contractorId: (json['vendor_account_id'] ?? json['contractor_id']) as int,
      projectName: project is Map<String, dynamic>
          ? (project['title'] as String? ?? project['name'] as String?)
          : json['project_name'] as String?,
      contractorName: vendor is Map<String, dynamic>
          ? vendor['name'] as String?
          : json['contractor_name'] as String?,
      status: json['status'] as String? ?? 'pending',
      description: json['title'] as String? ?? json['description'] as String?,
      amount: amount ?? (json['amount'] != null ? jsonMoney(json['amount']) : null),
      notes: json['notes'] as String?,
      createdAt: json['created_at']?.toString(),
      responseNotes: json['response_notes'] as String?,
    );
  }
}
