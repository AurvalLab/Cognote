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

class $ObservationsTable extends Observations
    with TableInfo<$ObservationsTable, Observation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES principals (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _inputTypeMeta = const VerificationMeta(
    'inputType',
  );
  @override
  late final GeneratedColumn<String> inputType = GeneratedColumn<String>(
    'input_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneOffsetMeta = const VerificationMeta(
    'timezoneOffset',
  );
  @override
  late final GeneratedColumn<int> timezoneOffset = GeneratedColumn<int>(
    'timezone_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privacyLevelMeta = const VerificationMeta(
    'privacyLevel',
  );
  @override
  late final GeneratedColumn<String> privacyLevel = GeneratedColumn<String>(
    'privacy_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cloudAiPolicyMeta = const VerificationMeta(
    'cloudAiPolicy',
  );
  @override
  late final GeneratedColumn<String> cloudAiPolicy = GeneratedColumn<String>(
    'cloud_ai_policy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncPolicyMeta = const VerificationMeta(
    'syncPolicy',
  );
  @override
  late final GeneratedColumn<String> syncPolicy = GeneratedColumn<String>(
    'sync_policy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByDeviceIdMeta = const VerificationMeta(
    'createdByDeviceId',
  );
  @override
  late final GeneratedColumn<String> createdByDeviceId =
      GeneratedColumn<String>(
        'created_by_device_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES device_identities (id) ON DELETE RESTRICT',
        ),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverRevisionMeta = const VerificationMeta(
    'serverRevision',
  );
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
    'server_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    inputType,
    rawText,
    capturedAt,
    timezoneOffset,
    privacyLevel,
    cloudAiPolicy,
    syncPolicy,
    createdByDeviceId,
    createdAt,
    updatedAt,
    deletedAt,
    serverRevision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Observation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('input_type')) {
      context.handle(
        _inputTypeMeta,
        inputType.isAcceptableOrUnknown(data['input_type']!, _inputTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_inputTypeMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('timezone_offset')) {
      context.handle(
        _timezoneOffsetMeta,
        timezoneOffset.isAcceptableOrUnknown(
          data['timezone_offset']!,
          _timezoneOffsetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timezoneOffsetMeta);
    }
    if (data.containsKey('privacy_level')) {
      context.handle(
        _privacyLevelMeta,
        privacyLevel.isAcceptableOrUnknown(
          data['privacy_level']!,
          _privacyLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyLevelMeta);
    }
    if (data.containsKey('cloud_ai_policy')) {
      context.handle(
        _cloudAiPolicyMeta,
        cloudAiPolicy.isAcceptableOrUnknown(
          data['cloud_ai_policy']!,
          _cloudAiPolicyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cloudAiPolicyMeta);
    }
    if (data.containsKey('sync_policy')) {
      context.handle(
        _syncPolicyMeta,
        syncPolicy.isAcceptableOrUnknown(data['sync_policy']!, _syncPolicyMeta),
      );
    } else if (isInserting) {
      context.missing(_syncPolicyMeta);
    }
    if (data.containsKey('created_by_device_id')) {
      context.handle(
        _createdByDeviceIdMeta,
        createdByDeviceId.isAcceptableOrUnknown(
          data['created_by_device_id']!,
          _createdByDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByDeviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_revision')) {
      context.handle(
        _serverRevisionMeta,
        serverRevision.isAcceptableOrUnknown(
          data['server_revision']!,
          _serverRevisionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Observation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Observation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      inputType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_type'],
      )!,
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      timezoneOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timezone_offset'],
      )!,
      privacyLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy_level'],
      )!,
      cloudAiPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_ai_policy'],
      )!,
      syncPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_policy'],
      )!,
      createdByDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_revision'],
      ),
    );
  }

  @override
  $ObservationsTable createAlias(String alias) {
    return $ObservationsTable(attachedDatabase, alias);
  }
}

class Observation extends DataClass implements Insertable<Observation> {
  final String id;
  final String ownerId;
  final String inputType;
  final String? rawText;
  final DateTime capturedAt;
  final int timezoneOffset;
  final String privacyLevel;
  final String cloudAiPolicy;
  final String syncPolicy;
  final String createdByDeviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverRevision;
  const Observation({
    required this.id,
    required this.ownerId,
    required this.inputType,
    this.rawText,
    required this.capturedAt,
    required this.timezoneOffset,
    required this.privacyLevel,
    required this.cloudAiPolicy,
    required this.syncPolicy,
    required this.createdByDeviceId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverRevision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['input_type'] = Variable<String>(inputType);
    if (!nullToAbsent || rawText != null) {
      map['raw_text'] = Variable<String>(rawText);
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['timezone_offset'] = Variable<int>(timezoneOffset);
    map['privacy_level'] = Variable<String>(privacyLevel);
    map['cloud_ai_policy'] = Variable<String>(cloudAiPolicy);
    map['sync_policy'] = Variable<String>(syncPolicy);
    map['created_by_device_id'] = Variable<String>(createdByDeviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverRevision != null) {
      map['server_revision'] = Variable<int>(serverRevision);
    }
    return map;
  }

  ObservationsCompanion toCompanion(bool nullToAbsent) {
    return ObservationsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      inputType: Value(inputType),
      rawText: rawText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawText),
      capturedAt: Value(capturedAt),
      timezoneOffset: Value(timezoneOffset),
      privacyLevel: Value(privacyLevel),
      cloudAiPolicy: Value(cloudAiPolicy),
      syncPolicy: Value(syncPolicy),
      createdByDeviceId: Value(createdByDeviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverRevision: serverRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRevision),
    );
  }

  factory Observation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Observation(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      inputType: serializer.fromJson<String>(json['inputType']),
      rawText: serializer.fromJson<String?>(json['rawText']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      timezoneOffset: serializer.fromJson<int>(json['timezoneOffset']),
      privacyLevel: serializer.fromJson<String>(json['privacyLevel']),
      cloudAiPolicy: serializer.fromJson<String>(json['cloudAiPolicy']),
      syncPolicy: serializer.fromJson<String>(json['syncPolicy']),
      createdByDeviceId: serializer.fromJson<String>(json['createdByDeviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverRevision: serializer.fromJson<int?>(json['serverRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'inputType': serializer.toJson<String>(inputType),
      'rawText': serializer.toJson<String?>(rawText),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'timezoneOffset': serializer.toJson<int>(timezoneOffset),
      'privacyLevel': serializer.toJson<String>(privacyLevel),
      'cloudAiPolicy': serializer.toJson<String>(cloudAiPolicy),
      'syncPolicy': serializer.toJson<String>(syncPolicy),
      'createdByDeviceId': serializer.toJson<String>(createdByDeviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverRevision': serializer.toJson<int?>(serverRevision),
    };
  }

  Observation copyWith({
    String? id,
    String? ownerId,
    String? inputType,
    Value<String?> rawText = const Value.absent(),
    DateTime? capturedAt,
    int? timezoneOffset,
    String? privacyLevel,
    String? cloudAiPolicy,
    String? syncPolicy,
    String? createdByDeviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverRevision = const Value.absent(),
  }) => Observation(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    inputType: inputType ?? this.inputType,
    rawText: rawText.present ? rawText.value : this.rawText,
    capturedAt: capturedAt ?? this.capturedAt,
    timezoneOffset: timezoneOffset ?? this.timezoneOffset,
    privacyLevel: privacyLevel ?? this.privacyLevel,
    cloudAiPolicy: cloudAiPolicy ?? this.cloudAiPolicy,
    syncPolicy: syncPolicy ?? this.syncPolicy,
    createdByDeviceId: createdByDeviceId ?? this.createdByDeviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverRevision: serverRevision.present
        ? serverRevision.value
        : this.serverRevision,
  );
  Observation copyWithCompanion(ObservationsCompanion data) {
    return Observation(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      inputType: data.inputType.present ? data.inputType.value : this.inputType,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      timezoneOffset: data.timezoneOffset.present
          ? data.timezoneOffset.value
          : this.timezoneOffset,
      privacyLevel: data.privacyLevel.present
          ? data.privacyLevel.value
          : this.privacyLevel,
      cloudAiPolicy: data.cloudAiPolicy.present
          ? data.cloudAiPolicy.value
          : this.cloudAiPolicy,
      syncPolicy: data.syncPolicy.present
          ? data.syncPolicy.value
          : this.syncPolicy,
      createdByDeviceId: data.createdByDeviceId.present
          ? data.createdByDeviceId.value
          : this.createdByDeviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Observation(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('inputType: $inputType, ')
          ..write('rawText: $rawText, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('timezoneOffset: $timezoneOffset, ')
          ..write('privacyLevel: $privacyLevel, ')
          ..write('cloudAiPolicy: $cloudAiPolicy, ')
          ..write('syncPolicy: $syncPolicy, ')
          ..write('createdByDeviceId: $createdByDeviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    inputType,
    rawText,
    capturedAt,
    timezoneOffset,
    privacyLevel,
    cloudAiPolicy,
    syncPolicy,
    createdByDeviceId,
    createdAt,
    updatedAt,
    deletedAt,
    serverRevision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Observation &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.inputType == this.inputType &&
          other.rawText == this.rawText &&
          other.capturedAt == this.capturedAt &&
          other.timezoneOffset == this.timezoneOffset &&
          other.privacyLevel == this.privacyLevel &&
          other.cloudAiPolicy == this.cloudAiPolicy &&
          other.syncPolicy == this.syncPolicy &&
          other.createdByDeviceId == this.createdByDeviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverRevision == this.serverRevision);
}

class ObservationsCompanion extends UpdateCompanion<Observation> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> inputType;
  final Value<String?> rawText;
  final Value<DateTime> capturedAt;
  final Value<int> timezoneOffset;
  final Value<String> privacyLevel;
  final Value<String> cloudAiPolicy;
  final Value<String> syncPolicy;
  final Value<String> createdByDeviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverRevision;
  final Value<int> rowid;
  const ObservationsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.inputType = const Value.absent(),
    this.rawText = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.timezoneOffset = const Value.absent(),
    this.privacyLevel = const Value.absent(),
    this.cloudAiPolicy = const Value.absent(),
    this.syncPolicy = const Value.absent(),
    this.createdByDeviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObservationsCompanion.insert({
    required String id,
    required String ownerId,
    required String inputType,
    this.rawText = const Value.absent(),
    required DateTime capturedAt,
    required int timezoneOffset,
    required String privacyLevel,
    required String cloudAiPolicy,
    required String syncPolicy,
    required String createdByDeviceId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       inputType = Value(inputType),
       capturedAt = Value(capturedAt),
       timezoneOffset = Value(timezoneOffset),
       privacyLevel = Value(privacyLevel),
       cloudAiPolicy = Value(cloudAiPolicy),
       syncPolicy = Value(syncPolicy),
       createdByDeviceId = Value(createdByDeviceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Observation> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? inputType,
    Expression<String>? rawText,
    Expression<DateTime>? capturedAt,
    Expression<int>? timezoneOffset,
    Expression<String>? privacyLevel,
    Expression<String>? cloudAiPolicy,
    Expression<String>? syncPolicy,
    Expression<String>? createdByDeviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (inputType != null) 'input_type': inputType,
      if (rawText != null) 'raw_text': rawText,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (timezoneOffset != null) 'timezone_offset': timezoneOffset,
      if (privacyLevel != null) 'privacy_level': privacyLevel,
      if (cloudAiPolicy != null) 'cloud_ai_policy': cloudAiPolicy,
      if (syncPolicy != null) 'sync_policy': syncPolicy,
      if (createdByDeviceId != null) 'created_by_device_id': createdByDeviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObservationsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? inputType,
    Value<String?>? rawText,
    Value<DateTime>? capturedAt,
    Value<int>? timezoneOffset,
    Value<String>? privacyLevel,
    Value<String>? cloudAiPolicy,
    Value<String>? syncPolicy,
    Value<String>? createdByDeviceId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverRevision,
    Value<int>? rowid,
  }) {
    return ObservationsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      inputType: inputType ?? this.inputType,
      rawText: rawText ?? this.rawText,
      capturedAt: capturedAt ?? this.capturedAt,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      cloudAiPolicy: cloudAiPolicy ?? this.cloudAiPolicy,
      syncPolicy: syncPolicy ?? this.syncPolicy,
      createdByDeviceId: createdByDeviceId ?? this.createdByDeviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverRevision: serverRevision ?? this.serverRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (inputType.present) {
      map['input_type'] = Variable<String>(inputType.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (timezoneOffset.present) {
      map['timezone_offset'] = Variable<int>(timezoneOffset.value);
    }
    if (privacyLevel.present) {
      map['privacy_level'] = Variable<String>(privacyLevel.value);
    }
    if (cloudAiPolicy.present) {
      map['cloud_ai_policy'] = Variable<String>(cloudAiPolicy.value);
    }
    if (syncPolicy.present) {
      map['sync_policy'] = Variable<String>(syncPolicy.value);
    }
    if (createdByDeviceId.present) {
      map['created_by_device_id'] = Variable<String>(createdByDeviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservationsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('inputType: $inputType, ')
          ..write('rawText: $rawText, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('timezoneOffset: $timezoneOffset, ')
          ..write('privacyLevel: $privacyLevel, ')
          ..write('cloudAiPolicy: $cloudAiPolicy, ')
          ..write('syncPolicy: $syncPolicy, ')
          ..write('createdByDeviceId: $createdByDeviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAssetsTable extends LocalAssets
    with TableInfo<$LocalAssetsTable, LocalAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observationIdMeta = const VerificationMeta(
    'observationId',
  );
  @override
  late final GeneratedColumn<String> observationId = GeneratedColumn<String>(
    'observation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES observations (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _localUriMeta = const VerificationMeta(
    'localUri',
  );
  @override
  late final GeneratedColumn<String> localUri = GeneratedColumn<String>(
    'local_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _analysisDerivativeUriMeta =
      const VerificationMeta('analysisDerivativeUri');
  @override
  late final GeneratedColumn<String> analysisDerivativeUri =
      GeneratedColumn<String>(
        'analysis_derivative_uri',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _localOriginalPresentMeta =
      const VerificationMeta('localOriginalPresent');
  @override
  late final GeneratedColumn<bool> localOriginalPresent = GeneratedColumn<bool>(
    'local_original_present',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("local_original_present" IN (0, 1))',
    ),
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exifRemovedMeta = const VerificationMeta(
    'exifRemoved',
  );
  @override
  late final GeneratedColumn<bool> exifRemoved = GeneratedColumn<bool>(
    'exif_removed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("exif_removed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _uploadStateMeta = const VerificationMeta(
    'uploadState',
  );
  @override
  late final GeneratedColumn<String> uploadState = GeneratedColumn<String>(
    'upload_state',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    observationId,
    localUri,
    analysisDerivativeUri,
    localOriginalPresent,
    mimeType,
    bytes,
    width,
    height,
    sha256,
    exifRemoved,
    uploadState,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('observation_id')) {
      context.handle(
        _observationIdMeta,
        observationId.isAcceptableOrUnknown(
          data['observation_id']!,
          _observationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observationIdMeta);
    }
    if (data.containsKey('local_uri')) {
      context.handle(
        _localUriMeta,
        localUri.isAcceptableOrUnknown(data['local_uri']!, _localUriMeta),
      );
    } else if (isInserting) {
      context.missing(_localUriMeta);
    }
    if (data.containsKey('analysis_derivative_uri')) {
      context.handle(
        _analysisDerivativeUriMeta,
        analysisDerivativeUri.isAcceptableOrUnknown(
          data['analysis_derivative_uri']!,
          _analysisDerivativeUriMeta,
        ),
      );
    }
    if (data.containsKey('local_original_present')) {
      context.handle(
        _localOriginalPresentMeta,
        localOriginalPresent.isAcceptableOrUnknown(
          data['local_original_present']!,
          _localOriginalPresentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localOriginalPresentMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('exif_removed')) {
      context.handle(
        _exifRemovedMeta,
        exifRemoved.isAcceptableOrUnknown(
          data['exif_removed']!,
          _exifRemovedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exifRemovedMeta);
    }
    if (data.containsKey('upload_state')) {
      context.handle(
        _uploadStateMeta,
        uploadState.isAcceptableOrUnknown(
          data['upload_state']!,
          _uploadStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uploadStateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAsset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      observationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation_id'],
      )!,
      localUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_uri'],
      )!,
      analysisDerivativeUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_derivative_uri'],
      ),
      localOriginalPresent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}local_original_present'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      exifRemoved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}exif_removed'],
      )!,
      uploadState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upload_state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalAssetsTable createAlias(String alias) {
    return $LocalAssetsTable(attachedDatabase, alias);
  }
}

class LocalAsset extends DataClass implements Insertable<LocalAsset> {
  final String id;
  final String observationId;
  final String localUri;
  final String? analysisDerivativeUri;
  final bool localOriginalPresent;
  final String mimeType;
  final int bytes;
  final int? width;
  final int? height;
  final String sha256;
  final bool exifRemoved;
  final String uploadState;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalAsset({
    required this.id,
    required this.observationId,
    required this.localUri,
    this.analysisDerivativeUri,
    required this.localOriginalPresent,
    required this.mimeType,
    required this.bytes,
    this.width,
    this.height,
    required this.sha256,
    required this.exifRemoved,
    required this.uploadState,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['observation_id'] = Variable<String>(observationId);
    map['local_uri'] = Variable<String>(localUri);
    if (!nullToAbsent || analysisDerivativeUri != null) {
      map['analysis_derivative_uri'] = Variable<String>(analysisDerivativeUri);
    }
    map['local_original_present'] = Variable<bool>(localOriginalPresent);
    map['mime_type'] = Variable<String>(mimeType);
    map['bytes'] = Variable<int>(bytes);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['sha256'] = Variable<String>(sha256);
    map['exif_removed'] = Variable<bool>(exifRemoved);
    map['upload_state'] = Variable<String>(uploadState);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalAssetsCompanion toCompanion(bool nullToAbsent) {
    return LocalAssetsCompanion(
      id: Value(id),
      observationId: Value(observationId),
      localUri: Value(localUri),
      analysisDerivativeUri: analysisDerivativeUri == null && nullToAbsent
          ? const Value.absent()
          : Value(analysisDerivativeUri),
      localOriginalPresent: Value(localOriginalPresent),
      mimeType: Value(mimeType),
      bytes: Value(bytes),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      sha256: Value(sha256),
      exifRemoved: Value(exifRemoved),
      uploadState: Value(uploadState),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAsset(
      id: serializer.fromJson<String>(json['id']),
      observationId: serializer.fromJson<String>(json['observationId']),
      localUri: serializer.fromJson<String>(json['localUri']),
      analysisDerivativeUri: serializer.fromJson<String?>(
        json['analysisDerivativeUri'],
      ),
      localOriginalPresent: serializer.fromJson<bool>(
        json['localOriginalPresent'],
      ),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      bytes: serializer.fromJson<int>(json['bytes']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      sha256: serializer.fromJson<String>(json['sha256']),
      exifRemoved: serializer.fromJson<bool>(json['exifRemoved']),
      uploadState: serializer.fromJson<String>(json['uploadState']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'observationId': serializer.toJson<String>(observationId),
      'localUri': serializer.toJson<String>(localUri),
      'analysisDerivativeUri': serializer.toJson<String?>(
        analysisDerivativeUri,
      ),
      'localOriginalPresent': serializer.toJson<bool>(localOriginalPresent),
      'mimeType': serializer.toJson<String>(mimeType),
      'bytes': serializer.toJson<int>(bytes),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'sha256': serializer.toJson<String>(sha256),
      'exifRemoved': serializer.toJson<bool>(exifRemoved),
      'uploadState': serializer.toJson<String>(uploadState),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalAsset copyWith({
    String? id,
    String? observationId,
    String? localUri,
    Value<String?> analysisDerivativeUri = const Value.absent(),
    bool? localOriginalPresent,
    String? mimeType,
    int? bytes,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    String? sha256,
    bool? exifRemoved,
    String? uploadState,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalAsset(
    id: id ?? this.id,
    observationId: observationId ?? this.observationId,
    localUri: localUri ?? this.localUri,
    analysisDerivativeUri: analysisDerivativeUri.present
        ? analysisDerivativeUri.value
        : this.analysisDerivativeUri,
    localOriginalPresent: localOriginalPresent ?? this.localOriginalPresent,
    mimeType: mimeType ?? this.mimeType,
    bytes: bytes ?? this.bytes,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    sha256: sha256 ?? this.sha256,
    exifRemoved: exifRemoved ?? this.exifRemoved,
    uploadState: uploadState ?? this.uploadState,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalAsset copyWithCompanion(LocalAssetsCompanion data) {
    return LocalAsset(
      id: data.id.present ? data.id.value : this.id,
      observationId: data.observationId.present
          ? data.observationId.value
          : this.observationId,
      localUri: data.localUri.present ? data.localUri.value : this.localUri,
      analysisDerivativeUri: data.analysisDerivativeUri.present
          ? data.analysisDerivativeUri.value
          : this.analysisDerivativeUri,
      localOriginalPresent: data.localOriginalPresent.present
          ? data.localOriginalPresent.value
          : this.localOriginalPresent,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      exifRemoved: data.exifRemoved.present
          ? data.exifRemoved.value
          : this.exifRemoved,
      uploadState: data.uploadState.present
          ? data.uploadState.value
          : this.uploadState,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAsset(')
          ..write('id: $id, ')
          ..write('observationId: $observationId, ')
          ..write('localUri: $localUri, ')
          ..write('analysisDerivativeUri: $analysisDerivativeUri, ')
          ..write('localOriginalPresent: $localOriginalPresent, ')
          ..write('mimeType: $mimeType, ')
          ..write('bytes: $bytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('sha256: $sha256, ')
          ..write('exifRemoved: $exifRemoved, ')
          ..write('uploadState: $uploadState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    observationId,
    localUri,
    analysisDerivativeUri,
    localOriginalPresent,
    mimeType,
    bytes,
    width,
    height,
    sha256,
    exifRemoved,
    uploadState,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAsset &&
          other.id == this.id &&
          other.observationId == this.observationId &&
          other.localUri == this.localUri &&
          other.analysisDerivativeUri == this.analysisDerivativeUri &&
          other.localOriginalPresent == this.localOriginalPresent &&
          other.mimeType == this.mimeType &&
          other.bytes == this.bytes &&
          other.width == this.width &&
          other.height == this.height &&
          other.sha256 == this.sha256 &&
          other.exifRemoved == this.exifRemoved &&
          other.uploadState == this.uploadState &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalAssetsCompanion extends UpdateCompanion<LocalAsset> {
  final Value<String> id;
  final Value<String> observationId;
  final Value<String> localUri;
  final Value<String?> analysisDerivativeUri;
  final Value<bool> localOriginalPresent;
  final Value<String> mimeType;
  final Value<int> bytes;
  final Value<int?> width;
  final Value<int?> height;
  final Value<String> sha256;
  final Value<bool> exifRemoved;
  final Value<String> uploadState;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalAssetsCompanion({
    this.id = const Value.absent(),
    this.observationId = const Value.absent(),
    this.localUri = const Value.absent(),
    this.analysisDerivativeUri = const Value.absent(),
    this.localOriginalPresent = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.bytes = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.exifRemoved = const Value.absent(),
    this.uploadState = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAssetsCompanion.insert({
    required String id,
    required String observationId,
    required String localUri,
    this.analysisDerivativeUri = const Value.absent(),
    required bool localOriginalPresent,
    required String mimeType,
    required int bytes,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required String sha256,
    required bool exifRemoved,
    required String uploadState,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       observationId = Value(observationId),
       localUri = Value(localUri),
       localOriginalPresent = Value(localOriginalPresent),
       mimeType = Value(mimeType),
       bytes = Value(bytes),
       sha256 = Value(sha256),
       exifRemoved = Value(exifRemoved),
       uploadState = Value(uploadState),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalAsset> custom({
    Expression<String>? id,
    Expression<String>? observationId,
    Expression<String>? localUri,
    Expression<String>? analysisDerivativeUri,
    Expression<bool>? localOriginalPresent,
    Expression<String>? mimeType,
    Expression<int>? bytes,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? sha256,
    Expression<bool>? exifRemoved,
    Expression<String>? uploadState,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (observationId != null) 'observation_id': observationId,
      if (localUri != null) 'local_uri': localUri,
      if (analysisDerivativeUri != null)
        'analysis_derivative_uri': analysisDerivativeUri,
      if (localOriginalPresent != null)
        'local_original_present': localOriginalPresent,
      if (mimeType != null) 'mime_type': mimeType,
      if (bytes != null) 'bytes': bytes,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (sha256 != null) 'sha256': sha256,
      if (exifRemoved != null) 'exif_removed': exifRemoved,
      if (uploadState != null) 'upload_state': uploadState,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAssetsCompanion copyWith({
    Value<String>? id,
    Value<String>? observationId,
    Value<String>? localUri,
    Value<String?>? analysisDerivativeUri,
    Value<bool>? localOriginalPresent,
    Value<String>? mimeType,
    Value<int>? bytes,
    Value<int?>? width,
    Value<int?>? height,
    Value<String>? sha256,
    Value<bool>? exifRemoved,
    Value<String>? uploadState,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalAssetsCompanion(
      id: id ?? this.id,
      observationId: observationId ?? this.observationId,
      localUri: localUri ?? this.localUri,
      analysisDerivativeUri:
          analysisDerivativeUri ?? this.analysisDerivativeUri,
      localOriginalPresent: localOriginalPresent ?? this.localOriginalPresent,
      mimeType: mimeType ?? this.mimeType,
      bytes: bytes ?? this.bytes,
      width: width ?? this.width,
      height: height ?? this.height,
      sha256: sha256 ?? this.sha256,
      exifRemoved: exifRemoved ?? this.exifRemoved,
      uploadState: uploadState ?? this.uploadState,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (observationId.present) {
      map['observation_id'] = Variable<String>(observationId.value);
    }
    if (localUri.present) {
      map['local_uri'] = Variable<String>(localUri.value);
    }
    if (analysisDerivativeUri.present) {
      map['analysis_derivative_uri'] = Variable<String>(
        analysisDerivativeUri.value,
      );
    }
    if (localOriginalPresent.present) {
      map['local_original_present'] = Variable<bool>(
        localOriginalPresent.value,
      );
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (exifRemoved.present) {
      map['exif_removed'] = Variable<bool>(exifRemoved.value);
    }
    if (uploadState.present) {
      map['upload_state'] = Variable<String>(uploadState.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssetsCompanion(')
          ..write('id: $id, ')
          ..write('observationId: $observationId, ')
          ..write('localUri: $localUri, ')
          ..write('analysisDerivativeUri: $analysisDerivativeUri, ')
          ..write('localOriginalPresent: $localOriginalPresent, ')
          ..write('mimeType: $mimeType, ')
          ..write('bytes: $bytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('sha256: $sha256, ')
          ..write('exifRemoved: $exifRemoved, ')
          ..write('uploadState: $uploadState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxOperationsTable extends OutboxOperations
    with TableInfo<$OutboxOperationsTable, OutboxOperationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES principals (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES device_identities (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _aggregateTypeMeta = const VerificationMeta(
    'aggregateType',
  );
  @override
  late final GeneratedColumn<String> aggregateType = GeneratedColumn<String>(
    'aggregate_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateIdMeta = const VerificationMeta(
    'aggregateId',
  );
  @override
  late final GeneratedColumn<String> aggregateId = GeneratedColumn<String>(
    'aggregate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationKindMeta = const VerificationMeta(
    'operationKind',
  );
  @override
  late final GeneratedColumn<String> operationKind = GeneratedColumn<String>(
    'operation_kind',
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
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    ownerId,
    deviceId,
    aggregateType,
    aggregateId,
    operationKind,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxOperationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('aggregate_type')) {
      context.handle(
        _aggregateTypeMeta,
        aggregateType.isAcceptableOrUnknown(
          data['aggregate_type']!,
          _aggregateTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateTypeMeta);
    }
    if (data.containsKey('aggregate_id')) {
      context.handle(
        _aggregateIdMeta,
        aggregateId.isAcceptableOrUnknown(
          data['aggregate_id']!,
          _aggregateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateIdMeta);
    }
    if (data.containsKey('operation_kind')) {
      context.handle(
        _operationKindMeta,
        operationKind.isAcceptableOrUnknown(
          data['operation_kind']!,
          _operationKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationKindMeta);
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
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  OutboxOperationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxOperationRow(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      aggregateType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_type'],
      )!,
      aggregateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_id'],
      )!,
      operationKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_kind'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxOperationsTable createAlias(String alias) {
    return $OutboxOperationsTable(attachedDatabase, alias);
  }
}

class OutboxOperationRow extends DataClass
    implements Insertable<OutboxOperationRow> {
  final String operationId;
  final String ownerId;
  final String deviceId;
  final String aggregateType;
  final String aggregateId;
  final String operationKind;
  final DateTime createdAt;
  const OutboxOperationRow({
    required this.operationId,
    required this.ownerId,
    required this.deviceId,
    required this.aggregateType,
    required this.aggregateId,
    required this.operationKind,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['owner_id'] = Variable<String>(ownerId);
    map['device_id'] = Variable<String>(deviceId);
    map['aggregate_type'] = Variable<String>(aggregateType);
    map['aggregate_id'] = Variable<String>(aggregateId);
    map['operation_kind'] = Variable<String>(operationKind);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxOperationsCompanion toCompanion(bool nullToAbsent) {
    return OutboxOperationsCompanion(
      operationId: Value(operationId),
      ownerId: Value(ownerId),
      deviceId: Value(deviceId),
      aggregateType: Value(aggregateType),
      aggregateId: Value(aggregateId),
      operationKind: Value(operationKind),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxOperationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxOperationRow(
      operationId: serializer.fromJson<String>(json['operationId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      aggregateType: serializer.fromJson<String>(json['aggregateType']),
      aggregateId: serializer.fromJson<String>(json['aggregateId']),
      operationKind: serializer.fromJson<String>(json['operationKind']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'ownerId': serializer.toJson<String>(ownerId),
      'deviceId': serializer.toJson<String>(deviceId),
      'aggregateType': serializer.toJson<String>(aggregateType),
      'aggregateId': serializer.toJson<String>(aggregateId),
      'operationKind': serializer.toJson<String>(operationKind),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxOperationRow copyWith({
    String? operationId,
    String? ownerId,
    String? deviceId,
    String? aggregateType,
    String? aggregateId,
    String? operationKind,
    DateTime? createdAt,
  }) => OutboxOperationRow(
    operationId: operationId ?? this.operationId,
    ownerId: ownerId ?? this.ownerId,
    deviceId: deviceId ?? this.deviceId,
    aggregateType: aggregateType ?? this.aggregateType,
    aggregateId: aggregateId ?? this.aggregateId,
    operationKind: operationKind ?? this.operationKind,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxOperationRow copyWithCompanion(OutboxOperationsCompanion data) {
    return OutboxOperationRow(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      aggregateType: data.aggregateType.present
          ? data.aggregateType.value
          : this.aggregateType,
      aggregateId: data.aggregateId.present
          ? data.aggregateId.value
          : this.aggregateId,
      operationKind: data.operationKind.present
          ? data.operationKind.value
          : this.operationKind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOperationRow(')
          ..write('operationId: $operationId, ')
          ..write('ownerId: $ownerId, ')
          ..write('deviceId: $deviceId, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('operationKind: $operationKind, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    operationId,
    ownerId,
    deviceId,
    aggregateType,
    aggregateId,
    operationKind,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxOperationRow &&
          other.operationId == this.operationId &&
          other.ownerId == this.ownerId &&
          other.deviceId == this.deviceId &&
          other.aggregateType == this.aggregateType &&
          other.aggregateId == this.aggregateId &&
          other.operationKind == this.operationKind &&
          other.createdAt == this.createdAt);
}

class OutboxOperationsCompanion extends UpdateCompanion<OutboxOperationRow> {
  final Value<String> operationId;
  final Value<String> ownerId;
  final Value<String> deviceId;
  final Value<String> aggregateType;
  final Value<String> aggregateId;
  final Value<String> operationKind;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OutboxOperationsCompanion({
    this.operationId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.aggregateType = const Value.absent(),
    this.aggregateId = const Value.absent(),
    this.operationKind = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxOperationsCompanion.insert({
    required String operationId,
    required String ownerId,
    required String deviceId,
    required String aggregateType,
    required String aggregateId,
    required String operationKind,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       ownerId = Value(ownerId),
       deviceId = Value(deviceId),
       aggregateType = Value(aggregateType),
       aggregateId = Value(aggregateId),
       operationKind = Value(operationKind),
       createdAt = Value(createdAt);
  static Insertable<OutboxOperationRow> custom({
    Expression<String>? operationId,
    Expression<String>? ownerId,
    Expression<String>? deviceId,
    Expression<String>? aggregateType,
    Expression<String>? aggregateId,
    Expression<String>? operationKind,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (ownerId != null) 'owner_id': ownerId,
      if (deviceId != null) 'device_id': deviceId,
      if (aggregateType != null) 'aggregate_type': aggregateType,
      if (aggregateId != null) 'aggregate_id': aggregateId,
      if (operationKind != null) 'operation_kind': operationKind,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxOperationsCompanion copyWith({
    Value<String>? operationId,
    Value<String>? ownerId,
    Value<String>? deviceId,
    Value<String>? aggregateType,
    Value<String>? aggregateId,
    Value<String>? operationKind,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return OutboxOperationsCompanion(
      operationId: operationId ?? this.operationId,
      ownerId: ownerId ?? this.ownerId,
      deviceId: deviceId ?? this.deviceId,
      aggregateType: aggregateType ?? this.aggregateType,
      aggregateId: aggregateId ?? this.aggregateId,
      operationKind: operationKind ?? this.operationKind,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (aggregateType.present) {
      map['aggregate_type'] = Variable<String>(aggregateType.value);
    }
    if (aggregateId.present) {
      map['aggregate_id'] = Variable<String>(aggregateId.value);
    }
    if (operationKind.present) {
      map['operation_kind'] = Variable<String>(operationKind.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOperationsCompanion(')
          ..write('operationId: $operationId, ')
          ..write('ownerId: $ownerId, ')
          ..write('deviceId: $deviceId, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('operationKind: $operationKind, ')
          ..write('createdAt: $createdAt, ')
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
  late final $ObservationsTable observations = $ObservationsTable(this);
  late final $LocalAssetsTable localAssets = $LocalAssetsTable(this);
  late final $OutboxOperationsTable outboxOperations = $OutboxOperationsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    principals,
    deviceIdentities,
    observations,
    localAssets,
    outboxOperations,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'observations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('local_assets', kind: UpdateKind.delete)],
    ),
  ]);
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

  static MultiTypedResultKey<$ObservationsTable, List<Observation>>
  _observationsRefsTable(_$CognoteDatabase db) => MultiTypedResultKey.fromTable(
    db.observations,
    aliasName: 'principals__id__observations__owner_id',
  );

  $$ObservationsTableProcessedTableManager get observationsRefs {
    final manager = $$ObservationsTableTableManager(
      $_db,
      $_db.observations,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_observationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OutboxOperationsTable, List<OutboxOperationRow>>
  _outboxOperationsRefsTable(_$CognoteDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.outboxOperations,
        aliasName: 'principals__id__outbox_operations__owner_id',
      );

  $$OutboxOperationsTableProcessedTableManager get outboxOperationsRefs {
    final manager = $$OutboxOperationsTableTableManager(
      $_db,
      $_db.outboxOperations,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _outboxOperationsRefsTable($_db),
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

  Expression<bool> observationsRefs(
    Expression<bool> Function($$ObservationsTableFilterComposer f) f,
  ) {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableFilterComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> outboxOperationsRefs(
    Expression<bool> Function($$OutboxOperationsTableFilterComposer f) f,
  ) {
    final $$OutboxOperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outboxOperations,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutboxOperationsTableFilterComposer(
            $db: $db,
            $table: $db.outboxOperations,
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

  Expression<T> observationsRefs<T extends Object>(
    Expression<T> Function($$ObservationsTableAnnotationComposer a) f,
  ) {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableAnnotationComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> outboxOperationsRefs<T extends Object>(
    Expression<T> Function($$OutboxOperationsTableAnnotationComposer a) f,
  ) {
    final $$OutboxOperationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outboxOperations,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutboxOperationsTableAnnotationComposer(
            $db: $db,
            $table: $db.outboxOperations,
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
          PrefetchHooks Function({
            bool deviceIdentitiesRefs,
            bool observationsRefs,
            bool outboxOperationsRefs,
          })
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
          prefetchHooksCallback:
              ({
                deviceIdentitiesRefs = false,
                observationsRefs = false,
                outboxOperationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (deviceIdentitiesRefs) db.deviceIdentities,
                    if (observationsRefs) db.observations,
                    if (outboxOperationsRefs) db.outboxOperations,
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
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.principalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (observationsRefs)
                        await $_getPrefetchedData<
                          Principal,
                          $PrincipalsTable,
                          Observation
                        >(
                          currentTable: table,
                          referencedTable: $$PrincipalsTableReferences
                              ._observationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PrincipalsTableReferences(
                                db,
                                table,
                                p0,
                              ).observationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (outboxOperationsRefs)
                        await $_getPrefetchedData<
                          Principal,
                          $PrincipalsTable,
                          OutboxOperationRow
                        >(
                          currentTable: table,
                          referencedTable: $$PrincipalsTableReferences
                              ._outboxOperationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PrincipalsTableReferences(
                                db,
                                table,
                                p0,
                              ).outboxOperationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
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
      PrefetchHooks Function({
        bool deviceIdentitiesRefs,
        bool observationsRefs,
        bool outboxOperationsRefs,
      })
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

  static MultiTypedResultKey<$ObservationsTable, List<Observation>>
  _observationsRefsTable(_$CognoteDatabase db) => MultiTypedResultKey.fromTable(
    db.observations,
    aliasName: 'device_identities__id__observations__created_by_device_id',
  );

  $$ObservationsTableProcessedTableManager get observationsRefs {
    final manager = $$ObservationsTableTableManager($_db, $_db.observations)
        .filter(
          (f) => f.createdByDeviceId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_observationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OutboxOperationsTable, List<OutboxOperationRow>>
  _outboxOperationsRefsTable(_$CognoteDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.outboxOperations,
        aliasName: 'device_identities__id__outbox_operations__device_id',
      );

  $$OutboxOperationsTableProcessedTableManager get outboxOperationsRefs {
    final manager = $$OutboxOperationsTableTableManager(
      $_db,
      $_db.outboxOperations,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _outboxOperationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  Expression<bool> observationsRefs(
    Expression<bool> Function($$ObservationsTableFilterComposer f) f,
  ) {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.createdByDeviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableFilterComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> outboxOperationsRefs(
    Expression<bool> Function($$OutboxOperationsTableFilterComposer f) f,
  ) {
    final $$OutboxOperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outboxOperations,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutboxOperationsTableFilterComposer(
            $db: $db,
            $table: $db.outboxOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  Expression<T> observationsRefs<T extends Object>(
    Expression<T> Function($$ObservationsTableAnnotationComposer a) f,
  ) {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.createdByDeviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableAnnotationComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> outboxOperationsRefs<T extends Object>(
    Expression<T> Function($$OutboxOperationsTableAnnotationComposer a) f,
  ) {
    final $$OutboxOperationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outboxOperations,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutboxOperationsTableAnnotationComposer(
            $db: $db,
            $table: $db.outboxOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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
          PrefetchHooks Function({
            bool principalId,
            bool observationsRefs,
            bool outboxOperationsRefs,
          })
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
          prefetchHooksCallback:
              ({
                principalId = false,
                observationsRefs = false,
                outboxOperationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (observationsRefs) db.observations,
                    if (outboxOperationsRefs) db.outboxOperations,
                  ],
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
                    return [
                      if (observationsRefs)
                        await $_getPrefetchedData<
                          DeviceIdentity,
                          $DeviceIdentitiesTable,
                          Observation
                        >(
                          currentTable: table,
                          referencedTable: $$DeviceIdentitiesTableReferences
                              ._observationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DeviceIdentitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).observationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.createdByDeviceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (outboxOperationsRefs)
                        await $_getPrefetchedData<
                          DeviceIdentity,
                          $DeviceIdentitiesTable,
                          OutboxOperationRow
                        >(
                          currentTable: table,
                          referencedTable: $$DeviceIdentitiesTableReferences
                              ._outboxOperationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DeviceIdentitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).outboxOperationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deviceId == item.id,
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
      PrefetchHooks Function({
        bool principalId,
        bool observationsRefs,
        bool outboxOperationsRefs,
      })
    >;
typedef $$ObservationsTableCreateCompanionBuilder =
    ObservationsCompanion Function({
      required String id,
      required String ownerId,
      required String inputType,
      Value<String?> rawText,
      required DateTime capturedAt,
      required int timezoneOffset,
      required String privacyLevel,
      required String cloudAiPolicy,
      required String syncPolicy,
      required String createdByDeviceId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverRevision,
      Value<int> rowid,
    });
typedef $$ObservationsTableUpdateCompanionBuilder =
    ObservationsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> inputType,
      Value<String?> rawText,
      Value<DateTime> capturedAt,
      Value<int> timezoneOffset,
      Value<String> privacyLevel,
      Value<String> cloudAiPolicy,
      Value<String> syncPolicy,
      Value<String> createdByDeviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverRevision,
      Value<int> rowid,
    });

final class $$ObservationsTableReferences
    extends BaseReferences<_$CognoteDatabase, $ObservationsTable, Observation> {
  $$ObservationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PrincipalsTable _ownerIdTable(_$CognoteDatabase db) =>
      db.principals.createAlias('observations__owner_id__principals__id');

  $$PrincipalsTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$PrincipalsTableTableManager(
      $_db,
      $_db.principals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DeviceIdentitiesTable _createdByDeviceIdTable(_$CognoteDatabase db) =>
      db.deviceIdentities.createAlias(
        'observations__created_by_device_id__device_identities__id',
      );

  $$DeviceIdentitiesTableProcessedTableManager get createdByDeviceId {
    final $_column = $_itemColumn<String>('created_by_device_id')!;

    final manager = $$DeviceIdentitiesTableTableManager(
      $_db,
      $_db.deviceIdentities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByDeviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LocalAssetsTable, List<LocalAsset>>
  _localAssetsRefsTable(_$CognoteDatabase db) => MultiTypedResultKey.fromTable(
    db.localAssets,
    aliasName: 'observations__id__local_assets__observation_id',
  );

  $$LocalAssetsTableProcessedTableManager get localAssetsRefs {
    final manager = $$LocalAssetsTableTableManager(
      $_db,
      $_db.localAssets,
    ).filter((f) => f.observationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localAssetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ObservationsTableFilterComposer
    extends Composer<_$CognoteDatabase, $ObservationsTable> {
  $$ObservationsTableFilterComposer({
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

  ColumnFilters<String> get inputType => $composableBuilder(
    column: $table.inputType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timezoneOffset => $composableBuilder(
    column: $table.timezoneOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacyLevel => $composableBuilder(
    column: $table.privacyLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudAiPolicy => $composableBuilder(
    column: $table.cloudAiPolicy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncPolicy => $composableBuilder(
    column: $table.syncPolicy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnFilters(column),
  );

  $$PrincipalsTableFilterComposer get ownerId {
    final $$PrincipalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
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

  $$DeviceIdentitiesTableFilterComposer get createdByDeviceId {
    final $$DeviceIdentitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByDeviceId,
      referencedTable: $db.deviceIdentities,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  Expression<bool> localAssetsRefs(
    Expression<bool> Function($$LocalAssetsTableFilterComposer f) f,
  ) {
    final $$LocalAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localAssets,
      getReferencedColumn: (t) => t.observationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalAssetsTableFilterComposer(
            $db: $db,
            $table: $db.localAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObservationsTableOrderingComposer
    extends Composer<_$CognoteDatabase, $ObservationsTable> {
  $$ObservationsTableOrderingComposer({
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

  ColumnOrderings<String> get inputType => $composableBuilder(
    column: $table.inputType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timezoneOffset => $composableBuilder(
    column: $table.timezoneOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacyLevel => $composableBuilder(
    column: $table.privacyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudAiPolicy => $composableBuilder(
    column: $table.cloudAiPolicy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncPolicy => $composableBuilder(
    column: $table.syncPolicy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnOrderings(column),
  );

  $$PrincipalsTableOrderingComposer get ownerId {
    final $$PrincipalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
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

  $$DeviceIdentitiesTableOrderingComposer get createdByDeviceId {
    final $$DeviceIdentitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByDeviceId,
      referencedTable: $db.deviceIdentities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceIdentitiesTableOrderingComposer(
            $db: $db,
            $table: $db.deviceIdentities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObservationsTableAnnotationComposer
    extends Composer<_$CognoteDatabase, $ObservationsTable> {
  $$ObservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get inputType =>
      $composableBuilder(column: $table.inputType, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timezoneOffset => $composableBuilder(
    column: $table.timezoneOffset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get privacyLevel => $composableBuilder(
    column: $table.privacyLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cloudAiPolicy => $composableBuilder(
    column: $table.cloudAiPolicy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncPolicy => $composableBuilder(
    column: $table.syncPolicy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => column,
  );

  $$PrincipalsTableAnnotationComposer get ownerId {
    final $$PrincipalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
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

  $$DeviceIdentitiesTableAnnotationComposer get createdByDeviceId {
    final $$DeviceIdentitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByDeviceId,
      referencedTable: $db.deviceIdentities,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  Expression<T> localAssetsRefs<T extends Object>(
    Expression<T> Function($$LocalAssetsTableAnnotationComposer a) f,
  ) {
    final $$LocalAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localAssets,
      getReferencedColumn: (t) => t.observationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.localAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObservationsTableTableManager
    extends
        RootTableManager<
          _$CognoteDatabase,
          $ObservationsTable,
          Observation,
          $$ObservationsTableFilterComposer,
          $$ObservationsTableOrderingComposer,
          $$ObservationsTableAnnotationComposer,
          $$ObservationsTableCreateCompanionBuilder,
          $$ObservationsTableUpdateCompanionBuilder,
          (Observation, $$ObservationsTableReferences),
          Observation,
          PrefetchHooks Function({
            bool ownerId,
            bool createdByDeviceId,
            bool localAssetsRefs,
          })
        > {
  $$ObservationsTableTableManager(
    _$CognoteDatabase db,
    $ObservationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObservationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObservationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObservationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> inputType = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<int> timezoneOffset = const Value.absent(),
                Value<String> privacyLevel = const Value.absent(),
                Value<String> cloudAiPolicy = const Value.absent(),
                Value<String> syncPolicy = const Value.absent(),
                Value<String> createdByDeviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservationsCompanion(
                id: id,
                ownerId: ownerId,
                inputType: inputType,
                rawText: rawText,
                capturedAt: capturedAt,
                timezoneOffset: timezoneOffset,
                privacyLevel: privacyLevel,
                cloudAiPolicy: cloudAiPolicy,
                syncPolicy: syncPolicy,
                createdByDeviceId: createdByDeviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverRevision: serverRevision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String inputType,
                Value<String?> rawText = const Value.absent(),
                required DateTime capturedAt,
                required int timezoneOffset,
                required String privacyLevel,
                required String cloudAiPolicy,
                required String syncPolicy,
                required String createdByDeviceId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservationsCompanion.insert(
                id: id,
                ownerId: ownerId,
                inputType: inputType,
                rawText: rawText,
                capturedAt: capturedAt,
                timezoneOffset: timezoneOffset,
                privacyLevel: privacyLevel,
                cloudAiPolicy: cloudAiPolicy,
                syncPolicy: syncPolicy,
                createdByDeviceId: createdByDeviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverRevision: serverRevision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ObservationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ownerId = false,
                createdByDeviceId = false,
                localAssetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (localAssetsRefs) db.localAssets,
                  ],
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
                        if (ownerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ownerId,
                                    referencedTable:
                                        $$ObservationsTableReferences
                                            ._ownerIdTable(db),
                                    referencedColumn:
                                        $$ObservationsTableReferences
                                            ._ownerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (createdByDeviceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.createdByDeviceId,
                                    referencedTable:
                                        $$ObservationsTableReferences
                                            ._createdByDeviceIdTable(db),
                                    referencedColumn:
                                        $$ObservationsTableReferences
                                            ._createdByDeviceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (localAssetsRefs)
                        await $_getPrefetchedData<
                          Observation,
                          $ObservationsTable,
                          LocalAsset
                        >(
                          currentTable: table,
                          referencedTable: $$ObservationsTableReferences
                              ._localAssetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObservationsTableReferences(
                                db,
                                table,
                                p0,
                              ).localAssetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.observationId == item.id,
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

typedef $$ObservationsTableProcessedTableManager =
    ProcessedTableManager<
      _$CognoteDatabase,
      $ObservationsTable,
      Observation,
      $$ObservationsTableFilterComposer,
      $$ObservationsTableOrderingComposer,
      $$ObservationsTableAnnotationComposer,
      $$ObservationsTableCreateCompanionBuilder,
      $$ObservationsTableUpdateCompanionBuilder,
      (Observation, $$ObservationsTableReferences),
      Observation,
      PrefetchHooks Function({
        bool ownerId,
        bool createdByDeviceId,
        bool localAssetsRefs,
      })
    >;
typedef $$LocalAssetsTableCreateCompanionBuilder =
    LocalAssetsCompanion Function({
      required String id,
      required String observationId,
      required String localUri,
      Value<String?> analysisDerivativeUri,
      required bool localOriginalPresent,
      required String mimeType,
      required int bytes,
      Value<int?> width,
      Value<int?> height,
      required String sha256,
      required bool exifRemoved,
      required String uploadState,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalAssetsTableUpdateCompanionBuilder =
    LocalAssetsCompanion Function({
      Value<String> id,
      Value<String> observationId,
      Value<String> localUri,
      Value<String?> analysisDerivativeUri,
      Value<bool> localOriginalPresent,
      Value<String> mimeType,
      Value<int> bytes,
      Value<int?> width,
      Value<int?> height,
      Value<String> sha256,
      Value<bool> exifRemoved,
      Value<String> uploadState,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$LocalAssetsTableReferences
    extends BaseReferences<_$CognoteDatabase, $LocalAssetsTable, LocalAsset> {
  $$LocalAssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ObservationsTable _observationIdTable(_$CognoteDatabase db) => db
      .observations
      .createAlias('local_assets__observation_id__observations__id');

  $$ObservationsTableProcessedTableManager get observationId {
    final $_column = $_itemColumn<String>('observation_id')!;

    final manager = $$ObservationsTableTableManager(
      $_db,
      $_db.observations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_observationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalAssetsTableFilterComposer
    extends Composer<_$CognoteDatabase, $LocalAssetsTable> {
  $$LocalAssetsTableFilterComposer({
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

  ColumnFilters<String> get localUri => $composableBuilder(
    column: $table.localUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisDerivativeUri => $composableBuilder(
    column: $table.analysisDerivativeUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get localOriginalPresent => $composableBuilder(
    column: $table.localOriginalPresent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get exifRemoved => $composableBuilder(
    column: $table.exifRemoved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ObservationsTableFilterComposer get observationId {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableFilterComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalAssetsTableOrderingComposer
    extends Composer<_$CognoteDatabase, $LocalAssetsTable> {
  $$LocalAssetsTableOrderingComposer({
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

  ColumnOrderings<String> get localUri => $composableBuilder(
    column: $table.localUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisDerivativeUri => $composableBuilder(
    column: $table.analysisDerivativeUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get localOriginalPresent => $composableBuilder(
    column: $table.localOriginalPresent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get exifRemoved => $composableBuilder(
    column: $table.exifRemoved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ObservationsTableOrderingComposer get observationId {
    final $$ObservationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableOrderingComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalAssetsTableAnnotationComposer
    extends Composer<_$CognoteDatabase, $LocalAssetsTable> {
  $$LocalAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localUri =>
      $composableBuilder(column: $table.localUri, builder: (column) => column);

  GeneratedColumn<String> get analysisDerivativeUri => $composableBuilder(
    column: $table.analysisDerivativeUri,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get localOriginalPresent => $composableBuilder(
    column: $table.localOriginalPresent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<bool> get exifRemoved => $composableBuilder(
    column: $table.exifRemoved,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ObservationsTableAnnotationComposer get observationId {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableAnnotationComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalAssetsTableTableManager
    extends
        RootTableManager<
          _$CognoteDatabase,
          $LocalAssetsTable,
          LocalAsset,
          $$LocalAssetsTableFilterComposer,
          $$LocalAssetsTableOrderingComposer,
          $$LocalAssetsTableAnnotationComposer,
          $$LocalAssetsTableCreateCompanionBuilder,
          $$LocalAssetsTableUpdateCompanionBuilder,
          (LocalAsset, $$LocalAssetsTableReferences),
          LocalAsset,
          PrefetchHooks Function({bool observationId})
        > {
  $$LocalAssetsTableTableManager(_$CognoteDatabase db, $LocalAssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> observationId = const Value.absent(),
                Value<String> localUri = const Value.absent(),
                Value<String?> analysisDerivativeUri = const Value.absent(),
                Value<bool> localOriginalPresent = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> bytes = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<bool> exifRemoved = const Value.absent(),
                Value<String> uploadState = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssetsCompanion(
                id: id,
                observationId: observationId,
                localUri: localUri,
                analysisDerivativeUri: analysisDerivativeUri,
                localOriginalPresent: localOriginalPresent,
                mimeType: mimeType,
                bytes: bytes,
                width: width,
                height: height,
                sha256: sha256,
                exifRemoved: exifRemoved,
                uploadState: uploadState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String observationId,
                required String localUri,
                Value<String?> analysisDerivativeUri = const Value.absent(),
                required bool localOriginalPresent,
                required String mimeType,
                required int bytes,
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required String sha256,
                required bool exifRemoved,
                required String uploadState,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalAssetsCompanion.insert(
                id: id,
                observationId: observationId,
                localUri: localUri,
                analysisDerivativeUri: analysisDerivativeUri,
                localOriginalPresent: localOriginalPresent,
                mimeType: mimeType,
                bytes: bytes,
                width: width,
                height: height,
                sha256: sha256,
                exifRemoved: exifRemoved,
                uploadState: uploadState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalAssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({observationId = false}) {
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
                    if (observationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.observationId,
                                referencedTable: $$LocalAssetsTableReferences
                                    ._observationIdTable(db),
                                referencedColumn: $$LocalAssetsTableReferences
                                    ._observationIdTable(db)
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

typedef $$LocalAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$CognoteDatabase,
      $LocalAssetsTable,
      LocalAsset,
      $$LocalAssetsTableFilterComposer,
      $$LocalAssetsTableOrderingComposer,
      $$LocalAssetsTableAnnotationComposer,
      $$LocalAssetsTableCreateCompanionBuilder,
      $$LocalAssetsTableUpdateCompanionBuilder,
      (LocalAsset, $$LocalAssetsTableReferences),
      LocalAsset,
      PrefetchHooks Function({bool observationId})
    >;
typedef $$OutboxOperationsTableCreateCompanionBuilder =
    OutboxOperationsCompanion Function({
      required String operationId,
      required String ownerId,
      required String deviceId,
      required String aggregateType,
      required String aggregateId,
      required String operationKind,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$OutboxOperationsTableUpdateCompanionBuilder =
    OutboxOperationsCompanion Function({
      Value<String> operationId,
      Value<String> ownerId,
      Value<String> deviceId,
      Value<String> aggregateType,
      Value<String> aggregateId,
      Value<String> operationKind,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$OutboxOperationsTableReferences
    extends
        BaseReferences<
          _$CognoteDatabase,
          $OutboxOperationsTable,
          OutboxOperationRow
        > {
  $$OutboxOperationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PrincipalsTable _ownerIdTable(_$CognoteDatabase db) =>
      db.principals.createAlias('outbox_operations__owner_id__principals__id');

  $$PrincipalsTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$PrincipalsTableTableManager(
      $_db,
      $_db.principals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DeviceIdentitiesTable _deviceIdTable(_$CognoteDatabase db) => db
      .deviceIdentities
      .createAlias('outbox_operations__device_id__device_identities__id');

  $$DeviceIdentitiesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DeviceIdentitiesTableTableManager(
      $_db,
      $_db.deviceIdentities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OutboxOperationsTableFilterComposer
    extends Composer<_$CognoteDatabase, $OutboxOperationsTable> {
  $$OutboxOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationKind => $composableBuilder(
    column: $table.operationKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PrincipalsTableFilterComposer get ownerId {
    final $$PrincipalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
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

  $$DeviceIdentitiesTableFilterComposer get deviceId {
    final $$DeviceIdentitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.deviceIdentities,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$OutboxOperationsTableOrderingComposer
    extends Composer<_$CognoteDatabase, $OutboxOperationsTable> {
  $$OutboxOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationKind => $composableBuilder(
    column: $table.operationKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PrincipalsTableOrderingComposer get ownerId {
    final $$PrincipalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
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

  $$DeviceIdentitiesTableOrderingComposer get deviceId {
    final $$DeviceIdentitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.deviceIdentities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceIdentitiesTableOrderingComposer(
            $db: $db,
            $table: $db.deviceIdentities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutboxOperationsTableAnnotationComposer
    extends Composer<_$CognoteDatabase, $OutboxOperationsTable> {
  $$OutboxOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operationKind => $composableBuilder(
    column: $table.operationKind,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PrincipalsTableAnnotationComposer get ownerId {
    final $$PrincipalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
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

  $$DeviceIdentitiesTableAnnotationComposer get deviceId {
    final $$DeviceIdentitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.deviceIdentities,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$OutboxOperationsTableTableManager
    extends
        RootTableManager<
          _$CognoteDatabase,
          $OutboxOperationsTable,
          OutboxOperationRow,
          $$OutboxOperationsTableFilterComposer,
          $$OutboxOperationsTableOrderingComposer,
          $$OutboxOperationsTableAnnotationComposer,
          $$OutboxOperationsTableCreateCompanionBuilder,
          $$OutboxOperationsTableUpdateCompanionBuilder,
          (OutboxOperationRow, $$OutboxOperationsTableReferences),
          OutboxOperationRow,
          PrefetchHooks Function({bool ownerId, bool deviceId})
        > {
  $$OutboxOperationsTableTableManager(
    _$CognoteDatabase db,
    $OutboxOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxOperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> aggregateType = const Value.absent(),
                Value<String> aggregateId = const Value.absent(),
                Value<String> operationKind = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxOperationsCompanion(
                operationId: operationId,
                ownerId: ownerId,
                deviceId: deviceId,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                operationKind: operationKind,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String ownerId,
                required String deviceId,
                required String aggregateType,
                required String aggregateId,
                required String operationKind,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OutboxOperationsCompanion.insert(
                operationId: operationId,
                ownerId: ownerId,
                deviceId: deviceId,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                operationKind: operationKind,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OutboxOperationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ownerId = false, deviceId = false}) {
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
                    if (ownerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ownerId,
                                referencedTable:
                                    $$OutboxOperationsTableReferences
                                        ._ownerIdTable(db),
                                referencedColumn:
                                    $$OutboxOperationsTableReferences
                                        ._ownerIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (deviceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deviceId,
                                referencedTable:
                                    $$OutboxOperationsTableReferences
                                        ._deviceIdTable(db),
                                referencedColumn:
                                    $$OutboxOperationsTableReferences
                                        ._deviceIdTable(db)
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

typedef $$OutboxOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$CognoteDatabase,
      $OutboxOperationsTable,
      OutboxOperationRow,
      $$OutboxOperationsTableFilterComposer,
      $$OutboxOperationsTableOrderingComposer,
      $$OutboxOperationsTableAnnotationComposer,
      $$OutboxOperationsTableCreateCompanionBuilder,
      $$OutboxOperationsTableUpdateCompanionBuilder,
      (OutboxOperationRow, $$OutboxOperationsTableReferences),
      OutboxOperationRow,
      PrefetchHooks Function({bool ownerId, bool deviceId})
    >;

class $CognoteDatabaseManager {
  final _$CognoteDatabase _db;
  $CognoteDatabaseManager(this._db);
  $$PrincipalsTableTableManager get principals =>
      $$PrincipalsTableTableManager(_db, _db.principals);
  $$DeviceIdentitiesTableTableManager get deviceIdentities =>
      $$DeviceIdentitiesTableTableManager(_db, _db.deviceIdentities);
  $$ObservationsTableTableManager get observations =>
      $$ObservationsTableTableManager(_db, _db.observations);
  $$LocalAssetsTableTableManager get localAssets =>
      $$LocalAssetsTableTableManager(_db, _db.localAssets);
  $$OutboxOperationsTableTableManager get outboxOperations =>
      $$OutboxOperationsTableTableManager(_db, _db.outboxOperations);
}
