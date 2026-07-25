// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cognote_database.dart';

// ignore_for_file: type=lint
class $PrincipalsTable extends Principals
    with TableInfo<$PrincipalsTable, Principal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrincipalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _homeRegionMeta = const VerificationMeta(
    'homeRegion',
  );
  @override
  late final GeneratedColumn<String> homeRegion = GeneratedColumn<String>(
    'home_region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataResidencyMeta = const VerificationMeta(
    'dataResidency',
  );
  @override
  late final GeneratedColumn<String> dataResidency = GeneratedColumn<String>(
    'data_residency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _upgradedAtMeta = const VerificationMeta(
    'upgradedAt',
  );
  @override
  late final GeneratedColumn<DateTime> upgradedAt = GeneratedColumn<DateTime>(
    'upgraded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    status,
    homeRegion,
    dataResidency,
    createdAt,
    upgradedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'principals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Principal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('home_region')) {
      context.handle(
        _homeRegionMeta,
        homeRegion.isAcceptableOrUnknown(data['home_region']!, _homeRegionMeta),
      );
    } else if (isInserting) {
      context.missing(_homeRegionMeta);
    }
    if (data.containsKey('data_residency')) {
      context.handle(
        _dataResidencyMeta,
        dataResidency.isAcceptableOrUnknown(
          data['data_residency']!,
          _dataResidencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataResidencyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('upgraded_at')) {
      context.handle(
        _upgradedAtMeta,
        upgradedAt.isAcceptableOrUnknown(data['upgraded_at']!, _upgradedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Principal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Principal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      homeRegion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_region'],
      )!,
      dataResidency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_residency'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      upgradedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}upgraded_at'],
      ),
    );
  }

  @override
  $PrincipalsTable createAlias(String alias) {
    return $PrincipalsTable(attachedDatabase, alias);
  }
}

class Principal extends DataClass implements Insertable<Principal> {
  final String id;
  final String kind;
  final String status;
  final String homeRegion;
  final String dataResidency;
  final DateTime createdAt;
  final DateTime? upgradedAt;
  const Principal({
    required this.id,
    required this.kind,
    required this.status,
    required this.homeRegion,
    required this.dataResidency,
    required this.createdAt,
    this.upgradedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['status'] = Variable<String>(status);
    map['home_region'] = Variable<String>(homeRegion);
    map['data_residency'] = Variable<String>(dataResidency);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || upgradedAt != null) {
      map['upgraded_at'] = Variable<DateTime>(upgradedAt);
    }
    return map;
  }

  PrincipalsCompanion toCompanion(bool nullToAbsent) {
    return PrincipalsCompanion(
      id: Value(id),
      kind: Value(kind),
      status: Value(status),
      homeRegion: Value(homeRegion),
      dataResidency: Value(dataResidency),
      createdAt: Value(createdAt),
      upgradedAt: upgradedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(upgradedAt),
    );
  }

