import '../../../../core/utils/json.dart';
import '../../../catalog/data/models/catalog_models.dart';

class JobPayment {
  const JobPayment({
    required this.id,
    required this.sequence,
    required this.amount,
    required this.paidOn,
  });

  final int id;
  final int sequence;
  final String amount;
  final String paidOn;

  factory JobPayment.fromJson(Map<String, dynamic> json) => JobPayment(
        id: json['id'] as int,
        sequence: json['sequence'] as int? ?? 1,
        amount: jsonMoney(json['amount']),
        paidOn: jsonDate(json['paid_on']),
      );
}

class ContractorJob {
  const ContractorJob({
    required this.id,
    required this.title,
    required this.qty,
    required this.unitPrice,
    required this.total,
    required this.paid,
    required this.remaining,
    this.contractor,
    this.payments = const [],
  });

  final int id;
  final String title;
  final String qty;
  final String unitPrice;
  final String total;
  final String paid;
  final String remaining;
  final Party? contractor;
  final List<JobPayment> payments;

  factory ContractorJob.fromJson(Map<String, dynamic> json) => ContractorJob(
        id: json['id'] as int,
        title: json['title'] as String,
        qty: jsonMoney(json['qty']),
        unitPrice: jsonMoney(json['unit_price']),
        total: jsonMoney(json['total']),
        paid: jsonMoney(json['paid']),
        remaining: jsonMoney(json['remaining']),
        contractor: json['contractor'] is Map<String, dynamic>
            ? Party.fromJson(json['contractor'] as Map<String, dynamic>)
            : null,
        payments: (json['payments'] as List<dynamic>? ?? [])
            .map((e) => JobPayment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
