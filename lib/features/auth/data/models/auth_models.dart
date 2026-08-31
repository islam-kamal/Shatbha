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

  bool get isVendor => role == 'contractor' || role == 'supplier';

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        company: json['company'] is Map<String, dynamic>
            ? CompanyInfo.fromJson(json['company'] as Map<String, dynamic>)
            : null,
      );

  factory AuthUser.fromVendorJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['type'] as String,
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
