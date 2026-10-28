// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class RecyclingPoints extends Table
    with TableInfo<RecyclingPoints, RecyclingPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  RecyclingPoints(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _occupancyMeta = const VerificationMeta(
    'occupancy',
  );
  late final GeneratedColumn<int> occupancy = GeneratedColumn<int>(
    'occupancy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (typeof(occupancy) = \'integer\' AND occupancy BETWEEN 0 AND 100)',
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _isDemoMeta = const VerificationMeta('isDemo');
  late final GeneratedColumn<int> isDemo = GeneratedColumn<int>(
    'is_demo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (is_demo IN (0, 1))',
    defaultValue: const CustomExpression('1'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    occupancy,
    latitude,
    longitude,
    isDemo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recycling_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecyclingPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('occupancy')) {
      context.handle(
        _occupancyMeta,
        occupancy.isAcceptableOrUnknown(data['occupancy']!, _occupancyMeta),
      );
    } else if (isInserting) {
      context.missing(_occupancyMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('is_demo')) {
      context.handle(
        _isDemoMeta,
        isDemo.isAcceptableOrUnknown(data['is_demo']!, _isDemoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecyclingPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecyclingPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      occupancy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occupancy'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      isDemo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_demo'],
      )!,
    );
  }

  @override
  RecyclingPoints createAlias(String alias) {
    return RecyclingPoints(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class RecyclingPoint extends DataClass implements Insertable<RecyclingPoint> {
  final String id;
  final String name;
  final String description;
  final int occupancy;
  final double? latitude;
  final double? longitude;
  final int isDemo;
  const RecyclingPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.occupancy,
    this.latitude,
    this.longitude,
    required this.isDemo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['occupancy'] = Variable<int>(occupancy);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['is_demo'] = Variable<int>(isDemo);
    return map;
  }

  RecyclingPointsCompanion toCompanion(bool nullToAbsent) {
    return RecyclingPointsCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      occupancy: Value(occupancy),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      isDemo: Value(isDemo),
    );
  }

  factory RecyclingPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecyclingPoint(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      occupancy: serializer.fromJson<int>(json['occupancy']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      isDemo: serializer.fromJson<int>(json['is_demo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'occupancy': serializer.toJson<int>(occupancy),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'is_demo': serializer.toJson<int>(isDemo),
    };
  }

  RecyclingPoint copyWith({
    String? id,
    String? name,
    String? description,
    int? occupancy,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    int? isDemo,
  }) => RecyclingPoint(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    occupancy: occupancy ?? this.occupancy,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    isDemo: isDemo ?? this.isDemo,
  );
  RecyclingPoint copyWithCompanion(RecyclingPointsCompanion data) {
    return RecyclingPoint(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      occupancy: data.occupancy.present ? data.occupancy.value : this.occupancy,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      isDemo: data.isDemo.present ? data.isDemo.value : this.isDemo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecyclingPoint(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('occupancy: $occupancy, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('isDemo: $isDemo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    occupancy,
    latitude,
    longitude,
    isDemo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecyclingPoint &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.occupancy == this.occupancy &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.isDemo == this.isDemo);
}

class RecyclingPointsCompanion extends UpdateCompanion<RecyclingPoint> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<int> occupancy;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> isDemo;
  final Value<int> rowid;
  const RecyclingPointsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.occupancy = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.isDemo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecyclingPointsCompanion.insert({
    required String id,
    required String name,
    required String description,
    required int occupancy,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.isDemo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       description = Value(description),
       occupancy = Value(occupancy);
  static Insertable<RecyclingPoint> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? occupancy,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? isDemo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (occupancy != null) 'occupancy': occupancy,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (isDemo != null) 'is_demo': isDemo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecyclingPointsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<int>? occupancy,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<int>? isDemo,
    Value<int>? rowid,
  }) {
    return RecyclingPointsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      occupancy: occupancy ?? this.occupancy,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDemo: isDemo ?? this.isDemo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (occupancy.present) {
      map['occupancy'] = Variable<int>(occupancy.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (isDemo.present) {
      map['is_demo'] = Variable<int>(isDemo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecyclingPointsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('occupancy: $occupancy, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('isDemo: $isDemo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class RecyclingRecords extends Table
    with TableInfo<RecyclingRecords, RecyclingRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  RecyclingRecords(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _pointIdMeta = const VerificationMeta(
    'pointId',
  );
  late final GeneratedColumn<String> pointId = GeneratedColumn<String>(
    'point_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES recycling_points(id)',
  );
  static const VerificationMeta _materialMeta = const VerificationMeta(
    'material',
  );
  late final GeneratedColumn<String> material = GeneratedColumn<String>(
    'material',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (material IN (\'pet\', \'aluminum\'))',
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (typeof(quantity) = \'integer\' AND quantity BETWEEN 1 AND 100)',
  );
  static const VerificationMeta _unitPointsMeta = const VerificationMeta(
    'unitPoints',
  );
  late final GeneratedColumn<int> unitPoints = GeneratedColumn<int>(
    'unit_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (typeof(unit_points) = \'integer\' AND unit_points > 0)',
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'\' CHECK (length(note) <= 200)',
    defaultValue: const CustomExpression('\'\''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pointId,
    material,
    quantity,
    unitPoints,
    occurredAt,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recycling_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecyclingRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('point_id')) {
      context.handle(
        _pointIdMeta,
        pointId.isAcceptableOrUnknown(data['point_id']!, _pointIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pointIdMeta);
    }
    if (data.containsKey('material')) {
      context.handle(
        _materialMeta,
        material.isAcceptableOrUnknown(data['material']!, _materialMeta),
      );
    } else if (isInserting) {
      context.missing(_materialMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_points')) {
      context.handle(
        _unitPointsMeta,
        unitPoints.isAcceptableOrUnknown(data['unit_points']!, _unitPointsMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPointsMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
  RecyclingRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecyclingRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pointId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}point_id'],
      )!,
      material: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_points'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  RecyclingRecords createAlias(String alias) {
    return RecyclingRecords(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class RecyclingRecord extends DataClass implements Insertable<RecyclingRecord> {
  final String id;
  final String pointId;
  final String material;
  final int quantity;
  final int unitPoints;
  final int occurredAt;
  final String note;
  final int createdAt;
  final int updatedAt;
  const RecyclingRecord({
    required this.id,
    required this.pointId,
    required this.material,
    required this.quantity,
    required this.unitPoints,
    required this.occurredAt,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['point_id'] = Variable<String>(pointId);
    map['material'] = Variable<String>(material);
    map['quantity'] = Variable<int>(quantity);
    map['unit_points'] = Variable<int>(unitPoints);
    map['occurred_at'] = Variable<int>(occurredAt);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  RecyclingRecordsCompanion toCompanion(bool nullToAbsent) {
    return RecyclingRecordsCompanion(
      id: Value(id),
      pointId: Value(pointId),
      material: Value(material),
      quantity: Value(quantity),
      unitPoints: Value(unitPoints),
      occurredAt: Value(occurredAt),
      note: Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RecyclingRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecyclingRecord(
      id: serializer.fromJson<String>(json['id']),
      pointId: serializer.fromJson<String>(json['point_id']),
      material: serializer.fromJson<String>(json['material']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPoints: serializer.fromJson<int>(json['unit_points']),
      occurredAt: serializer.fromJson<int>(json['occurred_at']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'point_id': serializer.toJson<String>(pointId),
      'material': serializer.toJson<String>(material),
      'quantity': serializer.toJson<int>(quantity),
      'unit_points': serializer.toJson<int>(unitPoints),
      'occurred_at': serializer.toJson<int>(occurredAt),
      'note': serializer.toJson<String>(note),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  RecyclingRecord copyWith({
    String? id,
    String? pointId,
    String? material,
    int? quantity,
    int? unitPoints,
    int? occurredAt,
    String? note,
    int? createdAt,
    int? updatedAt,
  }) => RecyclingRecord(
    id: id ?? this.id,
    pointId: pointId ?? this.pointId,
    material: material ?? this.material,
    quantity: quantity ?? this.quantity,
    unitPoints: unitPoints ?? this.unitPoints,
    occurredAt: occurredAt ?? this.occurredAt,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RecyclingRecord copyWithCompanion(RecyclingRecordsCompanion data) {
    return RecyclingRecord(
      id: data.id.present ? data.id.value : this.id,
      pointId: data.pointId.present ? data.pointId.value : this.pointId,
      material: data.material.present ? data.material.value : this.material,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPoints: data.unitPoints.present
          ? data.unitPoints.value
          : this.unitPoints,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecyclingRecord(')
          ..write('id: $id, ')
          ..write('pointId: $pointId, ')
          ..write('material: $material, ')
          ..write('quantity: $quantity, ')
          ..write('unitPoints: $unitPoints, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pointId,
    material,
    quantity,
    unitPoints,
    occurredAt,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecyclingRecord &&
          other.id == this.id &&
          other.pointId == this.pointId &&
          other.material == this.material &&
          other.quantity == this.quantity &&
          other.unitPoints == this.unitPoints &&
          other.occurredAt == this.occurredAt &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecyclingRecordsCompanion extends UpdateCompanion<RecyclingRecord> {
  final Value<String> id;
  final Value<String> pointId;
  final Value<String> material;
  final Value<int> quantity;
  final Value<int> unitPoints;
  final Value<int> occurredAt;
  final Value<String> note;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const RecyclingRecordsCompanion({
    this.id = const Value.absent(),
    this.pointId = const Value.absent(),
    this.material = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPoints = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecyclingRecordsCompanion.insert({
    required String id,
    required String pointId,
    required String material,
    required int quantity,
    required int unitPoints,
    required int occurredAt,
    this.note = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pointId = Value(pointId),
       material = Value(material),
       quantity = Value(quantity),
       unitPoints = Value(unitPoints),
       occurredAt = Value(occurredAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RecyclingRecord> custom({
    Expression<String>? id,
    Expression<String>? pointId,
    Expression<String>? material,
    Expression<int>? quantity,
    Expression<int>? unitPoints,
    Expression<int>? occurredAt,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pointId != null) 'point_id': pointId,
      if (material != null) 'material': material,
      if (quantity != null) 'quantity': quantity,
      if (unitPoints != null) 'unit_points': unitPoints,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecyclingRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? pointId,
    Value<String>? material,
    Value<int>? quantity,
    Value<int>? unitPoints,
    Value<int>? occurredAt,
    Value<String>? note,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return RecyclingRecordsCompanion(
      id: id ?? this.id,
      pointId: pointId ?? this.pointId,
      material: material ?? this.material,
      quantity: quantity ?? this.quantity,
      unitPoints: unitPoints ?? this.unitPoints,
      occurredAt: occurredAt ?? this.occurredAt,
      note: note ?? this.note,
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
    if (pointId.present) {
      map['point_id'] = Variable<String>(pointId.value);
    }
    if (material.present) {
      map['material'] = Variable<String>(material.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPoints.present) {
      map['unit_points'] = Variable<int>(unitPoints.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecyclingRecordsCompanion(')
          ..write('id: $id, ')
          ..write('pointId: $pointId, ')
          ..write('material: $material, ')
          ..write('quantity: $quantity, ')
          ..write('unitPoints: $unitPoints, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Rewards extends Table with TableInfo<Rewards, Reward> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Rewards(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (category IN (\'photocopies\', \'mobile\', \'cafeteria\'))',
  );
  static const VerificationMeta _costPointsMeta = const VerificationMeta(
    'costPoints',
  );
  late final GeneratedColumn<int> costPoints = GeneratedColumn<int>(
    'cost_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (typeof(cost_points) = \'integer\' AND cost_points > 0)',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))',
    defaultValue: const CustomExpression('1'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    category,
    costPoints,
    description,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rewards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reward> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('cost_points')) {
      context.handle(
        _costPointsMeta,
        costPoints.isAcceptableOrUnknown(data['cost_points']!, _costPointsMeta),
      );
    } else if (isInserting) {
      context.missing(_costPointsMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reward map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reward(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      costPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_points'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  Rewards createAlias(String alias) {
    return Rewards(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Reward extends DataClass implements Insertable<Reward> {
  final String id;
  final String title;
  final String category;
  final int costPoints;
  final String description;
  final int isActive;
  const Reward({
    required this.id,
    required this.title,
    required this.category,
    required this.costPoints,
    required this.description,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['cost_points'] = Variable<int>(costPoints);
    map['description'] = Variable<String>(description);
    map['is_active'] = Variable<int>(isActive);
    return map;
  }

  RewardsCompanion toCompanion(bool nullToAbsent) {
    return RewardsCompanion(
      id: Value(id),
      title: Value(title),
      category: Value(category),
      costPoints: Value(costPoints),
      description: Value(description),
      isActive: Value(isActive),
    );
  }

  factory Reward.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reward(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      costPoints: serializer.fromJson<int>(json['cost_points']),
      description: serializer.fromJson<String>(json['description']),
      isActive: serializer.fromJson<int>(json['is_active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'cost_points': serializer.toJson<int>(costPoints),
      'description': serializer.toJson<String>(description),
      'is_active': serializer.toJson<int>(isActive),
    };
  }

  Reward copyWith({
    String? id,
    String? title,
    String? category,
    int? costPoints,
    String? description,
    int? isActive,
  }) => Reward(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    costPoints: costPoints ?? this.costPoints,
    description: description ?? this.description,
    isActive: isActive ?? this.isActive,
  );
  Reward copyWithCompanion(RewardsCompanion data) {
    return Reward(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      costPoints: data.costPoints.present
          ? data.costPoints.value
          : this.costPoints,
      description: data.description.present
          ? data.description.value
          : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reward(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('costPoints: $costPoints, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, category, costPoints, description, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reward &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.costPoints == this.costPoints &&
          other.description == this.description &&
          other.isActive == this.isActive);
}

class RewardsCompanion extends UpdateCompanion<Reward> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> category;
  final Value<int> costPoints;
  final Value<String> description;
  final Value<int> isActive;
  final Value<int> rowid;
  const RewardsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.costPoints = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RewardsCompanion.insert({
    required String id,
    required String title,
    required String category,
    required int costPoints,
    required String description,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       category = Value(category),
       costPoints = Value(costPoints),
       description = Value(description);
  static Insertable<Reward> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<int>? costPoints,
    Expression<String>? description,
    Expression<int>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (costPoints != null) 'cost_points': costPoints,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RewardsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? category,
    Value<int>? costPoints,
    Value<String>? description,
    Value<int>? isActive,
    Value<int>? rowid,
  }) {
    return RewardsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      costPoints: costPoints ?? this.costPoints,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (costPoints.present) {
      map['cost_points'] = Variable<int>(costPoints.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RewardsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('costPoints: $costPoints, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Redemptions extends Table with TableInfo<Redemptions, Redemption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Redemptions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _rewardIdMeta = const VerificationMeta(
    'rewardId',
  );
  late final GeneratedColumn<String> rewardId = GeneratedColumn<String>(
    'reward_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES rewards(id)',
  );
  static const VerificationMeta _titleSnapshotMeta = const VerificationMeta(
    'titleSnapshot',
  );
  late final GeneratedColumn<String> titleSnapshot = GeneratedColumn<String>(
    'title_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _costSnapshotMeta = const VerificationMeta(
    'costSnapshot',
  );
  late final GeneratedColumn<int> costSnapshot = GeneratedColumn<int>(
    'cost_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (typeof(cost_snapshot) = \'integer\' AND cost_snapshot > 0)',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _canceledAtMeta = const VerificationMeta(
    'canceledAt',
  );
  late final GeneratedColumn<int> canceledAt = GeneratedColumn<int>(
    'canceled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationId,
    rewardId,
    titleSnapshot,
    costSnapshot,
    createdAt,
    canceledAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'redemptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Redemption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
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
    if (data.containsKey('reward_id')) {
      context.handle(
        _rewardIdMeta,
        rewardId.isAcceptableOrUnknown(data['reward_id']!, _rewardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rewardIdMeta);
    }
    if (data.containsKey('title_snapshot')) {
      context.handle(
        _titleSnapshotMeta,
        titleSnapshot.isAcceptableOrUnknown(
          data['title_snapshot']!,
          _titleSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_titleSnapshotMeta);
    }
    if (data.containsKey('cost_snapshot')) {
      context.handle(
        _costSnapshotMeta,
        costSnapshot.isAcceptableOrUnknown(
          data['cost_snapshot']!,
          _costSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costSnapshotMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('canceled_at')) {
      context.handle(
        _canceledAtMeta,
        canceledAt.isAcceptableOrUnknown(data['canceled_at']!, _canceledAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Redemption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Redemption(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      rewardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reward_id'],
      )!,
      titleSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_snapshot'],
      )!,
      costSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_snapshot'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      canceledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}canceled_at'],
      ),
    );
  }

  @override
  Redemptions createAlias(String alias) {
    return Redemptions(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Redemption extends DataClass implements Insertable<Redemption> {
  final String id;
  final String operationId;
  final String rewardId;
  final String titleSnapshot;
  final int costSnapshot;
  final int createdAt;
  final int? canceledAt;
  const Redemption({
    required this.id,
    required this.operationId,
    required this.rewardId,
    required this.titleSnapshot,
    required this.costSnapshot,
    required this.createdAt,
    this.canceledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operation_id'] = Variable<String>(operationId);
    map['reward_id'] = Variable<String>(rewardId);
    map['title_snapshot'] = Variable<String>(titleSnapshot);
    map['cost_snapshot'] = Variable<int>(costSnapshot);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || canceledAt != null) {
      map['canceled_at'] = Variable<int>(canceledAt);
    }
    return map;
  }

  RedemptionsCompanion toCompanion(bool nullToAbsent) {
    return RedemptionsCompanion(
      id: Value(id),
      operationId: Value(operationId),
      rewardId: Value(rewardId),
      titleSnapshot: Value(titleSnapshot),
      costSnapshot: Value(costSnapshot),
      createdAt: Value(createdAt),
      canceledAt: canceledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(canceledAt),
    );
  }

  factory Redemption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Redemption(
      id: serializer.fromJson<String>(json['id']),
      operationId: serializer.fromJson<String>(json['operation_id']),
      rewardId: serializer.fromJson<String>(json['reward_id']),
      titleSnapshot: serializer.fromJson<String>(json['title_snapshot']),
      costSnapshot: serializer.fromJson<int>(json['cost_snapshot']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      canceledAt: serializer.fromJson<int?>(json['canceled_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operation_id': serializer.toJson<String>(operationId),
      'reward_id': serializer.toJson<String>(rewardId),
      'title_snapshot': serializer.toJson<String>(titleSnapshot),
      'cost_snapshot': serializer.toJson<int>(costSnapshot),
      'created_at': serializer.toJson<int>(createdAt),
      'canceled_at': serializer.toJson<int?>(canceledAt),
    };
  }

  Redemption copyWith({
    String? id,
    String? operationId,
    String? rewardId,
    String? titleSnapshot,
    int? costSnapshot,
    int? createdAt,
    Value<int?> canceledAt = const Value.absent(),
  }) => Redemption(
    id: id ?? this.id,
    operationId: operationId ?? this.operationId,
    rewardId: rewardId ?? this.rewardId,
    titleSnapshot: titleSnapshot ?? this.titleSnapshot,
    costSnapshot: costSnapshot ?? this.costSnapshot,
    createdAt: createdAt ?? this.createdAt,
    canceledAt: canceledAt.present ? canceledAt.value : this.canceledAt,
  );
  Redemption copyWithCompanion(RedemptionsCompanion data) {
    return Redemption(
      id: data.id.present ? data.id.value : this.id,
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      rewardId: data.rewardId.present ? data.rewardId.value : this.rewardId,
      titleSnapshot: data.titleSnapshot.present
          ? data.titleSnapshot.value
          : this.titleSnapshot,
      costSnapshot: data.costSnapshot.present
          ? data.costSnapshot.value
          : this.costSnapshot,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      canceledAt: data.canceledAt.present
          ? data.canceledAt.value
          : this.canceledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Redemption(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('rewardId: $rewardId, ')
          ..write('titleSnapshot: $titleSnapshot, ')
          ..write('costSnapshot: $costSnapshot, ')
          ..write('createdAt: $createdAt, ')
          ..write('canceledAt: $canceledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operationId,
    rewardId,
    titleSnapshot,
    costSnapshot,
    createdAt,
    canceledAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Redemption &&
          other.id == this.id &&
          other.operationId == this.operationId &&
          other.rewardId == this.rewardId &&
          other.titleSnapshot == this.titleSnapshot &&
          other.costSnapshot == this.costSnapshot &&
          other.createdAt == this.createdAt &&
          other.canceledAt == this.canceledAt);
}

class RedemptionsCompanion extends UpdateCompanion<Redemption> {
  final Value<String> id;
  final Value<String> operationId;
  final Value<String> rewardId;
  final Value<String> titleSnapshot;
  final Value<int> costSnapshot;
  final Value<int> createdAt;
  final Value<int?> canceledAt;
  final Value<int> rowid;
  const RedemptionsCompanion({
    this.id = const Value.absent(),
    this.operationId = const Value.absent(),
    this.rewardId = const Value.absent(),
    this.titleSnapshot = const Value.absent(),
    this.costSnapshot = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.canceledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RedemptionsCompanion.insert({
    required String id,
    required String operationId,
    required String rewardId,
    required String titleSnapshot,
    required int costSnapshot,
    required int createdAt,
    this.canceledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       operationId = Value(operationId),
       rewardId = Value(rewardId),
       titleSnapshot = Value(titleSnapshot),
       costSnapshot = Value(costSnapshot),
       createdAt = Value(createdAt);
  static Insertable<Redemption> custom({
    Expression<String>? id,
    Expression<String>? operationId,
    Expression<String>? rewardId,
    Expression<String>? titleSnapshot,
    Expression<int>? costSnapshot,
    Expression<int>? createdAt,
    Expression<int>? canceledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationId != null) 'operation_id': operationId,
      if (rewardId != null) 'reward_id': rewardId,
      if (titleSnapshot != null) 'title_snapshot': titleSnapshot,
      if (costSnapshot != null) 'cost_snapshot': costSnapshot,
      if (createdAt != null) 'created_at': createdAt,
      if (canceledAt != null) 'canceled_at': canceledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RedemptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? operationId,
    Value<String>? rewardId,
    Value<String>? titleSnapshot,
    Value<int>? costSnapshot,
    Value<int>? createdAt,
    Value<int?>? canceledAt,
    Value<int>? rowid,
  }) {
    return RedemptionsCompanion(
      id: id ?? this.id,
      operationId: operationId ?? this.operationId,
      rewardId: rewardId ?? this.rewardId,
      titleSnapshot: titleSnapshot ?? this.titleSnapshot,
      costSnapshot: costSnapshot ?? this.costSnapshot,
      createdAt: createdAt ?? this.createdAt,
      canceledAt: canceledAt ?? this.canceledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (rewardId.present) {
      map['reward_id'] = Variable<String>(rewardId.value);
    }
    if (titleSnapshot.present) {
      map['title_snapshot'] = Variable<String>(titleSnapshot.value);
    }
    if (costSnapshot.present) {
      map['cost_snapshot'] = Variable<int>(costSnapshot.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (canceledAt.present) {
      map['canceled_at'] = Variable<int>(canceledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RedemptionsCompanion(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('rewardId: $rewardId, ')
          ..write('titleSnapshot: $titleSnapshot, ')
          ..write('costSnapshot: $costSnapshot, ')
          ..write('createdAt: $createdAt, ')
          ..write('canceledAt: $canceledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Drafts extends Table with TableInfo<Drafts, Draft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Drafts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _pointIdMeta = const VerificationMeta(
    'pointId',
  );
  late final GeneratedColumn<String> pointId = GeneratedColumn<String>(
    'point_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _materialMeta = const VerificationMeta(
    'material',
  );
  late final GeneratedColumn<String> material = GeneratedColumn<String>(
    'material',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _quantityTextMeta = const VerificationMeta(
    'quantityText',
  );
  late final GeneratedColumn<String> quantityText = GeneratedColumn<String>(
    'quantity_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(note) <= 200)',
  );
  static const VerificationMeta _stepMeta = const VerificationMeta('step');
  late final GeneratedColumn<int> step = GeneratedColumn<int>(
    'step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (step BETWEEN 0 AND 2)',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    recordId,
    pointId,
    material,
    quantityText,
    note,
    step,
    updatedAt,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Draft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    }
    if (data.containsKey('point_id')) {
      context.handle(
        _pointIdMeta,
        pointId.isAcceptableOrUnknown(data['point_id']!, _pointIdMeta),
      );
    }
    if (data.containsKey('material')) {
      context.handle(
        _materialMeta,
        material.isAcceptableOrUnknown(data['material']!, _materialMeta),
      );
    }
    if (data.containsKey('quantity_text')) {
      context.handle(
        _quantityTextMeta,
        quantityText.isAcceptableOrUnknown(
          data['quantity_text']!,
          _quantityTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityTextMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('step')) {
      context.handle(
        _stepMeta,
        step.isAcceptableOrUnknown(data['step']!, _stepMeta),
      );
    } else if (isInserting) {
      context.missing(_stepMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Draft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Draft(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      ),
      pointId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}point_id'],
      ),
      material: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material'],
      ),
      quantityText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_text'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      step: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      ),
    );
  }

  @override
  Drafts createAlias(String alias) {
    return Drafts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Draft extends DataClass implements Insertable<Draft> {
  final String key;
  final String? recordId;
  final String? pointId;
  final String? material;
  final String quantityText;
  final String note;
  final int step;
  final int updatedAt;
  final int? occurredAt;
  const Draft({
    required this.key,
    this.recordId,
    this.pointId,
    this.material,
    required this.quantityText,
    required this.note,
    required this.step,
    required this.updatedAt,
    this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || recordId != null) {
      map['record_id'] = Variable<String>(recordId);
    }
    if (!nullToAbsent || pointId != null) {
      map['point_id'] = Variable<String>(pointId);
    }
    if (!nullToAbsent || material != null) {
      map['material'] = Variable<String>(material);
    }
    map['quantity_text'] = Variable<String>(quantityText);
    map['note'] = Variable<String>(note);
    map['step'] = Variable<int>(step);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || occurredAt != null) {
      map['occurred_at'] = Variable<int>(occurredAt);
    }
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      key: Value(key),
      recordId: recordId == null && nullToAbsent
          ? const Value.absent()
          : Value(recordId),
      pointId: pointId == null && nullToAbsent
          ? const Value.absent()
          : Value(pointId),
      material: material == null && nullToAbsent
          ? const Value.absent()
          : Value(material),
      quantityText: Value(quantityText),
      note: Value(note),
      step: Value(step),
      updatedAt: Value(updatedAt),
      occurredAt: occurredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(occurredAt),
    );
  }

  factory Draft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Draft(
      key: serializer.fromJson<String>(json['key']),
      recordId: serializer.fromJson<String?>(json['record_id']),
      pointId: serializer.fromJson<String?>(json['point_id']),
      material: serializer.fromJson<String?>(json['material']),
      quantityText: serializer.fromJson<String>(json['quantity_text']),
      note: serializer.fromJson<String>(json['note']),
      step: serializer.fromJson<int>(json['step']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      occurredAt: serializer.fromJson<int?>(json['occurred_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'record_id': serializer.toJson<String?>(recordId),
      'point_id': serializer.toJson<String?>(pointId),
      'material': serializer.toJson<String?>(material),
      'quantity_text': serializer.toJson<String>(quantityText),
      'note': serializer.toJson<String>(note),
      'step': serializer.toJson<int>(step),
      'updated_at': serializer.toJson<int>(updatedAt),
      'occurred_at': serializer.toJson<int?>(occurredAt),
    };
  }

  Draft copyWith({
    String? key,
    Value<String?> recordId = const Value.absent(),
    Value<String?> pointId = const Value.absent(),
    Value<String?> material = const Value.absent(),
    String? quantityText,
    String? note,
    int? step,
    int? updatedAt,
    Value<int?> occurredAt = const Value.absent(),
  }) => Draft(
    key: key ?? this.key,
    recordId: recordId.present ? recordId.value : this.recordId,
    pointId: pointId.present ? pointId.value : this.pointId,
    material: material.present ? material.value : this.material,
    quantityText: quantityText ?? this.quantityText,
    note: note ?? this.note,
    step: step ?? this.step,
    updatedAt: updatedAt ?? this.updatedAt,
    occurredAt: occurredAt.present ? occurredAt.value : this.occurredAt,
  );
  Draft copyWithCompanion(DraftsCompanion data) {
    return Draft(
      key: data.key.present ? data.key.value : this.key,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      pointId: data.pointId.present ? data.pointId.value : this.pointId,
      material: data.material.present ? data.material.value : this.material,
      quantityText: data.quantityText.present
          ? data.quantityText.value
          : this.quantityText,
      note: data.note.present ? data.note.value : this.note,
      step: data.step.present ? data.step.value : this.step,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Draft(')
          ..write('key: $key, ')
          ..write('recordId: $recordId, ')
          ..write('pointId: $pointId, ')
          ..write('material: $material, ')
          ..write('quantityText: $quantityText, ')
          ..write('note: $note, ')
          ..write('step: $step, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    key,
    recordId,
    pointId,
    material,
    quantityText,
    note,
    step,
    updatedAt,
    occurredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Draft &&
          other.key == this.key &&
          other.recordId == this.recordId &&
          other.pointId == this.pointId &&
          other.material == this.material &&
          other.quantityText == this.quantityText &&
          other.note == this.note &&
          other.step == this.step &&
          other.updatedAt == this.updatedAt &&
          other.occurredAt == this.occurredAt);
}

class DraftsCompanion extends UpdateCompanion<Draft> {
  final Value<String> key;
  final Value<String?> recordId;
  final Value<String?> pointId;
  final Value<String?> material;
  final Value<String> quantityText;
  final Value<String> note;
  final Value<int> step;
  final Value<int> updatedAt;
  final Value<int?> occurredAt;
  final Value<int> rowid;
  const DraftsCompanion({
    this.key = const Value.absent(),
    this.recordId = const Value.absent(),
    this.pointId = const Value.absent(),
    this.material = const Value.absent(),
    this.quantityText = const Value.absent(),
    this.note = const Value.absent(),
    this.step = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftsCompanion.insert({
    required String key,
    this.recordId = const Value.absent(),
    this.pointId = const Value.absent(),
    this.material = const Value.absent(),
    required String quantityText,
    required String note,
    required int step,
    required int updatedAt,
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       quantityText = Value(quantityText),
       note = Value(note),
       step = Value(step),
       updatedAt = Value(updatedAt);
  static Insertable<Draft> custom({
    Expression<String>? key,
    Expression<String>? recordId,
    Expression<String>? pointId,
    Expression<String>? material,
    Expression<String>? quantityText,
    Expression<String>? note,
    Expression<int>? step,
    Expression<int>? updatedAt,
    Expression<int>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (recordId != null) 'record_id': recordId,
      if (pointId != null) 'point_id': pointId,
      if (material != null) 'material': material,
      if (quantityText != null) 'quantity_text': quantityText,
      if (note != null) 'note': note,
      if (step != null) 'step': step,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftsCompanion copyWith({
    Value<String>? key,
    Value<String?>? recordId,
    Value<String?>? pointId,
    Value<String?>? material,
    Value<String>? quantityText,
    Value<String>? note,
    Value<int>? step,
    Value<int>? updatedAt,
    Value<int?>? occurredAt,
    Value<int>? rowid,
  }) {
    return DraftsCompanion(
      key: key ?? this.key,
      recordId: recordId ?? this.recordId,
      pointId: pointId ?? this.pointId,
      material: material ?? this.material,
      quantityText: quantityText ?? this.quantityText,
      note: note ?? this.note,
      step: step ?? this.step,
      updatedAt: updatedAt ?? this.updatedAt,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (pointId.present) {
      map['point_id'] = Variable<String>(pointId.value);
    }
    if (material.present) {
      map['material'] = Variable<String>(material.value);
    }
    if (quantityText.present) {
      map['quantity_text'] = Variable<String>(quantityText.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (step.present) {
      map['step'] = Variable<int>(step.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftsCompanion(')
          ..write('key: $key, ')
          ..write('recordId: $recordId, ')
          ..write('pointId: $pointId, ')
          ..write('material: $material, ')
          ..write('quantityText: $quantityText, ')
          ..write('note: $note, ')
          ..write('step: $step, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Suggestions extends Table with TableInfo<Suggestions, Suggestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Suggestions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (length(trim(message)) BETWEEN 5 AND 500)',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [id, message, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suggestions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Suggestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
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
  Suggestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Suggestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  Suggestions createAlias(String alias) {
    return Suggestions(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Suggestion extends DataClass implements Insertable<Suggestion> {
  final String id;
  final String message;
  final int createdAt;
  const Suggestion({
    required this.id,
    required this.message,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['message'] = Variable<String>(message);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SuggestionsCompanion toCompanion(bool nullToAbsent) {
    return SuggestionsCompanion(
      id: Value(id),
      message: Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory Suggestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Suggestion(
      id: serializer.fromJson<String>(json['id']),
      message: serializer.fromJson<String>(json['message']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'message': serializer.toJson<String>(message),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  Suggestion copyWith({String? id, String? message, int? createdAt}) =>
      Suggestion(
        id: id ?? this.id,
        message: message ?? this.message,
        createdAt: createdAt ?? this.createdAt,
      );
  Suggestion copyWithCompanion(SuggestionsCompanion data) {
    return Suggestion(
      id: data.id.present ? data.id.value : this.id,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Suggestion(')
          ..write('id: $id, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, message, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Suggestion &&
          other.id == this.id &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class SuggestionsCompanion extends UpdateCompanion<Suggestion> {
  final Value<String> id;
  final Value<String> message;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SuggestionsCompanion({
    this.id = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuggestionsCompanion.insert({
    required String id,
    required String message,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       message = Value(message),
       createdAt = Value(createdAt);
  static Insertable<Suggestion> custom({
    Expression<String>? id,
    Expression<String>? message,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuggestionsCompanion copyWith({
    Value<String>? id,
    Value<String>? message,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SuggestionsCompanion(
      id: id ?? this.id,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuggestionsCompanion(')
          ..write('id: $id, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final RecyclingPoints recyclingPoints = RecyclingPoints(this);
  late final RecyclingRecords recyclingRecords = RecyclingRecords(this);
  late final Index recordsOccurredAt = Index(
    'records_occurred_at',
    'CREATE INDEX records_occurred_at ON recycling_records (occurred_at DESC, id)',
  );
  late final Index recordsPoint = Index(
    'records_point',
    'CREATE INDEX records_point ON recycling_records (point_id)',
  );
  late final Rewards rewards = Rewards(this);
  late final Redemptions redemptions = Redemptions(this);
  late final Drafts drafts = Drafts(this);
  late final Suggestions suggestions = Suggestions(this);
  late final Trigger protectRedemptionBalance = Trigger(
    'CREATE TRIGGER protect_redemption_balance BEFORE INSERT ON redemptions WHEN NEW.canceled_at IS NULL AND((SELECT coalesce(sum(quantity * unit_points), 0) FROM recycling_records) - (SELECT coalesce(sum(cost_snapshot), 0) FROM redemptions WHERE canceled_at IS NULL))< NEW.cost_snapshot BEGIN SELECT RAISE (ABORT, \'insufficient_points\');END',
    'protect_redemption_balance',
  );
  late final Trigger protectRecordUpdateBalance = Trigger(
    'CREATE TRIGGER protect_record_update_balance BEFORE UPDATE ON recycling_records WHEN((SELECT coalesce(sum(quantity * unit_points), 0) FROM recycling_records) - OLD.quantity * OLD.unit_points + NEW.quantity * NEW.unit_points)< (SELECT coalesce(sum(cost_snapshot), 0) FROM redemptions WHERE canceled_at IS NULL) BEGIN SELECT RAISE (ABORT, \'committed_points\');END',
    'protect_record_update_balance',
  );
  late final Trigger protectRecordDeleteBalance = Trigger(
    'CREATE TRIGGER protect_record_delete_balance BEFORE DELETE ON recycling_records WHEN (SELECT coalesce(sum(quantity * unit_points), 0) FROM recycling_records WHERE id != OLD.id) < (SELECT coalesce(sum(cost_snapshot), 0) FROM redemptions WHERE canceled_at IS NULL) BEGIN SELECT RAISE (ABORT, \'committed_points\');END',
    'protect_record_delete_balance',
  );
  late final Trigger immutableRedemption = Trigger(
    'CREATE TRIGGER immutable_redemption BEFORE UPDATE ON redemptions WHEN NEW.id != OLD.id OR NEW.operation_id != OLD.operation_id OR NEW.reward_id != OLD.reward_id OR NEW.title_snapshot != OLD.title_snapshot OR NEW.cost_snapshot != OLD.cost_snapshot OR NEW.created_at != OLD.created_at OR(OLD.canceled_at IS NOT NULL AND NEW.canceled_at IS NOT OLD.canceled_at)BEGIN SELECT RAISE (ABORT, \'immutable_redemption\');END',
    'immutable_redemption',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recyclingPoints,
    recyclingRecords,
    recordsOccurredAt,
    recordsPoint,
    rewards,
    redemptions,
    drafts,
    suggestions,
    protectRedemptionBalance,
    protectRecordUpdateBalance,
    protectRecordDeleteBalance,
    immutableRedemption,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'redemptions',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recycling_records',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recycling_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'redemptions',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
  ]);
}
