import '../../../../core/utils/json.dart';

class CustomerReportRow {
  const CustomerReportRow({
    required this.id,
    required this.name,
    required this.opening,
    required this.sales,
    required this.collect,
    required this.closing,
  });

  final int id;
  final String name;
  final String opening;
  final String sales;
  final String collect;
  final String closing;

  factory CustomerReportRow.fromJson(Map<String, dynamic> json) =>
      CustomerReportRow(
        id: json['id'] as int,
        name: json['name'] as String,
        opening: jsonMoney(json['opening']),
        sales: jsonMoney(json['sales']),
        collect: jsonMoney(json['collect']),
        closing: jsonMoney(json['closing']),
      );
}

class ContractorReportRow {
  const ContractorReportRow({
    required this.id,
    required this.name,
    required this.remaining,
  });

  final int id;
  final String name;
  final String remaining;

  factory ContractorReportRow.fromJson(Map<String, dynamic> json) =>
      ContractorReportRow(
        id: json['id'] as int,
        name: json['name'] as String,
        remaining: jsonMoney(json['remaining']),
      );
}

class PnLLine {
  const PnLLine({required this.label, required this.amount, required this.kind});
  final String label;
  final String amount;
  final String kind;

  factory PnLLine.fromJson(Map<String, dynamic> json) => PnLLine(
        label: json['label'] as String,
        amount: jsonMoney(json['amount']),
        kind: json['kind'] as String,
      );
}

class IncomeStatement {
  const IncomeStatement({
    required this.supervisionFees,
    required this.officeExpenses,
    required this.net,
    required this.lines,
  });

  final String supervisionFees;
  final String officeExpenses;
  final String net;
  final List<PnLLine> lines;

  factory IncomeStatement.fromJson(Map<String, dynamic> json) =>
      IncomeStatement(
        supervisionFees: jsonMoney(json['supervision_fees']),
        officeExpenses: jsonMoney(json['office_expenses']),
        net: jsonMoney(json['net']),
        lines: (json['lines'] as List<dynamic>? ?? [])
            .map((e) => PnLLine.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
