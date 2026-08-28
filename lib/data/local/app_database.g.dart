// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedCompaniesTable extends CachedCompanies
    with TableInfo<$CachedCompaniesTable, CachedCompany> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedCompaniesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _packMeta = const VerificationMeta('pack');
  @override
  late final GeneratedColumn<String> pack = GeneratedColumn<String>(
    'pack',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('finishing'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, subtitle, pack];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedCompany> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('pack')) {
      context.handle(
        _packMeta,
        pack.isAcceptableOrUnknown(data['pack']!, _packMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedCompany map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCompany(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      ),
      pack: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack'],
      )!,
    );
  }

  @override
  $CachedCompaniesTable createAlias(String alias) {
    return $CachedCompaniesTable(attachedDatabase, alias);
  }
}

class CachedCompany extends DataClass implements Insertable<CachedCompany> {
  final int id;
  final String name;
  final String? subtitle;
  final String pack;
  const CachedCompany({
    required this.id,
    required this.name,
    this.subtitle,
    required this.pack,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    map['pack'] = Variable<String>(pack);
    return map;
  }

  CachedCompaniesCompanion toCompanion(bool nullToAbsent) {
    return CachedCompaniesCompanion(
      id: Value(id),
      name: Value(name),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      pack: Value(pack),
    );
  }

  factory CachedCompany.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedCompany(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      pack: serializer.fromJson<String>(json['pack']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'subtitle': serializer.toJson<String?>(subtitle),
      'pack': serializer.toJson<String>(pack),
    };
  }

  CachedCompany copyWith({
    int? id,
    String? name,
    Value<String?> subtitle = const Value.absent(),
    String? pack,
  }) => CachedCompany(
    id: id ?? this.id,
    name: name ?? this.name,
    subtitle: subtitle.present ? subtitle.value : this.subtitle,
    pack: pack ?? this.pack,
  );
  CachedCompany copyWithCompanion(CachedCompaniesCompanion data) {
    return CachedCompany(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      pack: data.pack.present ? data.pack.value : this.pack,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedCompany(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('subtitle: $subtitle, ')
          ..write('pack: $pack')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, subtitle, pack);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedCompany &&
          other.id == this.id &&
          other.name == this.name &&
          other.subtitle == this.subtitle &&
          other.pack == this.pack);
}

class CachedCompaniesCompanion extends UpdateCompanion<CachedCompany> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> subtitle;
  final Value<String> pack;
  const CachedCompaniesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.pack = const Value.absent(),
  });
  CachedCompaniesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.subtitle = const Value.absent(),
    this.pack = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CachedCompany> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? subtitle,
    Expression<String>? pack,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (subtitle != null) 'subtitle': subtitle,
      if (pack != null) 'pack': pack,
    });
  }

  CachedCompaniesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? subtitle,
    Value<String>? pack,
  }) {
    return CachedCompaniesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      pack: pack ?? this.pack,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (pack.present) {
      map['pack'] = Variable<String>(pack.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedCompaniesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('subtitle: $subtitle, ')
          ..write('pack: $pack')
          ..write(')'))
        .toString();
  }
}

class $CachedUsersTable extends CachedUsers
    with TableInfo<$CachedUsersTable, CachedUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, companyId, name, email, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $CachedUsersTable createAlias(String alias) {
    return $CachedUsersTable(attachedDatabase, alias);
  }
}

class CachedUser extends DataClass implements Insertable<CachedUser> {
  final int id;
  final int companyId;
  final String name;
  final String email;
  final String role;
  const CachedUser({
    required this.id,
    required this.companyId,
    required this.name,
    required this.email,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    return map;
  }

  CachedUsersCompanion toCompanion(bool nullToAbsent) {
    return CachedUsersCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      email: Value(email),
      role: Value(role),
    );
  }

  factory CachedUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedUser(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
    };
  }

  CachedUser copyWith({
    int? id,
    int? companyId,
    String? name,
    String? email,
    String? role,
  }) => CachedUser(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    email: email ?? this.email,
    role: role ?? this.role,
  );
  CachedUser copyWithCompanion(CachedUsersCompanion data) {
    return CachedUser(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedUser(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, companyId, name, email, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedUser &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.email == this.email &&
          other.role == this.role);
}

class CachedUsersCompanion extends UpdateCompanion<CachedUser> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> name;
  final Value<String> email;
  final Value<String> role;
  const CachedUsersCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
  });
  CachedUsersCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required String name,
    required String email,
    required String role,
  }) : companyId = Value(companyId),
       name = Value(name),
       email = Value(email),
       role = Value(role);
  static Insertable<CachedUser> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? role,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
    });
  }

  CachedUsersCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String>? name,
    Value<String>? email,
    Value<String>? role,
  }) {
    return CachedUsersCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedUsersCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }
}

class $CachedPartiesTable extends CachedParties
    with TableInfo<$CachedPartiesTable, CachedParty> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPartiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingBalanceMeta = const VerificationMeta(
    'openingBalance',
  );
  @override
  late final GeneratedColumn<String> openingBalance = GeneratedColumn<String>(
    'opening_balance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.00'),
  );
  static const VerificationMeta _agreementEstimateMeta = const VerificationMeta(
    'agreementEstimate',
  );
  @override
  late final GeneratedColumn<String> agreementEstimate =
      GeneratedColumn<String>(
        'agreement_estimate',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _supervisionPercentMeta =
      const VerificationMeta('supervisionPercent');
  @override
  late final GeneratedColumn<int> supervisionPercent = GeneratedColumn<int>(
    'supervision_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    type,
    name,
    phone,
    kind,
    openingBalance,
    agreementEstimate,
    supervisionPercent,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parties';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedParty> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
        _openingBalanceMeta,
        openingBalance.isAcceptableOrUnknown(
          data['opening_balance']!,
          _openingBalanceMeta,
        ),
      );
    }
    if (data.containsKey('agreement_estimate')) {
      context.handle(
        _agreementEstimateMeta,
        agreementEstimate.isAcceptableOrUnknown(
          data['agreement_estimate']!,
          _agreementEstimateMeta,
        ),
      );
    }
    if (data.containsKey('supervision_percent')) {
      context.handle(
        _supervisionPercentMeta,
        supervisionPercent.isAcceptableOrUnknown(
          data['supervision_percent']!,
          _supervisionPercentMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedParty map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedParty(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      ),
      openingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opening_balance'],
      )!,
      agreementEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agreement_estimate'],
      ),
      supervisionPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}supervision_percent'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CachedPartiesTable createAlias(String alias) {
    return $CachedPartiesTable(attachedDatabase, alias);
  }
}

