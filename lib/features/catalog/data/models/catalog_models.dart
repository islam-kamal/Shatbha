import '../../../../core/utils/json.dart';

class Party {
  const Party({
    required this.id,
    required this.type,
    required this.name,
    this.phone,
    this.email,
    this.kind,
    this.openingBalance = '0.00',
    this.agreementEstimate,
    this.supervisionPercent = 0,
    this.hasLogin = false,
    this.temporaryPassword,
    this.credentialsEmailed,
  });

  final int id;
  final String type;
  final String name;
  final String? phone;
  final String? email;
  final String? kind;
  final String openingBalance;
  final String? agreementEstimate;
  final int supervisionPercent;
  final bool hasLogin;
  final String? temporaryPassword;
  final bool? credentialsEmailed;

  bool get isSupervision => kind == 'supervision';

  factory Party.fromJson(Map<String, dynamic> json) {
    final account = json['client_account'];
    final email = json['email'] as String? ??
        json['login_email'] as String? ??
        (account is Map ? account['email'] as String? : null);
    return Party(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: email,
      kind: json['kind'] as String?,
      openingBalance: jsonMoney(json['opening_balance']),
      agreementEstimate: json['agreement_estimate']?.toString(),
      supervisionPercent: json['supervision_percent'] as int? ?? 0,
      hasLogin: json['has_login'] as bool? ?? email != null,
      temporaryPassword: json['temporary_password'] as String?,
      credentialsEmailed: json['credentials_emailed'] as bool?,
    );
  }
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
