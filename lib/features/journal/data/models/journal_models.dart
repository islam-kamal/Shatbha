import '../../../../core/utils/json.dart';
import '../../../catalog/data/models/catalog_models.dart';

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.customerId,
    required this.entryDate,
    required this.entryType,
    required this.title,
    this.amount = '0.00',
    this.laborAmount = '0.00',
    this.returnAmount = '0.00',
    this.notes,
    this.customerName,
  });

  final int id;
  final int customerId;
  final String entryDate;
  final String entryType;
  final String title;
  final String amount;
  final String laborAmount;
  final String returnAmount;
  final String? notes;
  final String? customerName;

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as int,
        customerId: json['customer_id'] as int,
        entryDate: jsonDate(json['entry_date']),
        entryType: json['entry_type'] as String,
        title: json['title'] as String,
        amount: jsonMoney(json['amount']),
        laborAmount: jsonMoney(json['labor_amount']),
        returnAmount: jsonMoney(json['return_amount']),
        notes: json['notes'] as String?,
        customerName: json['customer'] is Map
            ? json['customer']['name'] as String?
            : null,
      );
}

class StatementData {
  const StatementData({
    required this.customer,
    required this.entries,
    required this.opening,
    required this.sales,
    required this.collect,
    required this.returns,
    required this.closing,
  });

  final Party customer;
  final List<JournalEntry> entries;
  final String opening;
  final String sales;
  final String collect;
  final String returns;
  final String closing;

  factory StatementData.fromJson(Map<String, dynamic> json) => StatementData(
        customer: Party.fromJson(json['customer'] as Map<String, dynamic>),
        entries: (json['entries'] as List<dynamic>)
            .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        opening: jsonMoney(json['opening']),
        sales: jsonMoney(json['sales']),
        collect: jsonMoney(json['collect']),
        returns: jsonMoney(json['returns']),
        closing: jsonMoney(json['closing']),
      );
}