class CachedParty extends DataClass implements Insertable<CachedParty> {
  final int id;
  final int companyId;
  final String type;
  final String name;
  final String? phone;
  final String? kind;
  final String openingBalance;
  final String? agreementEstimate;
  final int supervisionPercent;
  final DateTime? updatedAt;
  const CachedParty({
    required this.id,
    required this.companyId,
    required this.type,
    required this.name,
    this.phone,
    this.kind,
    required this.openingBalance,
    this.agreementEstimate,
    required this.supervisionPercent,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || kind != null) {
      map['kind'] = Variable<String>(kind);
    }
    map['opening_balance'] = Variable<String>(openingBalance);
    if (!nullToAbsent || agreementEstimate != null) {
      map['agreement_estimate'] = Variable<String>(agreementEstimate);
    }
    map['supervision_percent'] = Variable<int>(supervisionPercent);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  CachedPartiesCompanion toCompanion(bool nullToAbsent) {
    return CachedPartiesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      type: Value(type),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      kind: kind == null && nullToAbsent ? const Value.absent() : Value(kind),
      openingBalance: Value(openingBalance),
      agreementEstimate: agreementEstimate == null && nullToAbsent
          ? const Value.absent()
          : Value(agreementEstimate),
      supervisionPercent: Value(supervisionPercent),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CachedParty.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedParty(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      kind: serializer.fromJson<String?>(json['kind']),
      openingBalance: serializer.fromJson<String>(json['openingBalance']),
      agreementEstimate: serializer.fromJson<String?>(
        json['agreementEstimate'],
      ),
      supervisionPercent: serializer.fromJson<int>(json['supervisionPercent']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'kind': serializer.toJson<String?>(kind),
      'openingBalance': serializer.toJson<String>(openingBalance),
      'agreementEstimate': serializer.toJson<String?>(agreementEstimate),
      'supervisionPercent': serializer.toJson<int>(supervisionPercent),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  CachedParty copyWith({
    int? id,
    int? companyId,
    String? type,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> kind = const Value.absent(),
    String? openingBalance,
    Value<String?> agreementEstimate = const Value.absent(),
    int? supervisionPercent,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => CachedParty(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    type: type ?? this.type,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    kind: kind.present ? kind.value : this.kind,
    openingBalance: openingBalance ?? this.openingBalance,
    agreementEstimate: agreementEstimate.present
        ? agreementEstimate.value
        : this.agreementEstimate,
    supervisionPercent: supervisionPercent ?? this.supervisionPercent,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CachedParty copyWithCompanion(CachedPartiesCompanion data) {
    return CachedParty(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      kind: data.kind.present ? data.kind.value : this.kind,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      agreementEstimate: data.agreementEstimate.present
          ? data.agreementEstimate.value
          : this.agreementEstimate,
      supervisionPercent: data.supervisionPercent.present
          ? data.supervisionPercent.value
          : this.supervisionPercent,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedParty(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('kind: $kind, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('agreementEstimate: $agreementEstimate, ')
          ..write('supervisionPercent: $supervisionPercent, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    type,
    name,
    phone,
    kind,
    openingBalance,
    agreementEstimate,
    supervisionPercent,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedParty &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.type == this.type &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.kind == this.kind &&
          other.openingBalance == this.openingBalance &&
          other.agreementEstimate == this.agreementEstimate &&
          other.supervisionPercent == this.supervisionPercent &&
          other.updatedAt == this.updatedAt);
}

class CachedPartiesCompanion extends UpdateCompanion<CachedParty> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> type;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> kind;
  final Value<String> openingBalance;
  final Value<String?> agreementEstimate;
  final Value<int> supervisionPercent;
  final Value<DateTime?> updatedAt;
  const CachedPartiesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.kind = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.agreementEstimate = const Value.absent(),
    this.supervisionPercent = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CachedPartiesCompanion.insert({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    required String type,
    required String name,
    this.phone = const Value.absent(),
    this.kind = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.agreementEstimate = const Value.absent(),
    this.supervisionPercent = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : type = Value(type),
       name = Value(name);
  static Insertable<CachedParty> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? kind,
    Expression<String>? openingBalance,
    Expression<String>? agreementEstimate,
    Expression<int>? supervisionPercent,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (kind != null) 'kind': kind,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (agreementEstimate != null) 'agreement_estimate': agreementEstimate,
      if (supervisionPercent != null) 'supervision_percent': supervisionPercent,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CachedPartiesCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String>? type,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? kind,
    Value<String>? openingBalance,
    Value<String?>? agreementEstimate,
    Value<int>? supervisionPercent,
    Value<DateTime?>? updatedAt,
  }) {
    return CachedPartiesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      type: type ?? this.type,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      kind: kind ?? this.kind,
      openingBalance: openingBalance ?? this.openingBalance,
      agreementEstimate: agreementEstimate ?? this.agreementEstimate,
      supervisionPercent: supervisionPercent ?? this.supervisionPercent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<String>(openingBalance.value);
    }
    if (agreementEstimate.present) {
      map['agreement_estimate'] = Variable<String>(agreementEstimate.value);
    }
    if (supervisionPercent.present) {
      map['supervision_percent'] = Variable<int>(supervisionPercent.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPartiesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('kind: $kind, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('agreementEstimate: $agreementEstimate, ')
          ..write('supervisionPercent: $supervisionPercent, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedWorkTypesTable extends CachedWorkTypes
    with TableInfo<$CachedWorkTypesTable, CachedWorkType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedWorkTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedWorkType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedWorkType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedWorkType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CachedWorkTypesTable createAlias(String alias) {
    return $CachedWorkTypesTable(attachedDatabase, alias);
  }
}

class CachedWorkType extends DataClass implements Insertable<CachedWorkType> {
  final int id;
  final String name;
  const CachedWorkType({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CachedWorkTypesCompanion toCompanion(bool nullToAbsent) {
    return CachedWorkTypesCompanion(id: Value(id), name: Value(name));
  }

  factory CachedWorkType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedWorkType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CachedWorkType copyWith({int? id, String? name}) =>
      CachedWorkType(id: id ?? this.id, name: name ?? this.name);
  CachedWorkType copyWithCompanion(CachedWorkTypesCompanion data) {
    return CachedWorkType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedWorkType(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedWorkType &&
          other.id == this.id &&
          other.name == this.name);
}

class CachedWorkTypesCompanion extends UpdateCompanion<CachedWorkType> {
  final Value<int> id;
  final Value<String> name;
  const CachedWorkTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  CachedWorkTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<CachedWorkType> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  CachedWorkTypesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return CachedWorkTypesCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedWorkTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $CachedExpenseCategoriesTable extends CachedExpenseCategories
    with TableInfo<$CachedExpenseCategoriesTable, CachedExpenseCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedExpenseCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedExpenseCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedExpenseCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedExpenseCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CachedExpenseCategoriesTable createAlias(String alias) {
    return $CachedExpenseCategoriesTable(attachedDatabase, alias);
  }
}

class CachedExpenseCategory extends DataClass
    implements Insertable<CachedExpenseCategory> {
  final int id;
  final String name;
  const CachedExpenseCategory({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CachedExpenseCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CachedExpenseCategoriesCompanion(id: Value(id), name: Value(name));
  }

  factory CachedExpenseCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedExpenseCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CachedExpenseCategory copyWith({int? id, String? name}) =>
      CachedExpenseCategory(id: id ?? this.id, name: name ?? this.name);
  CachedExpenseCategory copyWithCompanion(
    CachedExpenseCategoriesCompanion data,
  ) {
    return CachedExpenseCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedExpenseCategory(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedExpenseCategory &&
          other.id == this.id &&
          other.name == this.name);
}

class CachedExpenseCategoriesCompanion
    extends UpdateCompanion<CachedExpenseCategory> {
  final Value<int> id;
  final Value<String> name;
  const CachedExpenseCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  CachedExpenseCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<CachedExpenseCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  CachedExpenseCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
  }) {
    return CachedExpenseCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedExpenseCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $CachedEntriesTable extends CachedEntries
    with TableInfo<$CachedEntriesTable, CachedEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.00'),
  );
  static const VerificationMeta _laborAmountMeta = const VerificationMeta(
    'laborAmount',
  );
  @override
  late final GeneratedColumn<String> laborAmount = GeneratedColumn<String>(
    'labor_amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.00'),
  );
  static const VerificationMeta _returnAmountMeta = const VerificationMeta(
    'returnAmount',
  );
  @override
  late final GeneratedColumn<String> returnAmount = GeneratedColumn<String>(
    'return_amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.00'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    entryDate,
    entryType,
    title,
    amount,
    laborAmount,
    returnAmount,
    notes,
    customerName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('labor_amount')) {
      context.handle(
        _laborAmountMeta,
        laborAmount.isAcceptableOrUnknown(
          data['labor_amount']!,
          _laborAmountMeta,
        ),
      );
    }
    if (data.containsKey('return_amount')) {
      context.handle(
        _returnAmountMeta,
        returnAmount.isAcceptableOrUnknown(
          data['return_amount']!,
          _returnAmountMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_date'],
      )!,
      entryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
      laborAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}labor_amount'],
      )!,
      returnAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}return_amount'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      ),
    );
  }

  @override
  $CachedEntriesTable createAlias(String alias) {
    return $CachedEntriesTable(attachedDatabase, alias);
  }
}

class CachedEntry extends DataClass implements Insertable<CachedEntry> {
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
  const CachedEntry({
    required this.id,
    required this.customerId,
    required this.entryDate,
    required this.entryType,
    required this.title,
    required this.amount,
    required this.laborAmount,
    required this.returnAmount,
    this.notes,
    this.customerName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    map['entry_date'] = Variable<String>(entryDate);
    map['entry_type'] = Variable<String>(entryType);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<String>(amount);
    map['labor_amount'] = Variable<String>(laborAmount);
    map['return_amount'] = Variable<String>(returnAmount);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    return map;
  }

  CachedEntriesCompanion toCompanion(bool nullToAbsent) {
    return CachedEntriesCompanion(
      id: Value(id),
      customerId: Value(customerId),
      entryDate: Value(entryDate),
      entryType: Value(entryType),
      title: Value(title),
      amount: Value(amount),
      laborAmount: Value(laborAmount),
      returnAmount: Value(returnAmount),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
    );
  }

  factory CachedEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedEntry(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      entryType: serializer.fromJson<String>(json['entryType']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<String>(json['amount']),
      laborAmount: serializer.fromJson<String>(json['laborAmount']),
      returnAmount: serializer.fromJson<String>(json['returnAmount']),
      notes: serializer.fromJson<String?>(json['notes']),
      customerName: serializer.fromJson<String?>(json['customerName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int>(customerId),
      'entryDate': serializer.toJson<String>(entryDate),
      'entryType': serializer.toJson<String>(entryType),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<String>(amount),
      'laborAmount': serializer.toJson<String>(laborAmount),
      'returnAmount': serializer.toJson<String>(returnAmount),
      'notes': serializer.toJson<String?>(notes),
      'customerName': serializer.toJson<String?>(customerName),
    };
  }

  CachedEntry copyWith({
    int? id,
    int? customerId,
    String? entryDate,
    String? entryType,
    String? title,
    String? amount,
    String? laborAmount,
    String? returnAmount,
    Value<String?> notes = const Value.absent(),
    Value<String?> customerName = const Value.absent(),
  }) => CachedEntry(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    entryDate: entryDate ?? this.entryDate,
    entryType: entryType ?? this.entryType,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    laborAmount: laborAmount ?? this.laborAmount,
    returnAmount: returnAmount ?? this.returnAmount,
    notes: notes.present ? notes.value : this.notes,
    customerName: customerName.present ? customerName.value : this.customerName,
  );
  CachedEntry copyWithCompanion(CachedEntriesCompanion data) {
    return CachedEntry(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      laborAmount: data.laborAmount.present
          ? data.laborAmount.value
          : this.laborAmount,
      returnAmount: data.returnAmount.present
          ? data.returnAmount.value
          : this.returnAmount,
      notes: data.notes.present ? data.notes.value : this.notes,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedEntry(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('entryDate: $entryDate, ')
          ..write('entryType: $entryType, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('laborAmount: $laborAmount, ')
          ..write('returnAmount: $returnAmount, ')
          ..write('notes: $notes, ')
          ..write('customerName: $customerName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    entryDate,
    entryType,
    title,
    amount,
    laborAmount,
    returnAmount,
    notes,
    customerName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedEntry &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.entryDate == this.entryDate &&
          other.entryType == this.entryType &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.laborAmount == this.laborAmount &&
          other.returnAmount == this.returnAmount &&
          other.notes == this.notes &&
          other.customerName == this.customerName);
}

class CachedEntriesCompanion extends UpdateCompanion<CachedEntry> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<String> entryDate;
  final Value<String> entryType;
  final Value<String> title;
  final Value<String> amount;
  final Value<String> laborAmount;
  final Value<String> returnAmount;
  final Value<String?> notes;
  final Value<String?> customerName;
  const CachedEntriesCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.entryType = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.laborAmount = const Value.absent(),
    this.returnAmount = const Value.absent(),
    this.notes = const Value.absent(),
    this.customerName = const Value.absent(),
  });
  CachedEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    required String entryDate,
    required String entryType,
    required String title,
    this.amount = const Value.absent(),
    this.laborAmount = const Value.absent(),
    this.returnAmount = const Value.absent(),
    this.notes = const Value.absent(),
    this.customerName = const Value.absent(),
  }) : customerId = Value(customerId),
       entryDate = Value(entryDate),
       entryType = Value(entryType),
       title = Value(title);
  static Insertable<CachedEntry> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<String>? entryDate,
    Expression<String>? entryType,
    Expression<String>? title,
    Expression<String>? amount,
    Expression<String>? laborAmount,
    Expression<String>? returnAmount,
    Expression<String>? notes,
    Expression<String>? customerName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (entryDate != null) 'entry_date': entryDate,
      if (entryType != null) 'entry_type': entryType,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (laborAmount != null) 'labor_amount': laborAmount,
      if (returnAmount != null) 'return_amount': returnAmount,
      if (notes != null) 'notes': notes,
      if (customerName != null) 'customer_name': customerName,
    });
  }

  CachedEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? customerId,
    Value<String>? entryDate,
    Value<String>? entryType,
    Value<String>? title,
    Value<String>? amount,
    Value<String>? laborAmount,
    Value<String>? returnAmount,
    Value<String?>? notes,
    Value<String?>? customerName,
  }) {
    return CachedEntriesCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      entryDate: entryDate ?? this.entryDate,
      entryType: entryType ?? this.entryType,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      laborAmount: laborAmount ?? this.laborAmount,
      returnAmount: returnAmount ?? this.returnAmount,
      notes: notes ?? this.notes,
      customerName: customerName ?? this.customerName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (laborAmount.present) {
      map['labor_amount'] = Variable<String>(laborAmount.value);
    }
    if (returnAmount.present) {
      map['return_amount'] = Variable<String>(returnAmount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedEntriesCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('entryDate: $entryDate, ')
          ..write('entryType: $entryType, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('laborAmount: $laborAmount, ')
          ..write('returnAmount: $returnAmount, ')
          ..write('notes: $notes, ')
          ..write('customerName: $customerName')
          ..write(')'))
        .toString();
  }
}

class $CachedExpensesTable extends CachedExpenses
    with TableInfo<$CachedExpensesTable, CachedExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    entryDate,
    title,
    amount,
    notes,
    categoryName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedExpense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedExpense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_date'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      ),
    );
  }

  @override
  $CachedExpensesTable createAlias(String alias) {
    return $CachedExpensesTable(attachedDatabase, alias);
  }
}

class CachedExpense extends DataClass implements Insertable<CachedExpense> {
  final int id;
  final int? categoryId;
  final String entryDate;
  final String title;
  final String amount;
  final String? notes;
  final String? categoryName;
  const CachedExpense({
    required this.id,
    this.categoryId,
    required this.entryDate,
    required this.title,
    required this.amount,
    this.notes,
    this.categoryName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['entry_date'] = Variable<String>(entryDate);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<String>(amount);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || categoryName != null) {
      map['category_name'] = Variable<String>(categoryName);
    }
    return map;
  }

  CachedExpensesCompanion toCompanion(bool nullToAbsent) {
    return CachedExpensesCompanion(
      id: Value(id),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      entryDate: Value(entryDate),
      title: Value(title),
      amount: Value(amount),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      categoryName: categoryName == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryName),
    );
  }

  factory CachedExpense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedExpense(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<String>(json['amount']),
      notes: serializer.fromJson<String?>(json['notes']),
      categoryName: serializer.fromJson<String?>(json['categoryName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int?>(categoryId),
      'entryDate': serializer.toJson<String>(entryDate),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<String>(amount),
      'notes': serializer.toJson<String?>(notes),
      'categoryName': serializer.toJson<String?>(categoryName),
    };
  }

  CachedExpense copyWith({
    int? id,
    Value<int?> categoryId = const Value.absent(),
    String? entryDate,
    String? title,
    String? amount,
    Value<String?> notes = const Value.absent(),
    Value<String?> categoryName = const Value.absent(),
  }) => CachedExpense(
    id: id ?? this.id,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    entryDate: entryDate ?? this.entryDate,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    notes: notes.present ? notes.value : this.notes,
    categoryName: categoryName.present ? categoryName.value : this.categoryName,
  );
  CachedExpense copyWithCompanion(CachedExpensesCompanion data) {
    return CachedExpense(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      notes: data.notes.present ? data.notes.value : this.notes,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedExpense(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('entryDate: $entryDate, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('notes: $notes, ')
          ..write('categoryName: $categoryName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    entryDate,
    title,
    amount,
    notes,
    categoryName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedExpense &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.entryDate == this.entryDate &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.notes == this.notes &&
          other.categoryName == this.categoryName);
}

class CachedExpensesCompanion extends UpdateCompanion<CachedExpense> {
  final Value<int> id;
  final Value<int?> categoryId;
  final Value<String> entryDate;
  final Value<String> title;
  final Value<String> amount;
  final Value<String?> notes;
  final Value<String?> categoryName;
  const CachedExpensesCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.notes = const Value.absent(),
    this.categoryName = const Value.absent(),
  });
  CachedExpensesCompanion.insert({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    required String entryDate,
    required String title,
    required String amount,
    this.notes = const Value.absent(),
    this.categoryName = const Value.absent(),
  }) : entryDate = Value(entryDate),
       title = Value(title),
       amount = Value(amount);
  static Insertable<CachedExpense> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? entryDate,
    Expression<String>? title,
    Expression<String>? amount,
    Expression<String>? notes,
    Expression<String>? categoryName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (entryDate != null) 'entry_date': entryDate,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (notes != null) 'notes': notes,
      if (categoryName != null) 'category_name': categoryName,
    });
  }

  CachedExpensesCompanion copyWith({
    Value<int>? id,
    Value<int?>? categoryId,
    Value<String>? entryDate,
    Value<String>? title,
    Value<String>? amount,
    Value<String?>? notes,
    Value<String?>? categoryName,
  }) {
    return CachedExpensesCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      entryDate: entryDate ?? this.entryDate,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedExpensesCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('entryDate: $entryDate, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('notes: $notes, ')
          ..write('categoryName: $categoryName')
          ..write(')'))
        .toString();
  }
}

class $CachedJobsTable extends CachedJobs
    with TableInfo<$CachedJobsTable, CachedJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<String> qty = GeneratedColumn<String>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<String> unitPrice = GeneratedColumn<String>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<String> total = GeneratedColumn<String>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidMeta = const VerificationMeta('paid');
  @override
  late final GeneratedColumn<String> paid = GeneratedColumn<String>(
    'paid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingMeta = const VerificationMeta(
    'remaining',
  );
  @override
  late final GeneratedColumn<String> remaining = GeneratedColumn<String>(
    'remaining',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contractorNameMeta = const VerificationMeta(
    'contractorName',
  );
  @override
  late final GeneratedColumn<String> contractorName = GeneratedColumn<String>(
    'contractor_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contractorIdMeta = const VerificationMeta(
    'contractorId',
  );
  @override
  late final GeneratedColumn<int> contractorId = GeneratedColumn<int>(
    'contractor_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    qty,
    unitPrice,
    total,
    paid,
    remaining,
    contractorName,
    contractorId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('paid')) {
      context.handle(
        _paidMeta,
        paid.isAcceptableOrUnknown(data['paid']!, _paidMeta),
      );
    } else if (isInserting) {
      context.missing(_paidMeta);
    }
    if (data.containsKey('remaining')) {
      context.handle(
        _remainingMeta,
        remaining.isAcceptableOrUnknown(data['remaining']!, _remainingMeta),
      );
    } else if (isInserting) {
      context.missing(_remainingMeta);
    }
    if (data.containsKey('contractor_name')) {
      context.handle(
        _contractorNameMeta,
        contractorName.isAcceptableOrUnknown(
          data['contractor_name']!,
          _contractorNameMeta,
        ),
      );
    }
    if (data.containsKey('contractor_id')) {
      context.handle(
        _contractorIdMeta,
        contractorId.isAcceptableOrUnknown(
          data['contractor_id']!,
          _contractorIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qty'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_price'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total'],
      )!,
      paid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid'],
      )!,
      remaining: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remaining'],
      )!,
      contractorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contractor_name'],
      ),
      contractorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contractor_id'],
      ),
    );
  }

  @override
  $CachedJobsTable createAlias(String alias) {
    return $CachedJobsTable(attachedDatabase, alias);
  }
}

class CachedJob extends DataClass implements Insertable<CachedJob> {
  final int id;
  final String title;
  final String qty;
  final String unitPrice;
  final String total;
  final String paid;
  final String remaining;
  final String? contractorName;
  final int? contractorId;
  const CachedJob({
    required this.id,
    required this.title,
    required this.qty,
    required this.unitPrice,
    required this.total,
    required this.paid,
    required this.remaining,
    this.contractorName,
    this.contractorId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['qty'] = Variable<String>(qty);
    map['unit_price'] = Variable<String>(unitPrice);
    map['total'] = Variable<String>(total);
    map['paid'] = Variable<String>(paid);
    map['remaining'] = Variable<String>(remaining);
    if (!nullToAbsent || contractorName != null) {
      map['contractor_name'] = Variable<String>(contractorName);
    }
    if (!nullToAbsent || contractorId != null) {
      map['contractor_id'] = Variable<int>(contractorId);
    }
    return map;
  }

  CachedJobsCompanion toCompanion(bool nullToAbsent) {
    return CachedJobsCompanion(
      id: Value(id),
      title: Value(title),
      qty: Value(qty),
      unitPrice: Value(unitPrice),
      total: Value(total),
      paid: Value(paid),
      remaining: Value(remaining),
      contractorName: contractorName == null && nullToAbsent
          ? const Value.absent()
          : Value(contractorName),
      contractorId: contractorId == null && nullToAbsent
          ? const Value.absent()
          : Value(contractorId),
    );
  }

  factory CachedJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedJob(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      qty: serializer.fromJson<String>(json['qty']),
      unitPrice: serializer.fromJson<String>(json['unitPrice']),
      total: serializer.fromJson<String>(json['total']),
      paid: serializer.fromJson<String>(json['paid']),
      remaining: serializer.fromJson<String>(json['remaining']),
      contractorName: serializer.fromJson<String?>(json['contractorName']),
      contractorId: serializer.fromJson<int?>(json['contractorId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'qty': serializer.toJson<String>(qty),
      'unitPrice': serializer.toJson<String>(unitPrice),
      'total': serializer.toJson<String>(total),
      'paid': serializer.toJson<String>(paid),
      'remaining': serializer.toJson<String>(remaining),
      'contractorName': serializer.toJson<String?>(contractorName),
      'contractorId': serializer.toJson<int?>(contractorId),
    };
  }

  CachedJob copyWith({
    int? id,
    String? title,
    String? qty,
    String? unitPrice,
    String? total,
    String? paid,
    String? remaining,
    Value<String?> contractorName = const Value.absent(),
    Value<int?> contractorId = const Value.absent(),
  }) => CachedJob(
    id: id ?? this.id,
    title: title ?? this.title,
    qty: qty ?? this.qty,
    unitPrice: unitPrice ?? this.unitPrice,
    total: total ?? this.total,
    paid: paid ?? this.paid,
    remaining: remaining ?? this.remaining,
    contractorName: contractorName.present
        ? contractorName.value
        : this.contractorName,
    contractorId: contractorId.present ? contractorId.value : this.contractorId,
  );
  CachedJob copyWithCompanion(CachedJobsCompanion data) {
    return CachedJob(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      qty: data.qty.present ? data.qty.value : this.qty,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      total: data.total.present ? data.total.value : this.total,
      paid: data.paid.present ? data.paid.value : this.paid,
      remaining: data.remaining.present ? data.remaining.value : this.remaining,
      contractorName: data.contractorName.present
          ? data.contractorName.value
          : this.contractorName,
      contractorId: data.contractorId.present
          ? data.contractorId.value
          : this.contractorId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedJob(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('qty: $qty, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('total: $total, ')
          ..write('paid: $paid, ')
          ..write('remaining: $remaining, ')
          ..write('contractorName: $contractorName, ')
          ..write('contractorId: $contractorId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    qty,
    unitPrice,
    total,
    paid,
    remaining,
    contractorName,
    contractorId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedJob &&
          other.id == this.id &&
          other.title == this.title &&
          other.qty == this.qty &&
          other.unitPrice == this.unitPrice &&
          other.total == this.total &&
          other.paid == this.paid &&
          other.remaining == this.remaining &&
          other.contractorName == this.contractorName &&
          other.contractorId == this.contractorId);
}

class CachedJobsCompanion extends UpdateCompanion<CachedJob> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> qty;
  final Value<String> unitPrice;
  final Value<String> total;
  final Value<String> paid;
  final Value<String> remaining;
  final Value<String?> contractorName;
  final Value<int?> contractorId;
  const CachedJobsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.qty = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.total = const Value.absent(),
    this.paid = const Value.absent(),
    this.remaining = const Value.absent(),
    this.contractorName = const Value.absent(),
    this.contractorId = const Value.absent(),
  });
  CachedJobsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String qty,
    required String unitPrice,
    required String total,
    required String paid,
    required String remaining,
    this.contractorName = const Value.absent(),
    this.contractorId = const Value.absent(),
  }) : title = Value(title),
       qty = Value(qty),
       unitPrice = Value(unitPrice),
       total = Value(total),
       paid = Value(paid),
       remaining = Value(remaining);
  static Insertable<CachedJob> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? qty,
    Expression<String>? unitPrice,
    Expression<String>? total,
    Expression<String>? paid,
    Expression<String>? remaining,
    Expression<String>? contractorName,
    Expression<int>? contractorId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (qty != null) 'qty': qty,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (total != null) 'total': total,
      if (paid != null) 'paid': paid,
      if (remaining != null) 'remaining': remaining,
      if (contractorName != null) 'contractor_name': contractorName,
      if (contractorId != null) 'contractor_id': contractorId,
    });
  }

  CachedJobsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? qty,
    Value<String>? unitPrice,
    Value<String>? total,
    Value<String>? paid,
    Value<String>? remaining,
    Value<String?>? contractorName,
    Value<int?>? contractorId,
  }) {
    return CachedJobsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
      paid: paid ?? this.paid,
      remaining: remaining ?? this.remaining,
      contractorName: contractorName ?? this.contractorName,
      contractorId: contractorId ?? this.contractorId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (qty.present) {
      map['qty'] = Variable<String>(qty.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<String>(unitPrice.value);
    }
    if (total.present) {
      map['total'] = Variable<String>(total.value);
    }
    if (paid.present) {
      map['paid'] = Variable<String>(paid.value);
    }
    if (remaining.present) {
      map['remaining'] = Variable<String>(remaining.value);
    }
    if (contractorName.present) {
      map['contractor_name'] = Variable<String>(contractorName.value);
    }
    if (contractorId.present) {
      map['contractor_id'] = Variable<int>(contractorId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedJobsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('qty: $qty, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('total: $total, ')
          ..write('paid: $paid, ')
          ..write('remaining: $remaining, ')
          ..write('contractorName: $contractorName, ')
          ..write('contractorId: $contractorId')
          ..write(')'))
        .toString();
  }
}

class $CachedJobPaymentsTable extends CachedJobPayments
    with TableInfo<$CachedJobPaymentsTable, CachedJobPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedJobPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<int> jobId = GeneratedColumn<int>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidOnMeta = const VerificationMeta('paidOn');
  @override
  late final GeneratedColumn<String> paidOn = GeneratedColumn<String>(
    'paid_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, jobId, sequence, amount, paidOn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedJobPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('paid_on')) {
      context.handle(
        _paidOnMeta,
        paidOn.isAcceptableOrUnknown(data['paid_on']!, _paidOnMeta),
      );
    } else if (isInserting) {
      context.missing(_paidOnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedJobPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedJobPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}job_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
      paidOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_on'],
      )!,
    );
  }