  factory Principal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Principal(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      status: serializer.fromJson<String>(json['status']),
      homeRegion: serializer.fromJson<String>(json['homeRegion']),
      dataResidency: serializer.fromJson<String>(json['dataResidency']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      upgradedAt: serializer.fromJson<DateTime?>(json['upgradedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'status': serializer.toJson<String>(status),
      'homeRegion': serializer.toJson<String>(homeRegion),
      'dataResidency': serializer.toJson<String>(dataResidency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'upgradedAt': serializer.toJson<DateTime?>(upgradedAt),
    };
  }

  Principal copyWith({
    String? id,
    String? kind,
    String? status,
    String? homeRegion,
    String? dataResidency,
    DateTime? createdAt,
    Value<DateTime?> upgradedAt = const Value.absent(),
  }) => Principal(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    status: status ?? this.status,
    homeRegion: homeRegion ?? this.homeRegion,
    dataResidency: dataResidency ?? this.dataResidency,
    createdAt: createdAt ?? this.createdAt,
    upgradedAt: upgradedAt.present ? upgradedAt.value : this.upgradedAt,
  );
  Principal copyWithCompanion(PrincipalsCompanion data) {
    return Principal(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      status: data.status.present ? data.status.value : this.status,
      homeRegion: data.homeRegion.present
          ? data.homeRegion.value
          : this.homeRegion,
      dataResidency: data.dataResidency.present
          ? data.dataResidency.value
          : this.dataResidency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      upgradedAt: data.upgradedAt.present
          ? data.upgradedAt.value
          : this.upgradedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Principal(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('homeRegion: $homeRegion, ')
          ..write('dataResidency: $dataResidency, ')
          ..write('createdAt: $createdAt, ')
          ..write('upgradedAt: $upgradedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    status,
    homeRegion,
    dataResidency,
    createdAt,
    upgradedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Principal &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.status == this.status &&
          other.homeRegion == this.homeRegion &&
          other.dataResidency == this.dataResidency &&
          other.createdAt == this.createdAt &&
          other.upgradedAt == this.upgradedAt);
}

class PrincipalsCompanion extends UpdateCompanion<Principal> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> status;
  final Value<String> homeRegion;
  final Value<String> dataResidency;
  final Value<DateTime> createdAt;
  final Value<DateTime?> upgradedAt;
  final Value<int> rowid;
  const PrincipalsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.status = const Value.absent(),
    this.homeRegion = const Value.absent(),
    this.dataResidency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.upgradedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrincipalsCompanion.insert({
    required String id,
    required String kind,
    required String status,
    required String homeRegion,
    required String dataResidency,
    required DateTime createdAt,
    this.upgradedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       status = Value(status),
       homeRegion = Value(homeRegion),
       dataResidency = Value(dataResidency),
       createdAt = Value(createdAt);
  static Insertable<Principal> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? status,
    Expression<String>? homeRegion,
    Expression<String>? dataResidency,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? upgradedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (status != null) 'status': status,
      if (homeRegion != null) 'home_region': homeRegion,
      if (dataResidency != null) 'data_residency': dataResidency,
      if (createdAt != null) 'created_at': createdAt,
      if (upgradedAt != null) 'upgraded_at': upgradedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrincipalsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? status,
    Value<String>? homeRegion,
    Value<String>? dataResidency,
    Value<DateTime>? createdAt,
    Value<DateTime?>? upgradedAt,
    Value<int>? rowid,
  }) {
    return PrincipalsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      homeRegion: homeRegion ?? this.homeRegion,
      dataResidency: dataResidency ?? this.dataResidency,
      createdAt: createdAt ?? this.createdAt,
      upgradedAt: upgradedAt ?? this.upgradedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (homeRegion.present) {
      map['home_region'] = Variable<String>(homeRegion.value);
    }
    if (dataResidency.present) {
      map['data_residency'] = Variable<String>(dataResidency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (upgradedAt.present) {
      map['upgraded_at'] = Variable<DateTime>(upgradedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrincipalsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('homeRegion: $homeRegion, ')
          ..write('dataResidency: $dataResidency, ')
          ..write('createdAt: $createdAt, ')
          ..write('upgradedAt: $upgradedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceIdentitiesTable extends DeviceIdentities
    with TableInfo<$DeviceIdentitiesTable, DeviceIdentity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceIdentitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _principalIdMeta = const VerificationMeta(
    'principalId',
  );
  @override
  late final GeneratedColumn<String> principalId = GeneratedColumn<String>(
    'principal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES principals (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _publicInstallIdMeta = const VerificationMeta(
    'publicInstallId',
  );
  @override
  late final GeneratedColumn<String> publicInstallId = GeneratedColumn<String>(
    'public_install_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    principalId,
    publicInstallId,
    createdAt,
    lastSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_identities';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceIdentity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('principal_id')) {
      context.handle(
        _principalIdMeta,
        principalId.isAcceptableOrUnknown(
          data['principal_id']!,
          _principalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_principalIdMeta);
    }
    if (data.containsKey('public_install_id')) {
      context.handle(
        _publicInstallIdMeta,
        publicInstallId.isAcceptableOrUnknown(
          data['public_install_id']!,
          _publicInstallIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publicInstallIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {principalId},
  ];
  @override
  DeviceIdentity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceIdentity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      principalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}principal_id'],
      )!,
      publicInstallId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_install_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
    );
  }

  @override
  $DeviceIdentitiesTable createAlias(String alias) {
    return $DeviceIdentitiesTable(attachedDatabase, alias);
  }
}

class DeviceIdentity extends DataClass implements Insertable<DeviceIdentity> {
  final String id;
  final String principalId;
  final String publicInstallId;
  final DateTime createdAt;
  final DateTime lastSeenAt;
  const DeviceIdentity({
    required this.id,
    required this.principalId,
    required this.publicInstallId,
    required this.createdAt,
    required this.lastSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['principal_id'] = Variable<String>(principalId);
    map['public_install_id'] = Variable<String>(publicInstallId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    return map;
  }

  DeviceIdentitiesCompanion toCompanion(bool nullToAbsent) {
    return DeviceIdentitiesCompanion(
      id: Value(id),
      principalId: Value(principalId),
      publicInstallId: Value(publicInstallId),
      createdAt: Value(createdAt),
      lastSeenAt: Value(lastSeenAt),
    );
  }

  factory DeviceIdentity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceIdentity(
      id: serializer.fromJson<String>(json['id']),
      principalId: serializer.fromJson<String>(json['principalId']),
      publicInstallId: serializer.fromJson<String>(json['publicInstallId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'principalId': serializer.toJson<String>(principalId),
      'publicInstallId': serializer.toJson<String>(publicInstallId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
    };
  }

  DeviceIdentity copyWith({
    String? id,
    String? principalId,
    String? publicInstallId,
    DateTime? createdAt,
    DateTime? lastSeenAt,
  }) => DeviceIdentity(
    id: id ?? this.id,
    principalId: principalId ?? this.principalId,
    publicInstallId: publicInstallId ?? this.publicInstallId,
    createdAt: createdAt ?? this.createdAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
  );
  DeviceIdentity copyWithCompanion(DeviceIdentitiesCompanion data) {
    return DeviceIdentity(
      id: data.id.present ? data.id.value : this.id,
      principalId: data.principalId.present
          ? data.principalId.value
          : this.principalId,
      publicInstallId: data.publicInstallId.present
          ? data.publicInstallId.value
          : this.publicInstallId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceIdentity(')
          ..write('id: $id, ')
          ..write('principalId: $principalId, ')
          ..write('publicInstallId: $publicInstallId, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, principalId, publicInstallId, createdAt, lastSeenAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceIdentity &&
          other.id == this.id &&
          other.principalId == this.principalId &&
          other.publicInstallId == this.publicInstallId &&
          other.createdAt == this.createdAt &&
          other.lastSeenAt == this.lastSeenAt);
}

class DeviceIdentitiesCompanion extends UpdateCompanion<DeviceIdentity> {
  final Value<String> id;
  final Value<String> principalId;
  final Value<String> publicInstallId;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastSeenAt;
  final Value<int> rowid;
  const DeviceIdentitiesCompanion({
    this.id = const Value.absent(),
    this.principalId = const Value.absent(),
    this.publicInstallId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceIdentitiesCompanion.insert({
    required String id,
    required String principalId,
    required String publicInstallId,
    required DateTime createdAt,
    required DateTime lastSeenAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       principalId = Value(principalId),
       publicInstallId = Value(publicInstallId),
       createdAt = Value(createdAt),
       lastSeenAt = Value(lastSeenAt);
  static Insertable<DeviceIdentity> custom({
    Expression<String>? id,
    Expression<String>? principalId,
    Expression<String>? publicInstallId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastSeenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (principalId != null) 'principal_id': principalId,
      if (publicInstallId != null) 'public_install_id': publicInstallId,
      if (createdAt != null) 'created_at': createdAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceIdentitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? principalId,
    Value<String>? publicInstallId,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastSeenAt,
    Value<int>? rowid,
  }) {
    return DeviceIdentitiesCompanion(
      id: id ?? this.id,
      principalId: principalId ?? this.principalId,
      publicInstallId: publicInstallId ?? this.publicInstallId,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (principalId.present) {
      map['principal_id'] = Variable<String>(principalId.value);
    }
    if (publicInstallId.present) {
      map['public_install_id'] = Variable<String>(publicInstallId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceIdentitiesCompanion(')
          ..write('id: $id, ')
          ..write('principalId: $principalId, ')
          ..write('publicInstallId: $publicInstallId, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CognoteDatabase extends GeneratedDatabase {
  _$CognoteDatabase(QueryExecutor e) : super(e);
  $CognoteDatabaseManager get managers => $CognoteDatabaseManager(this);
  late final $PrincipalsTable principals = $PrincipalsTable(this);
  late final $DeviceIdentitiesTable deviceIdentities = $DeviceIdentitiesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    principals,
    deviceIdentities,
  ];
}

typedef $$PrincipalsTableCreateCompanionBuilder =
    PrincipalsCompanion Function({
      required String id,
      required String kind,
      required String status,
      required String homeRegion,
      required String dataResidency,
      required DateTime createdAt,
      Value<DateTime?> upgradedAt,
      Value<int> rowid,
    });
typedef $$PrincipalsTableUpdateCompanionBuilder =
    PrincipalsCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> status,
      Value<String> homeRegion,
      Value<String> dataResidency,
      Value<DateTime> createdAt,
      Value<DateTime?> upgradedAt,
      Value<int> rowid,
    });

final class $$PrincipalsTableReferences
    extends BaseReferences<_$CognoteDatabase, $PrincipalsTable, Principal> {
  $$PrincipalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DeviceIdentitiesTable, List<DeviceIdentity>>
  _deviceIdentitiesRefsTable(_$CognoteDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.deviceIdentities,
        aliasName: 'principals__id__device_identities__principal_id',
      );

  $$DeviceIdentitiesTableProcessedTableManager get deviceIdentitiesRefs {
    final manager = $$DeviceIdentitiesTableTableManager(
      $_db,
      $_db.deviceIdentities,
    ).filter((f) => f.principalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _deviceIdentitiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PrincipalsTableFilterComposer
    extends Composer<_$CognoteDatabase, $PrincipalsTable> {
  $$PrincipalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeRegion => $composableBuilder(
    column: $table.homeRegion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataResidency => $composableBuilder(
    column: $table.dataResidency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get upgradedAt => $composableBuilder(
    column: $table.upgradedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> deviceIdentitiesRefs(
    Expression<bool> Function($$DeviceIdentitiesTableFilterComposer f) f,
  ) {
    final $$DeviceIdentitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceIdentities,
      getReferencedColumn: (t) => t.principalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceIdentitiesTableFilterComposer(
            $db: $db,
            $table: $db.deviceIdentities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PrincipalsTableOrderingComposer
    extends Composer<_$CognoteDatabase, $PrincipalsTable> {
  $$PrincipalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeRegion => $composableBuilder(
    column: $table.homeRegion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataResidency => $composableBuilder(
    column: $table.dataResidency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get upgradedAt => $composableBuilder(
    column: $table.upgradedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrincipalsTableAnnotationComposer
    extends Composer<_$CognoteDatabase, $PrincipalsTable> {
  $$PrincipalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get homeRegion => $composableBuilder(
    column: $table.homeRegion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataResidency => $composableBuilder(
    column: $table.dataResidency,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get upgradedAt => $composableBuilder(
    column: $table.upgradedAt,
    builder: (column) => column,
  );

  Expression<T> deviceIdentitiesRefs<T extends Object>(
    Expression<T> Function($$DeviceIdentitiesTableAnnotationComposer a) f,
  ) {
    final $$DeviceIdentitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceIdentities,
      getReferencedColumn: (t) => t.principalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceIdentitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.deviceIdentities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PrincipalsTableTableManager
    extends
        RootTableManager<
          _$CognoteDatabase,
          $PrincipalsTable,
          Principal,
          $$PrincipalsTableFilterComposer,
          $$PrincipalsTableOrderingComposer,
          $$PrincipalsTableAnnotationComposer,
          $$PrincipalsTableCreateCompanionBuilder,
          $$PrincipalsTableUpdateCompanionBuilder,
          (Principal, $$PrincipalsTableReferences),
          Principal,
          PrefetchHooks Function({bool deviceIdentitiesRefs})
        > {
  $$PrincipalsTableTableManager(_$CognoteDatabase db, $PrincipalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrincipalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrincipalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrincipalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> homeRegion = const Value.absent(),
                Value<String> dataResidency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> upgradedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrincipalsCompanion(
                id: id,
                kind: kind,
                status: status,
                homeRegion: homeRegion,
                dataResidency: dataResidency,
                createdAt: createdAt,
                upgradedAt: upgradedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String status,
                required String homeRegion,
                required String dataResidency,
                required DateTime createdAt,
                Value<DateTime?> upgradedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrincipalsCompanion.insert(
                id: id,
                kind: kind,
                status: status,
                homeRegion: homeRegion,
                dataResidency: dataResidency,
                createdAt: createdAt,
                upgradedAt: upgradedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrincipalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceIdentitiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (deviceIdentitiesRefs) db.deviceIdentities,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (deviceIdentitiesRefs)
                    await $_getPrefetchedData<
                      Principal,
                      $PrincipalsTable,
                      DeviceIdentity
                    >(
                      currentTable: table,
                      referencedTable: $$PrincipalsTableReferences
                          ._deviceIdentitiesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PrincipalsTableReferences(
                            db,
                            table,
                            p0,
                          ).deviceIdentitiesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.principalId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PrincipalsTableProcessedTableManager =
    ProcessedTableManager<
      _$CognoteDatabase,
      $PrincipalsTable,
      Principal,
      $$PrincipalsTableFilterComposer,
      $$PrincipalsTableOrderingComposer,
      $$PrincipalsTableAnnotationComposer,
      $$PrincipalsTableCreateCompanionBuilder,
      $$PrincipalsTableUpdateCompanionBuilder,
      (Principal, $$PrincipalsTableReferences),
      Principal,
      PrefetchHooks Function({bool deviceIdentitiesRefs})
    >;
typedef $$DeviceIdentitiesTableCreateCompanionBuilder =
    DeviceIdentitiesCompanion Function({
      required String id,
      required String principalId,
      required String publicInstallId,
      required DateTime createdAt,
      required DateTime lastSeenAt,
      Value<int> rowid,
    });
typedef $$DeviceIdentitiesTableUpdateCompanionBuilder =
    DeviceIdentitiesCompanion Function({
      Value<String> id,
      Value<String> principalId,
      Value<String> publicInstallId,
      Value<DateTime> createdAt,
      Value<DateTime> lastSeenAt,
      Value<int> rowid,
    });

final class $$DeviceIdentitiesTableReferences
    extends
        BaseReferences<
          _$CognoteDatabase,
          $DeviceIdentitiesTable,
          DeviceIdentity
        > {
  $$DeviceIdentitiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PrincipalsTable _principalIdTable(_$CognoteDatabase db) => db
      .principals
      .createAlias('device_identities__principal_id__principals__id');

  $$PrincipalsTableProcessedTableManager get principalId {
    final $_column = $_itemColumn<String>('principal_id')!;

    final manager = $$PrincipalsTableTableManager(
      $_db,
      $_db.principals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_principalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DeviceIdentitiesTableFilterComposer
    extends Composer<_$CognoteDatabase, $DeviceIdentitiesTable> {
  $$DeviceIdentitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicInstallId => $composableBuilder(
    column: $table.publicInstallId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PrincipalsTableFilterComposer get principalId {
    final $$PrincipalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.principalId,
      referencedTable: $db.principals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrincipalsTableFilterComposer(
            $db: $db,
            $table: $db.principals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceIdentitiesTableOrderingComposer
    extends Composer<_$CognoteDatabase, $DeviceIdentitiesTable> {
  $$DeviceIdentitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicInstallId => $composableBuilder(
    column: $table.publicInstallId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PrincipalsTableOrderingComposer get principalId {
    final $$PrincipalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.principalId,
      referencedTable: $db.principals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrincipalsTableOrderingComposer(
            $db: $db,
            $table: $db.principals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceIdentitiesTableAnnotationComposer
    extends Composer<_$CognoteDatabase, $DeviceIdentitiesTable> {
  $$DeviceIdentitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get publicInstallId => $composableBuilder(
    column: $table.publicInstallId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  $$PrincipalsTableAnnotationComposer get principalId {
    final $$PrincipalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.principalId,
      referencedTable: $db.principals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrincipalsTableAnnotationComposer(
            $db: $db,
            $table: $db.principals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceIdentitiesTableTableManager
    extends
        RootTableManager<
          _$CognoteDatabase,
          $DeviceIdentitiesTable,
          DeviceIdentity,
          $$DeviceIdentitiesTableFilterComposer,
          $$DeviceIdentitiesTableOrderingComposer,
          $$DeviceIdentitiesTableAnnotationComposer,
          $$DeviceIdentitiesTableCreateCompanionBuilder,
          $$DeviceIdentitiesTableUpdateCompanionBuilder,
          (DeviceIdentity, $$DeviceIdentitiesTableReferences),
          DeviceIdentity,
          PrefetchHooks Function({bool principalId})
        > {
  $$DeviceIdentitiesTableTableManager(
    _$CognoteDatabase db,
    $DeviceIdentitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceIdentitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceIdentitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceIdentitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> principalId = const Value.absent(),
                Value<String> publicInstallId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceIdentitiesCompanion(
                id: id,
                principalId: principalId,
                publicInstallId: publicInstallId,
                createdAt: createdAt,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String principalId,
                required String publicInstallId,
                required DateTime createdAt,
                required DateTime lastSeenAt,
                Value<int> rowid = const Value.absent(),
              }) => DeviceIdentitiesCompanion.insert(
                id: id,
                principalId: principalId,
                publicInstallId: publicInstallId,
                createdAt: createdAt,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeviceIdentitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({principalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (principalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.principalId,
                                referencedTable:
                                    $$DeviceIdentitiesTableReferences
                                        ._principalIdTable(db),
                                referencedColumn:
                                    $$DeviceIdentitiesTableReferences
                                        ._principalIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DeviceIdentitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$CognoteDatabase,
      $DeviceIdentitiesTable,
      DeviceIdentity,
      $$DeviceIdentitiesTableFilterComposer,
      $$DeviceIdentitiesTableOrderingComposer,
      $$DeviceIdentitiesTableAnnotationComposer,
      $$DeviceIdentitiesTableCreateCompanionBuilder,
      $$DeviceIdentitiesTableUpdateCompanionBuilder,
      (DeviceIdentity, $$DeviceIdentitiesTableReferences),
      DeviceIdentity,
      PrefetchHooks Function({bool principalId})
    >;

class $CognoteDatabaseManager {
  final _$CognoteDatabase _db;
  $CognoteDatabaseManager(this._db);
  $$PrincipalsTableTableManager get principals =>
      $$PrincipalsTableTableManager(_db, _db.principals);
  $$DeviceIdentitiesTableTableManager get deviceIdentities =>
      $$DeviceIdentitiesTableTableManager(_db, _db.deviceIdentities);
}
