class CompanyInfo {
  const CompanyInfo({
    required this.id,
    required this.name,
    this.subtitle,
    this.pack = 'finishing',
  });

  final int id;
  final String name;
  final String? subtitle;
  final String pack;

  factory CompanyInfo.fromJson(Map<String, dynamic> json) => CompanyInfo(
        id: json['id'] as int,
        name: json['name'] as String,
        subtitle: json['subtitle'] as String?,
        pack: json['pack'] as String? ?? 'finishing',
      );

  CompanyInfo copyWith({
    String? name,
    String? subtitle,
    String? pack,
  }) {
    return CompanyInfo(
      id: id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      pack: pack ?? this.pack,
    );
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.company,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final CompanyInfo? company;

  bool get isAdmin => role == 'admin';

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        company: json['company'] is Map<String, dynamic>
            ? CompanyInfo.fromJson(json['company'] as Map<String, dynamic>)
            : null,
      );

  AuthUser copyWith({CompanyInfo? company}) {
    return AuthUser(
      id: id,
      name: name,
      email: email,
      role: role,
      company: company ?? this.company,
    );
  }
}

class Party {
  const Party({
    required this.id,
    required this.type,
    required this.name,
    this.phone,
    this.kind,
    this.openingBalance = '0.00',
    this.agreementEstimate,
    this.supervisionPercent = 0,
  });

  final int id;
  final String type;
  final String name;
  final String? phone;
  final String? kind;
  final String openingBalance;
  final String? agreementEstimate;
  final int supervisionPercent;

  bool get isSupervision => kind == 'supervision';

  factory Party.fromJson(Map<String, dynamic> json) => Party(
        id: json['id'] as int,
        type: json['type'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String?,
        kind: json['kind'] as String?,
        openingBalance: _money(json['opening_balance']),
        agreementEstimate: json['agreement_estimate']?.toString(),
        supervisionPercent: json['supervision_percent'] as int? ?? 0,
      );
}

class NamedItem {
  const NamedItem({required this.id, required this.name});
  final int id;
  final String name;

  factory NamedItem.fromJson(Map<String, dynamic> json) => NamedItem(
        id: json['id'] as int,
        name: json['name'] as String,
      );
}

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
        entryDate: _date(json['entry_date']),
        entryType: json['entry_type'] as String,
        title: json['title'] as String,
        amount: _money(json['amount']),
        laborAmount: _money(json['labor_amount']),
        returnAmount: _money(json['return_amount']),
        notes: json['notes'] as String?,
        customerName: json['customer'] is Map
            ? json['customer']['name'] as String?
            : null,
      );
}

class ExpenseItem {
  const ExpenseItem({
    required this.id,
    required this.entryDate,
    required this.title,
    required this.amount,
    this.categoryId,
    this.categoryName,
    this.notes,
  });

  final int id;
  final String entryDate;
  final String title;
  final String amount;
  final int? categoryId;
  final String? categoryName;
  final String? notes;

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
        id: json['id'] as int,
        entryDate: _date(json['entry_date']),
        title: json['title'] as String,
        amount: _money(json['amount']),
        categoryId: json['category_id'] as int?,
        categoryName: json['category'] is Map
            ? json['category']['name'] as String?
            : null,
        notes: json['notes'] as String?,
      );
}

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
        amount: _money(json['amount']),
        paidOn: _date(json['paid_on']),
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
        qty: _money(json['qty']),
        unitPrice: _money(json['unit_price']),
        total: _money(json['total']),
        paid: _money(json['paid']),
        remaining: _money(json['remaining']),
        contractor: json['contractor'] is Map<String, dynamic>
            ? Party.fromJson(json['contractor'] as Map<String, dynamic>)
            : null,
        payments: (json['payments'] as List<dynamic>? ?? [])
            .map((e) => JobPayment.fromJson(e as Map<String, dynamic>))
            .toList(),
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
        opening: _money(json['opening']),
        sales: _money(json['sales']),
        collect: _money(json['collect']),
        returns: _money(json['returns']),
        closing: _money(json['closing']),
      );
}

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
        opening: _money(json['opening']),
        sales: _money(json['sales']),
        collect: _money(json['collect']),
        closing: _money(json['closing']),
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
        remaining: _money(json['remaining']),
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
        supervisionFees: _money(json['supervision_fees']),
        officeExpenses: _money(json['office_expenses']),
        net: _money(json['net']),
        lines: (json['lines'] as List<dynamic>? ?? [])
            .map((e) => PnLLine.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PnLLine {
  const PnLLine({required this.label, required this.amount, required this.kind});
  final String label;
  final String amount;
  final String kind;

  factory PnLLine.fromJson(Map<String, dynamic> json) => PnLLine(
        label: json['label'] as String,
        amount: _money(json['amount']),
        kind: json['kind'] as String,
      );
}

class CategoryTotal {
  const CategoryTotal({required this.category, required this.total});
  final String category;
  final String total;

  factory CategoryTotal.fromJson(Map<String, dynamic> json) => CategoryTotal(
        category: json['category'] as String,
        total: _money(json['total']),
      );
}

String _money(dynamic value) {
  if (value == null) return '0.00';
  if (value is num) return value.toStringAsFixed(2);
  return value.toString();
}

String _date(dynamic value) {
  if (value == null) return '';
  final raw = value.toString();
  return raw.length >= 10 ? raw.substring(0, 10) : raw;
}