  @override
  $CachedJobPaymentsTable createAlias(String alias) {
    return $CachedJobPaymentsTable(attachedDatabase, alias);
  }
}

class CachedJobPayment extends DataClass
    implements Insertable<CachedJobPayment> {
  final int id;
  final int jobId;
  final int sequence;
  final String amount;
  final String paidOn;
  const CachedJobPayment({
    required this.id,
    required this.jobId,
    required this.sequence,
    required this.amount,
    required this.paidOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['job_id'] = Variable<int>(jobId);
    map['sequence'] = Variable<int>(sequence);
    map['amount'] = Variable<String>(amount);
    map['paid_on'] = Variable<String>(paidOn);
    return map;
  }

  CachedJobPaymentsCompanion toCompanion(bool nullToAbsent) {
    return CachedJobPaymentsCompanion(
      id: Value(id),
      jobId: Value(jobId),
      sequence: Value(sequence),
      amount: Value(amount),
      paidOn: Value(paidOn),
    );
  }

  factory CachedJobPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedJobPayment(
      id: serializer.fromJson<int>(json['id']),
      jobId: serializer.fromJson<int>(json['jobId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      amount: serializer.fromJson<String>(json['amount']),
      paidOn: serializer.fromJson<String>(json['paidOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jobId': serializer.toJson<int>(jobId),
      'sequence': serializer.toJson<int>(sequence),
      'amount': serializer.toJson<String>(amount),
      'paidOn': serializer.toJson<String>(paidOn),
    };
  }

  CachedJobPayment copyWith({
    int? id,
    int? jobId,
    int? sequence,
    String? amount,
    String? paidOn,
  }) => CachedJobPayment(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    sequence: sequence ?? this.sequence,
    amount: amount ?? this.amount,
    paidOn: paidOn ?? this.paidOn,
  );
  CachedJobPayment copyWithCompanion(CachedJobPaymentsCompanion data) {
    return CachedJobPayment(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      amount: data.amount.present ? data.amount.value : this.amount,
      paidOn: data.paidOn.present ? data.paidOn.value : this.paidOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedJobPayment(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('sequence: $sequence, ')
          ..write('amount: $amount, ')
          ..write('paidOn: $paidOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, jobId, sequence, amount, paidOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedJobPayment &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.sequence == this.sequence &&
          other.amount == this.amount &&
          other.paidOn == this.paidOn);
}

class CachedJobPaymentsCompanion extends UpdateCompanion<CachedJobPayment> {
  final Value<int> id;
  final Value<int> jobId;
  final Value<int> sequence;
  final Value<String> amount;
  final Value<String> paidOn;
  const CachedJobPaymentsCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.amount = const Value.absent(),
    this.paidOn = const Value.absent(),
  });
  CachedJobPaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int jobId,
    required int sequence,
    required String amount,
    required String paidOn,
  }) : jobId = Value(jobId),
       sequence = Value(sequence),
       amount = Value(amount),
       paidOn = Value(paidOn);
  static Insertable<CachedJobPayment> custom({
    Expression<int>? id,
    Expression<int>? jobId,
    Expression<int>? sequence,
    Expression<String>? amount,
    Expression<String>? paidOn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (sequence != null) 'sequence': sequence,
      if (amount != null) 'amount': amount,
      if (paidOn != null) 'paid_on': paidOn,
    });
  }

  CachedJobPaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? jobId,
    Value<int>? sequence,
    Value<String>? amount,
    Value<String>? paidOn,
  }) {
    return CachedJobPaymentsCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      sequence: sequence ?? this.sequence,
      amount: amount ?? this.amount,
      paidOn: paidOn ?? this.paidOn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<int>(jobId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (paidOn.present) {
      map['paid_on'] = Variable<String>(paidOn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedJobPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('sequence: $sequence, ')
          ..write('amount: $amount, ')
          ..write('paidOn: $paidOn')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    method,
    path,
    payload,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final int id;
  final String method;
  final String path;
  final String payload;
  final String status;
  final DateTime createdAt;
  const SyncOutboxData({
    required this.id,
    required this.method,
    required this.path,
    required this.payload,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['method'] = Variable<String>(method);
    map['path'] = Variable<String>(path);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      method: Value(method),
      path: Value(path),
      payload: Value(payload),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      id: serializer.fromJson<int>(json['id']),
      method: serializer.fromJson<String>(json['method']),
      path: serializer.fromJson<String>(json['path']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'method': serializer.toJson<String>(method),
      'path': serializer.toJson<String>(path),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncOutboxData copyWith({
    int? id,
    String? method,
    String? path,
    String? payload,
    String? status,
    DateTime? createdAt,
  }) => SyncOutboxData(
    id: id ?? this.id,
    method: method ?? this.method,
    path: path ?? this.path,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      method: data.method.present ? data.method.value : this.method,
      path: data.path.present ? data.path.value : this.path,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, method, path, payload, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.id == this.id &&
          other.method == this.method &&
          other.path == this.path &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<int> id;
  final Value<String> method;
  final Value<String> path;
  final Value<String> payload;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.method = const Value.absent(),
    this.path = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.id = const Value.absent(),
    required String method,
    required String path,
    required String payload,
    this.status = const Value.absent(),
    required DateTime createdAt,
  }) : method = Value(method),
       path = Value(path),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<SyncOutboxData> custom({
    Expression<int>? id,
    Expression<String>? method,
    Expression<String>? path,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (method != null) 'method': method,
      if (path != null) 'path': path,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<int>? id,
    Value<String>? method,
    Value<String>? path,
    Value<String>? payload,
    Value<String>? status,
    Value<DateTime>? createdAt,
  }) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      method: method ?? this.method,
      path: path ?? this.path,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedCompaniesTable cachedCompanies = $CachedCompaniesTable(
    this,
  );
  late final $CachedUsersTable cachedUsers = $CachedUsersTable(this);
  late final $CachedPartiesTable cachedParties = $CachedPartiesTable(this);
  late final $CachedWorkTypesTable cachedWorkTypes = $CachedWorkTypesTable(
    this,
  );
  late final $CachedExpenseCategoriesTable cachedExpenseCategories =
      $CachedExpenseCategoriesTable(this);
  late final $CachedEntriesTable cachedEntries = $CachedEntriesTable(this);
  late final $CachedExpensesTable cachedExpenses = $CachedExpensesTable(this);
  late final $CachedJobsTable cachedJobs = $CachedJobsTable(this);
  late final $CachedJobPaymentsTable cachedJobPayments =
      $CachedJobPaymentsTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedCompanies,
    cachedUsers,
    cachedParties,
    cachedWorkTypes,
    cachedExpenseCategories,
    cachedEntries,
    cachedExpenses,
    cachedJobs,
    cachedJobPayments,
    syncOutbox,
  ];
}

typedef $$CachedCompaniesTableCreateCompanionBuilder =
    CachedCompaniesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> subtitle,
      Value<String> pack,
    });
typedef $$CachedCompaniesTableUpdateCompanionBuilder =
    CachedCompaniesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> subtitle,
      Value<String> pack,
    });

class $$CachedCompaniesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedCompaniesTable> {
  $$CachedCompaniesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pack => $composableBuilder(
    column: $table.pack,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedCompaniesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedCompaniesTable> {
  $$CachedCompaniesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pack => $composableBuilder(
    column: $table.pack,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedCompaniesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedCompaniesTable> {
  $$CachedCompaniesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get pack =>
      $composableBuilder(column: $table.pack, builder: (column) => column);
}

class $$CachedCompaniesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedCompaniesTable,
          CachedCompany,
          $$CachedCompaniesTableFilterComposer,
          $$CachedCompaniesTableOrderingComposer,
          $$CachedCompaniesTableAnnotationComposer,
          $$CachedCompaniesTableCreateCompanionBuilder,
          $$CachedCompaniesTableUpdateCompanionBuilder,
          (
            CachedCompany,
            BaseReferences<_$AppDatabase, $CachedCompaniesTable, CachedCompany>,
          ),
          CachedCompany,
          PrefetchHooks Function()
        > {
  $$CachedCompaniesTableTableManager(
    _$AppDatabase db,
    $CachedCompaniesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedCompaniesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedCompaniesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedCompaniesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> subtitle = const Value.absent(),
                Value<String> pack = const Value.absent(),
              }) => CachedCompaniesCompanion(
                id: id,
                name: name,
                subtitle: subtitle,
                pack: pack,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> subtitle = const Value.absent(),
                Value<String> pack = const Value.absent(),
              }) => CachedCompaniesCompanion.insert(
                id: id,
                name: name,
                subtitle: subtitle,
                pack: pack,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedCompaniesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedCompaniesTable,
      CachedCompany,
      $$CachedCompaniesTableFilterComposer,
      $$CachedCompaniesTableOrderingComposer,
      $$CachedCompaniesTableAnnotationComposer,
      $$CachedCompaniesTableCreateCompanionBuilder,
      $$CachedCompaniesTableUpdateCompanionBuilder,
      (
        CachedCompany,
        BaseReferences<_$AppDatabase, $CachedCompaniesTable, CachedCompany>,
      ),
      CachedCompany,
      PrefetchHooks Function()
    >;
typedef $$CachedUsersTableCreateCompanionBuilder =
    CachedUsersCompanion Function({
      Value<int> id,
      required int companyId,
      required String name,
      required String email,
      required String role,
    });
typedef $$CachedUsersTableUpdateCompanionBuilder =
    CachedUsersCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String> name,
      Value<String> email,
      Value<String> role,
    });

class $$CachedUsersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedUsersTable> {
  $$CachedUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedUsersTable> {
  $$CachedUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedUsersTable> {
  $$CachedUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);
}

class $$CachedUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedUsersTable,
          CachedUser,
          $$CachedUsersTableFilterComposer,
          $$CachedUsersTableOrderingComposer,
          $$CachedUsersTableAnnotationComposer,
          $$CachedUsersTableCreateCompanionBuilder,
          $$CachedUsersTableUpdateCompanionBuilder,
          (
            CachedUser,
            BaseReferences<_$AppDatabase, $CachedUsersTable, CachedUser>,
          ),
          CachedUser,
          PrefetchHooks Function()
        > {
  $$CachedUsersTableTableManager(_$AppDatabase db, $CachedUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> role = const Value.absent(),
              }) => CachedUsersCompanion(
                id: id,
                companyId: companyId,
                name: name,
                email: email,
                role: role,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required String name,
                required String email,
                required String role,
              }) => CachedUsersCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                email: email,
                role: role,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedUsersTable,
      CachedUser,
      $$CachedUsersTableFilterComposer,
      $$CachedUsersTableOrderingComposer,
      $$CachedUsersTableAnnotationComposer,
      $$CachedUsersTableCreateCompanionBuilder,
      $$CachedUsersTableUpdateCompanionBuilder,
      (
        CachedUser,
        BaseReferences<_$AppDatabase, $CachedUsersTable, CachedUser>,
      ),
      CachedUser,
      PrefetchHooks Function()
    >;
typedef $$CachedPartiesTableCreateCompanionBuilder =
    CachedPartiesCompanion Function({
      Value<int> id,
      Value<int> companyId,
      required String type,
      required String name,
      Value<String?> phone,
      Value<String?> kind,
      Value<String> openingBalance,
      Value<String?> agreementEstimate,
      Value<int> supervisionPercent,
      Value<DateTime?> updatedAt,
    });
typedef $$CachedPartiesTableUpdateCompanionBuilder =
    CachedPartiesCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String> type,
      Value<String> name,
      Value<String?> phone,
      Value<String?> kind,
      Value<String> openingBalance,
      Value<String?> agreementEstimate,
      Value<int> supervisionPercent,
      Value<DateTime?> updatedAt,
    });

class $$CachedPartiesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedPartiesTable> {
  $$CachedPartiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agreementEstimate => $composableBuilder(
    column: $table.agreementEstimate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supervisionPercent => $composableBuilder(
    column: $table.supervisionPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedPartiesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedPartiesTable> {
  $$CachedPartiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agreementEstimate => $composableBuilder(
    column: $table.agreementEstimate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supervisionPercent => $composableBuilder(
    column: $table.supervisionPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedPartiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedPartiesTable> {
  $$CachedPartiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get agreementEstimate => $composableBuilder(
    column: $table.agreementEstimate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get supervisionPercent => $composableBuilder(
    column: $table.supervisionPercent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedPartiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedPartiesTable,
          CachedParty,
          $$CachedPartiesTableFilterComposer,
          $$CachedPartiesTableOrderingComposer,
          $$CachedPartiesTableAnnotationComposer,
          $$CachedPartiesTableCreateCompanionBuilder,
          $$CachedPartiesTableUpdateCompanionBuilder,
          (
            CachedParty,
            BaseReferences<_$AppDatabase, $CachedPartiesTable, CachedParty>,
          ),
          CachedParty,
          PrefetchHooks Function()
        > {
  $$CachedPartiesTableTableManager(_$AppDatabase db, $CachedPartiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPartiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedPartiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedPartiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> kind = const Value.absent(),
                Value<String> openingBalance = const Value.absent(),
                Value<String?> agreementEstimate = const Value.absent(),
                Value<int> supervisionPercent = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => CachedPartiesCompanion(
                id: id,
                companyId: companyId,
                type: type,
                name: name,
                phone: phone,
                kind: kind,
                openingBalance: openingBalance,
                agreementEstimate: agreementEstimate,
                supervisionPercent: supervisionPercent,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                required String type,
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> kind = const Value.absent(),
                Value<String> openingBalance = const Value.absent(),
                Value<String?> agreementEstimate = const Value.absent(),
                Value<int> supervisionPercent = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => CachedPartiesCompanion.insert(
                id: id,
                companyId: companyId,
                type: type,
                name: name,
                phone: phone,
                kind: kind,
                openingBalance: openingBalance,
                agreementEstimate: agreementEstimate,
                supervisionPercent: supervisionPercent,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedPartiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedPartiesTable,
      CachedParty,
      $$CachedPartiesTableFilterComposer,
      $$CachedPartiesTableOrderingComposer,
      $$CachedPartiesTableAnnotationComposer,
      $$CachedPartiesTableCreateCompanionBuilder,
      $$CachedPartiesTableUpdateCompanionBuilder,
      (
        CachedParty,
        BaseReferences<_$AppDatabase, $CachedPartiesTable, CachedParty>,
      ),
      CachedParty,
      PrefetchHooks Function()
    >;
typedef $$CachedWorkTypesTableCreateCompanionBuilder =
    CachedWorkTypesCompanion Function({Value<int> id, required String name});
typedef $$CachedWorkTypesTableUpdateCompanionBuilder =
    CachedWorkTypesCompanion Function({Value<int> id, Value<String> name});

class $$CachedWorkTypesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedWorkTypesTable> {
  $$CachedWorkTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedWorkTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedWorkTypesTable> {
  $$CachedWorkTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedWorkTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedWorkTypesTable> {
  $$CachedWorkTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$CachedWorkTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedWorkTypesTable,
          CachedWorkType,
          $$CachedWorkTypesTableFilterComposer,
          $$CachedWorkTypesTableOrderingComposer,
          $$CachedWorkTypesTableAnnotationComposer,
          $$CachedWorkTypesTableCreateCompanionBuilder,
          $$CachedWorkTypesTableUpdateCompanionBuilder,
          (
            CachedWorkType,
            BaseReferences<
              _$AppDatabase,
              $CachedWorkTypesTable,
              CachedWorkType
            >,
          ),
          CachedWorkType,
          PrefetchHooks Function()
        > {
  $$CachedWorkTypesTableTableManager(
    _$AppDatabase db,
    $CachedWorkTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedWorkTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedWorkTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedWorkTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => CachedWorkTypesCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  CachedWorkTypesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedWorkTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedWorkTypesTable,
      CachedWorkType,
      $$CachedWorkTypesTableFilterComposer,
      $$CachedWorkTypesTableOrderingComposer,
      $$CachedWorkTypesTableAnnotationComposer,
      $$CachedWorkTypesTableCreateCompanionBuilder,
      $$CachedWorkTypesTableUpdateCompanionBuilder,
      (
        CachedWorkType,
        BaseReferences<_$AppDatabase, $CachedWorkTypesTable, CachedWorkType>,
      ),
      CachedWorkType,
      PrefetchHooks Function()
    >;
typedef $$CachedExpenseCategoriesTableCreateCompanionBuilder =
    CachedExpenseCategoriesCompanion Function({
      Value<int> id,
      required String name,
    });
typedef $$CachedExpenseCategoriesTableUpdateCompanionBuilder =
    CachedExpenseCategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
    });

class $$CachedExpenseCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedExpenseCategoriesTable> {
  $$CachedExpenseCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedExpenseCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedExpenseCategoriesTable> {
  $$CachedExpenseCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedExpenseCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedExpenseCategoriesTable> {
  $$CachedExpenseCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$CachedExpenseCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedExpenseCategoriesTable,
          CachedExpenseCategory,
          $$CachedExpenseCategoriesTableFilterComposer,
          $$CachedExpenseCategoriesTableOrderingComposer,
          $$CachedExpenseCategoriesTableAnnotationComposer,
          $$CachedExpenseCategoriesTableCreateCompanionBuilder,
          $$CachedExpenseCategoriesTableUpdateCompanionBuilder,
          (
            CachedExpenseCategory,
            BaseReferences<
              _$AppDatabase,
              $CachedExpenseCategoriesTable,
              CachedExpenseCategory
            >,
          ),
          CachedExpenseCategory,
          PrefetchHooks Function()
        > {
  $$CachedExpenseCategoriesTableTableManager(
    _$AppDatabase db,
    $CachedExpenseCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedExpenseCategoriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CachedExpenseCategoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedExpenseCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => CachedExpenseCategoriesCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  CachedExpenseCategoriesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedExpenseCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedExpenseCategoriesTable,
      CachedExpenseCategory,
      $$CachedExpenseCategoriesTableFilterComposer,
      $$CachedExpenseCategoriesTableOrderingComposer,
      $$CachedExpenseCategoriesTableAnnotationComposer,
      $$CachedExpenseCategoriesTableCreateCompanionBuilder,
      $$CachedExpenseCategoriesTableUpdateCompanionBuilder,
      (
        CachedExpenseCategory,
        BaseReferences<
          _$AppDatabase,
          $CachedExpenseCategoriesTable,
          CachedExpenseCategory
        >,
      ),
      CachedExpenseCategory,
      PrefetchHooks Function()
    >;
typedef $$CachedEntriesTableCreateCompanionBuilder =
    CachedEntriesCompanion Function({
      Value<int> id,
      required int customerId,
      required String entryDate,
      required String entryType,
      required String title,
      Value<String> amount,
      Value<String> laborAmount,
      Value<String> returnAmount,
      Value<String?> notes,
      Value<String?> customerName,
    });
typedef $$CachedEntriesTableUpdateCompanionBuilder =
    CachedEntriesCompanion Function({
      Value<int> id,
      Value<int> customerId,
      Value<String> entryDate,
      Value<String> entryType,
      Value<String> title,
      Value<String> amount,
      Value<String> laborAmount,
      Value<String> returnAmount,
      Value<String?> notes,
      Value<String?> customerName,
    });

class $$CachedEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedEntriesTable> {
  $$CachedEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get laborAmount => $composableBuilder(
    column: $table.laborAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get returnAmount => $composableBuilder(
    column: $table.returnAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedEntriesTable> {
  $$CachedEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get laborAmount => $composableBuilder(
    column: $table.laborAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get returnAmount => $composableBuilder(
    column: $table.returnAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedEntriesTable> {
  $$CachedEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get laborAmount => $composableBuilder(
    column: $table.laborAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get returnAmount => $composableBuilder(
    column: $table.returnAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );
}

class $$CachedEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedEntriesTable,
          CachedEntry,
          $$CachedEntriesTableFilterComposer,
          $$CachedEntriesTableOrderingComposer,
          $$CachedEntriesTableAnnotationComposer,
          $$CachedEntriesTableCreateCompanionBuilder,
          $$CachedEntriesTableUpdateCompanionBuilder,
          (
            CachedEntry,
            BaseReferences<_$AppDatabase, $CachedEntriesTable, CachedEntry>,
          ),
          CachedEntry,
          PrefetchHooks Function()
        > {
  $$CachedEntriesTableTableManager(_$AppDatabase db, $CachedEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<String> entryDate = const Value.absent(),
                Value<String> entryType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<String> laborAmount = const Value.absent(),
                Value<String> returnAmount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
              }) => CachedEntriesCompanion(
                id: id,
                customerId: customerId,
                entryDate: entryDate,
                entryType: entryType,
                title: title,
                amount: amount,
                laborAmount: laborAmount,
                returnAmount: returnAmount,
                notes: notes,
                customerName: customerName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int customerId,
                required String entryDate,
                required String entryType,
                required String title,
                Value<String> amount = const Value.absent(),
                Value<String> laborAmount = const Value.absent(),
                Value<String> returnAmount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
              }) => CachedEntriesCompanion.insert(
                id: id,
                customerId: customerId,
                entryDate: entryDate,
                entryType: entryType,
                title: title,
                amount: amount,
                laborAmount: laborAmount,
                returnAmount: returnAmount,
                notes: notes,
                customerName: customerName,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedEntriesTable,
      CachedEntry,
      $$CachedEntriesTableFilterComposer,
      $$CachedEntriesTableOrderingComposer,
      $$CachedEntriesTableAnnotationComposer,
      $$CachedEntriesTableCreateCompanionBuilder,
      $$CachedEntriesTableUpdateCompanionBuilder,
      (
        CachedEntry,
        BaseReferences<_$AppDatabase, $CachedEntriesTable, CachedEntry>,
      ),
      CachedEntry,
      PrefetchHooks Function()
    >;
typedef $$CachedExpensesTableCreateCompanionBuilder =
    CachedExpensesCompanion Function({
      Value<int> id,
      Value<int?> categoryId,
      required String entryDate,
      required String title,
      required String amount,
      Value<String?> notes,
      Value<String?> categoryName,
    });
typedef $$CachedExpensesTableUpdateCompanionBuilder =
    CachedExpensesCompanion Function({
      Value<int> id,
      Value<int?> categoryId,
      Value<String> entryDate,
      Value<String> title,
      Value<String> amount,
      Value<String?> notes,
      Value<String?> categoryName,
    });

class $$CachedExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedExpensesTable> {
  $$CachedExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedExpensesTable> {
  $$CachedExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedExpensesTable> {
  $$CachedExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );
}

class $$CachedExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedExpensesTable,
          CachedExpense,
          $$CachedExpensesTableFilterComposer,
          $$CachedExpensesTableOrderingComposer,
          $$CachedExpensesTableAnnotationComposer,
          $$CachedExpensesTableCreateCompanionBuilder,
          $$CachedExpensesTableUpdateCompanionBuilder,
          (
            CachedExpense,
            BaseReferences<_$AppDatabase, $CachedExpensesTable, CachedExpense>,
          ),
          CachedExpense,
          PrefetchHooks Function()
        > {
  $$CachedExpensesTableTableManager(
    _$AppDatabase db,
    $CachedExpensesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String> entryDate = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
              }) => CachedExpensesCompanion(
                id: id,
                categoryId: categoryId,
                entryDate: entryDate,
                title: title,
                amount: amount,
                notes: notes,
                categoryName: categoryName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                required String entryDate,
                required String title,
                required String amount,
                Value<String?> notes = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
              }) => CachedExpensesCompanion.insert(
                id: id,
                categoryId: categoryId,
                entryDate: entryDate,
                title: title,
                amount: amount,
                notes: notes,
                categoryName: categoryName,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedExpensesTable,
      CachedExpense,
      $$CachedExpensesTableFilterComposer,
      $$CachedExpensesTableOrderingComposer,
      $$CachedExpensesTableAnnotationComposer,
      $$CachedExpensesTableCreateCompanionBuilder,
      $$CachedExpensesTableUpdateCompanionBuilder,
      (
        CachedExpense,
        BaseReferences<_$AppDatabase, $CachedExpensesTable, CachedExpense>,
      ),
      CachedExpense,
      PrefetchHooks Function()
    >;
typedef $$CachedJobsTableCreateCompanionBuilder =
    CachedJobsCompanion Function({
      Value<int> id,
      required String title,
      required String qty,
      required String unitPrice,
      required String total,
      required String paid,
      required String remaining,
      Value<String?> contractorName,
      Value<int?> contractorId,
    });
typedef $$CachedJobsTableUpdateCompanionBuilder =
    CachedJobsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> qty,
      Value<String> unitPrice,
      Value<String> total,
      Value<String> paid,
      Value<String> remaining,
      Value<String?> contractorName,
      Value<int?> contractorId,
    });

class $$CachedJobsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedJobsTable> {
  $$CachedJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paid => $composableBuilder(
    column: $table.paid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contractorName => $composableBuilder(
    column: $table.contractorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contractorId => $composableBuilder(
    column: $table.contractorId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedJobsTable> {
  $$CachedJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paid => $composableBuilder(
    column: $table.paid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contractorName => $composableBuilder(
    column: $table.contractorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contractorId => $composableBuilder(
    column: $table.contractorId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedJobsTable> {
  $$CachedJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<String> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get paid =>
      $composableBuilder(column: $table.paid, builder: (column) => column);

  GeneratedColumn<String> get remaining =>
      $composableBuilder(column: $table.remaining, builder: (column) => column);

  GeneratedColumn<String> get contractorName => $composableBuilder(
    column: $table.contractorName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contractorId => $composableBuilder(
    column: $table.contractorId,
    builder: (column) => column,
  );
}

class $$CachedJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedJobsTable,
          CachedJob,
          $$CachedJobsTableFilterComposer,
          $$CachedJobsTableOrderingComposer,
          $$CachedJobsTableAnnotationComposer,
          $$CachedJobsTableCreateCompanionBuilder,
          $$CachedJobsTableUpdateCompanionBuilder,
          (
            CachedJob,
            BaseReferences<_$AppDatabase, $CachedJobsTable, CachedJob>,
          ),
          CachedJob,
          PrefetchHooks Function()
        > {
  $$CachedJobsTableTableManager(_$AppDatabase db, $CachedJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> qty = const Value.absent(),
                Value<String> unitPrice = const Value.absent(),
                Value<String> total = const Value.absent(),
                Value<String> paid = const Value.absent(),
                Value<String> remaining = const Value.absent(),
                Value<String?> contractorName = const Value.absent(),
                Value<int?> contractorId = const Value.absent(),
              }) => CachedJobsCompanion(
                id: id,
                title: title,
                qty: qty,
                unitPrice: unitPrice,
                total: total,
                paid: paid,
                remaining: remaining,
                contractorName: contractorName,
                contractorId: contractorId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String qty,
                required String unitPrice,
                required String total,
                required String paid,
                required String remaining,
                Value<String?> contractorName = const Value.absent(),
                Value<int?> contractorId = const Value.absent(),
              }) => CachedJobsCompanion.insert(
                id: id,
                title: title,
                qty: qty,
                unitPrice: unitPrice,
                total: total,
                paid: paid,
                remaining: remaining,
                contractorName: contractorName,
                contractorId: contractorId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedJobsTable,
      CachedJob,
      $$CachedJobsTableFilterComposer,
      $$CachedJobsTableOrderingComposer,
      $$CachedJobsTableAnnotationComposer,
      $$CachedJobsTableCreateCompanionBuilder,
      $$CachedJobsTableUpdateCompanionBuilder,
      (CachedJob, BaseReferences<_$AppDatabase, $CachedJobsTable, CachedJob>),
      CachedJob,
      PrefetchHooks Function()
    >;
typedef $$CachedJobPaymentsTableCreateCompanionBuilder =
    CachedJobPaymentsCompanion Function({
      Value<int> id,
      required int jobId,
      required int sequence,
      required String amount,
      required String paidOn,
    });
typedef $$CachedJobPaymentsTableUpdateCompanionBuilder =
    CachedJobPaymentsCompanion Function({
      Value<int> id,
      Value<int> jobId,
      Value<int> sequence,
      Value<String> amount,
      Value<String> paidOn,
    });

class $$CachedJobPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedJobPaymentsTable> {
  $$CachedJobPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paidOn => $composableBuilder(
    column: $table.paidOn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedJobPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedJobPaymentsTable> {
  $$CachedJobPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paidOn => $composableBuilder(
    column: $table.paidOn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedJobPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedJobPaymentsTable> {
  $$CachedJobPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jobId =>
      $composableBuilder(column: $table.jobId, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paidOn =>
      $composableBuilder(column: $table.paidOn, builder: (column) => column);
}

class $$CachedJobPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedJobPaymentsTable,
          CachedJobPayment,
          $$CachedJobPaymentsTableFilterComposer,
          $$CachedJobPaymentsTableOrderingComposer,
          $$CachedJobPaymentsTableAnnotationComposer,
          $$CachedJobPaymentsTableCreateCompanionBuilder,
          $$CachedJobPaymentsTableUpdateCompanionBuilder,
          (
            CachedJobPayment,
            BaseReferences<
              _$AppDatabase,
              $CachedJobPaymentsTable,
              CachedJobPayment
            >,
          ),
          CachedJobPayment,
          PrefetchHooks Function()
        > {
  $$CachedJobPaymentsTableTableManager(
    _$AppDatabase db,
    $CachedJobPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedJobPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedJobPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedJobPaymentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jobId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<String> paidOn = const Value.absent(),
              }) => CachedJobPaymentsCompanion(
                id: id,
                jobId: jobId,
                sequence: sequence,
                amount: amount,
                paidOn: paidOn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jobId,
                required int sequence,
                required String amount,
                required String paidOn,
              }) => CachedJobPaymentsCompanion.insert(
                id: id,
                jobId: jobId,
                sequence: sequence,
                amount: amount,
                paidOn: paidOn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedJobPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedJobPaymentsTable,
      CachedJobPayment,
      $$CachedJobPaymentsTableFilterComposer,
      $$CachedJobPaymentsTableOrderingComposer,
      $$CachedJobPaymentsTableAnnotationComposer,
      $$CachedJobPaymentsTableCreateCompanionBuilder,
      $$CachedJobPaymentsTableUpdateCompanionBuilder,
      (
        CachedJobPayment,
        BaseReferences<
          _$AppDatabase,
          $CachedJobPaymentsTable,
          CachedJobPayment
        >,
      ),
      CachedJobPayment,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<int> id,
      required String method,
      required String path,
      required String payload,
      Value<String> status,
      required DateTime createdAt,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<int> id,
      Value<String> method,
      Value<String> path,
      Value<String> payload,
      Value<String> status,
      Value<DateTime> createdAt,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncOutboxCompanion(
                id: id,
                method: method,
                path: path,
                payload: payload,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String method,
                required String path,
                required String payload,
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
              }) => SyncOutboxCompanion.insert(
                id: id,
                method: method,
                path: path,
                payload: payload,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedCompaniesTableTableManager get cachedCompanies =>
      $$CachedCompaniesTableTableManager(_db, _db.cachedCompanies);
  $$CachedUsersTableTableManager get cachedUsers =>
      $$CachedUsersTableTableManager(_db, _db.cachedUsers);
  $$CachedPartiesTableTableManager get cachedParties =>
      $$CachedPartiesTableTableManager(_db, _db.cachedParties);
  $$CachedWorkTypesTableTableManager get cachedWorkTypes =>
      $$CachedWorkTypesTableTableManager(_db, _db.cachedWorkTypes);
  $$CachedExpenseCategoriesTableTableManager get cachedExpenseCategories =>
      $$CachedExpenseCategoriesTableTableManager(
        _db,
        _db.cachedExpenseCategories,
      );
  $$CachedEntriesTableTableManager get cachedEntries =>
      $$CachedEntriesTableTableManager(_db, _db.cachedEntries);
  $$CachedExpensesTableTableManager get cachedExpenses =>
      $$CachedExpensesTableTableManager(_db, _db.cachedExpenses);
  $$CachedJobsTableTableManager get cachedJobs =>
      $$CachedJobsTableTableManager(_db, _db.cachedJobs);
  $$CachedJobPaymentsTableTableManager get cachedJobPayments =>
      $$CachedJobPaymentsTableTableManager(_db, _db.cachedJobPayments);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
}
