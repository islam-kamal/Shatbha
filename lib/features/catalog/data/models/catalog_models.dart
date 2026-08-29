import '../../../../core/utils/json.dart';

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
        openingBalance: jsonMoney(json['opening_balance']),
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
