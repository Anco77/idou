// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ColorStandardsTable extends ColorStandards
    with TableInfo<$ColorStandardsTable, ColorStandard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ColorStandardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _colorIdMeta =
      const VerificationMeta('colorId');
  @override
  late final GeneratedColumn<int> colorId = GeneratedColumn<int>(
      'color_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _colorNameMeta =
      const VerificationMeta('colorName');
  @override
  late final GeneratedColumn<String> colorName = GeneratedColumn<String>(
      'color_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hexValueMeta =
      const VerificationMeta('hexValue');
  @override
  late final GeneratedColumn<String> hexValue = GeneratedColumn<String>(
      'hex_value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rMeta = const VerificationMeta('r');
  @override
  late final GeneratedColumn<int> r = GeneratedColumn<int>(
      'r', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _gMeta = const VerificationMeta('g');
  @override
  late final GeneratedColumn<int> g = GeneratedColumn<int>(
      'g', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bMeta = const VerificationMeta('b');
  @override
  late final GeneratedColumn<int> b = GeneratedColumn<int>(
      'b', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _defaultQtyMeta =
      const VerificationMeta('defaultQty');
  @override
  late final GeneratedColumn<int> defaultQty = GeneratedColumn<int>(
      'default_qty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1200));
  @override
  List<GeneratedColumn> get $columns =>
      [colorId, colorName, hexValue, r, g, b, defaultQty];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'color_standards';
  @override
  VerificationContext validateIntegrity(Insertable<ColorStandard> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('color_id')) {
      context.handle(_colorIdMeta,
          colorId.isAcceptableOrUnknown(data['color_id']!, _colorIdMeta));
    }
    if (data.containsKey('color_name')) {
      context.handle(_colorNameMeta,
          colorName.isAcceptableOrUnknown(data['color_name']!, _colorNameMeta));
    } else if (isInserting) {
      context.missing(_colorNameMeta);
    }
    if (data.containsKey('hex_value')) {
      context.handle(_hexValueMeta,
          hexValue.isAcceptableOrUnknown(data['hex_value']!, _hexValueMeta));
    } else if (isInserting) {
      context.missing(_hexValueMeta);
    }
    if (data.containsKey('r')) {
      context.handle(_rMeta, r.isAcceptableOrUnknown(data['r']!, _rMeta));
    } else if (isInserting) {
      context.missing(_rMeta);
    }
    if (data.containsKey('g')) {
      context.handle(_gMeta, g.isAcceptableOrUnknown(data['g']!, _gMeta));
    } else if (isInserting) {
      context.missing(_gMeta);
    }
    if (data.containsKey('b')) {
      context.handle(_bMeta, b.isAcceptableOrUnknown(data['b']!, _bMeta));
    } else if (isInserting) {
      context.missing(_bMeta);
    }
    if (data.containsKey('default_qty')) {
      context.handle(
          _defaultQtyMeta,
          defaultQty.isAcceptableOrUnknown(
              data['default_qty']!, _defaultQtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {colorId};
  @override
  ColorStandard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ColorStandard(
      colorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_id'])!,
      colorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_name'])!,
      hexValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hex_value'])!,
      r: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}r'])!,
      g: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}g'])!,
      b: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}b'])!,
      defaultQty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}default_qty'])!,
    );
  }

  @override
  $ColorStandardsTable createAlias(String alias) {
    return $ColorStandardsTable(attachedDatabase, alias);
  }
}

class ColorStandard extends DataClass implements Insertable<ColorStandard> {
  final int colorId;
  final String colorName;
  final String hexValue;
  final int r;
  final int g;
  final int b;
  final int defaultQty;
  const ColorStandard(
      {required this.colorId,
      required this.colorName,
      required this.hexValue,
      required this.r,
      required this.g,
      required this.b,
      required this.defaultQty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['color_id'] = Variable<int>(colorId);
    map['color_name'] = Variable<String>(colorName);
    map['hex_value'] = Variable<String>(hexValue);
    map['r'] = Variable<int>(r);
    map['g'] = Variable<int>(g);
    map['b'] = Variable<int>(b);
    map['default_qty'] = Variable<int>(defaultQty);
    return map;
  }

  ColorStandardsCompanion toCompanion(bool nullToAbsent) {
    return ColorStandardsCompanion(
      colorId: Value(colorId),
      colorName: Value(colorName),
      hexValue: Value(hexValue),
      r: Value(r),
      g: Value(g),
      b: Value(b),
      defaultQty: Value(defaultQty),
    );
  }

  factory ColorStandard.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ColorStandard(
      colorId: serializer.fromJson<int>(json['colorId']),
      colorName: serializer.fromJson<String>(json['colorName']),
      hexValue: serializer.fromJson<String>(json['hexValue']),
      r: serializer.fromJson<int>(json['r']),
      g: serializer.fromJson<int>(json['g']),
      b: serializer.fromJson<int>(json['b']),
      defaultQty: serializer.fromJson<int>(json['defaultQty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'colorId': serializer.toJson<int>(colorId),
      'colorName': serializer.toJson<String>(colorName),
      'hexValue': serializer.toJson<String>(hexValue),
      'r': serializer.toJson<int>(r),
      'g': serializer.toJson<int>(g),
      'b': serializer.toJson<int>(b),
      'defaultQty': serializer.toJson<int>(defaultQty),
    };
  }

  ColorStandard copyWith(
          {int? colorId,
          String? colorName,
          String? hexValue,
          int? r,
          int? g,
          int? b,
          int? defaultQty}) =>
      ColorStandard(
        colorId: colorId ?? this.colorId,
        colorName: colorName ?? this.colorName,
        hexValue: hexValue ?? this.hexValue,
        r: r ?? this.r,
        g: g ?? this.g,
        b: b ?? this.b,
        defaultQty: defaultQty ?? this.defaultQty,
      );
  ColorStandard copyWithCompanion(ColorStandardsCompanion data) {
    return ColorStandard(
      colorId: data.colorId.present ? data.colorId.value : this.colorId,
      colorName: data.colorName.present ? data.colorName.value : this.colorName,
      hexValue: data.hexValue.present ? data.hexValue.value : this.hexValue,
      r: data.r.present ? data.r.value : this.r,
      g: data.g.present ? data.g.value : this.g,
      b: data.b.present ? data.b.value : this.b,
      defaultQty:
          data.defaultQty.present ? data.defaultQty.value : this.defaultQty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ColorStandard(')
          ..write('colorId: $colorId, ')
          ..write('colorName: $colorName, ')
          ..write('hexValue: $hexValue, ')
          ..write('r: $r, ')
          ..write('g: $g, ')
          ..write('b: $b, ')
          ..write('defaultQty: $defaultQty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(colorId, colorName, hexValue, r, g, b, defaultQty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ColorStandard &&
          other.colorId == this.colorId &&
          other.colorName == this.colorName &&
          other.hexValue == this.hexValue &&
          other.r == this.r &&
          other.g == this.g &&
          other.b == this.b &&
          other.defaultQty == this.defaultQty);
}

class ColorStandardsCompanion extends UpdateCompanion<ColorStandard> {
  final Value<int> colorId;
  final Value<String> colorName;
  final Value<String> hexValue;
  final Value<int> r;
  final Value<int> g;
  final Value<int> b;
  final Value<int> defaultQty;
  const ColorStandardsCompanion({
    this.colorId = const Value.absent(),
    this.colorName = const Value.absent(),
    this.hexValue = const Value.absent(),
    this.r = const Value.absent(),
    this.g = const Value.absent(),
    this.b = const Value.absent(),
    this.defaultQty = const Value.absent(),
  });
  ColorStandardsCompanion.insert({
    this.colorId = const Value.absent(),
    required String colorName,
    required String hexValue,
    required int r,
    required int g,
    required int b,
    this.defaultQty = const Value.absent(),
  })  : colorName = Value(colorName),
        hexValue = Value(hexValue),
        r = Value(r),
        g = Value(g),
        b = Value(b);
  static Insertable<ColorStandard> custom({
    Expression<int>? colorId,
    Expression<String>? colorName,
    Expression<String>? hexValue,
    Expression<int>? r,
    Expression<int>? g,
    Expression<int>? b,
    Expression<int>? defaultQty,
  }) {
    return RawValuesInsertable({
      if (colorId != null) 'color_id': colorId,
      if (colorName != null) 'color_name': colorName,
      if (hexValue != null) 'hex_value': hexValue,
      if (r != null) 'r': r,
      if (g != null) 'g': g,
      if (b != null) 'b': b,
      if (defaultQty != null) 'default_qty': defaultQty,
    });
  }

  ColorStandardsCompanion copyWith(
      {Value<int>? colorId,
      Value<String>? colorName,
      Value<String>? hexValue,
      Value<int>? r,
      Value<int>? g,
      Value<int>? b,
      Value<int>? defaultQty}) {
    return ColorStandardsCompanion(
      colorId: colorId ?? this.colorId,
      colorName: colorName ?? this.colorName,
      hexValue: hexValue ?? this.hexValue,
      r: r ?? this.r,
      g: g ?? this.g,
      b: b ?? this.b,
      defaultQty: defaultQty ?? this.defaultQty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (colorId.present) {
      map['color_id'] = Variable<int>(colorId.value);
    }
    if (colorName.present) {
      map['color_name'] = Variable<String>(colorName.value);
    }
    if (hexValue.present) {
      map['hex_value'] = Variable<String>(hexValue.value);
    }
    if (r.present) {
      map['r'] = Variable<int>(r.value);
    }
    if (g.present) {
      map['g'] = Variable<int>(g.value);
    }
    if (b.present) {
      map['b'] = Variable<int>(b.value);
    }
    if (defaultQty.present) {
      map['default_qty'] = Variable<int>(defaultQty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ColorStandardsCompanion(')
          ..write('colorId: $colorId, ')
          ..write('colorName: $colorName, ')
          ..write('hexValue: $hexValue, ')
          ..write('r: $r, ')
          ..write('g: $g, ')
          ..write('b: $b, ')
          ..write('defaultQty: $defaultQty')
          ..write(')'))
        .toString();
  }
}

class $InventoryTable extends Inventory
    with TableInfo<$InventoryTable, InventoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _colorIdMeta =
      const VerificationMeta('colorId');
  @override
  late final GeneratedColumn<int> colorId = GeneratedColumn<int>(
      'color_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES color_standards (color_id)'));
  static const VerificationMeta _currentQtyMeta =
      const VerificationMeta('currentQty');
  @override
  late final GeneratedColumn<int> currentQty = GeneratedColumn<int>(
      'current_qty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [colorId, currentQty, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('color_id')) {
      context.handle(_colorIdMeta,
          colorId.isAcceptableOrUnknown(data['color_id']!, _colorIdMeta));
    }
    if (data.containsKey('current_qty')) {
      context.handle(
          _currentQtyMeta,
          currentQty.isAcceptableOrUnknown(
              data['current_qty']!, _currentQtyMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {colorId};
  @override
  InventoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryData(
      colorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_id'])!,
      currentQty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_qty'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $InventoryTable createAlias(String alias) {
    return $InventoryTable(attachedDatabase, alias);
  }
}

class InventoryData extends DataClass implements Insertable<InventoryData> {
  final int colorId;
  final int currentQty;
  final DateTime updatedAt;
  const InventoryData(
      {required this.colorId,
      required this.currentQty,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['color_id'] = Variable<int>(colorId);
    map['current_qty'] = Variable<int>(currentQty);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InventoryCompanion toCompanion(bool nullToAbsent) {
    return InventoryCompanion(
      colorId: Value(colorId),
      currentQty: Value(currentQty),
      updatedAt: Value(updatedAt),
    );
  }

  factory InventoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryData(
      colorId: serializer.fromJson<int>(json['colorId']),
      currentQty: serializer.fromJson<int>(json['currentQty']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'colorId': serializer.toJson<int>(colorId),
      'currentQty': serializer.toJson<int>(currentQty),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  InventoryData copyWith(
          {int? colorId, int? currentQty, DateTime? updatedAt}) =>
      InventoryData(
        colorId: colorId ?? this.colorId,
        currentQty: currentQty ?? this.currentQty,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  InventoryData copyWithCompanion(InventoryCompanion data) {
    return InventoryData(
      colorId: data.colorId.present ? data.colorId.value : this.colorId,
      currentQty:
          data.currentQty.present ? data.currentQty.value : this.currentQty,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryData(')
          ..write('colorId: $colorId, ')
          ..write('currentQty: $currentQty, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(colorId, currentQty, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryData &&
          other.colorId == this.colorId &&
          other.currentQty == this.currentQty &&
          other.updatedAt == this.updatedAt);
}

class InventoryCompanion extends UpdateCompanion<InventoryData> {
  final Value<int> colorId;
  final Value<int> currentQty;
  final Value<DateTime> updatedAt;
  const InventoryCompanion({
    this.colorId = const Value.absent(),
    this.currentQty = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  InventoryCompanion.insert({
    this.colorId = const Value.absent(),
    this.currentQty = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<InventoryData> custom({
    Expression<int>? colorId,
    Expression<int>? currentQty,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (colorId != null) 'color_id': colorId,
      if (currentQty != null) 'current_qty': currentQty,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  InventoryCompanion copyWith(
      {Value<int>? colorId,
      Value<int>? currentQty,
      Value<DateTime>? updatedAt}) {
    return InventoryCompanion(
      colorId: colorId ?? this.colorId,
      currentQty: currentQty ?? this.currentQty,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (colorId.present) {
      map['color_id'] = Variable<int>(colorId.value);
    }
    if (currentQty.present) {
      map['current_qty'] = Variable<int>(currentQty.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCompanion(')
          ..write('colorId: $colorId, ')
          ..write('currentQty: $currentQty, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PatternsTable extends Patterns with TableInfo<$PatternsTable, Pattern> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatternsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originalImageMeta =
      const VerificationMeta('originalImage');
  @override
  late final GeneratedColumn<String> originalImage = GeneratedColumn<String>(
      'original_image', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _uploadTimeMeta =
      const VerificationMeta('uploadTime');
  @override
  late final GeneratedColumn<DateTime> uploadTime = GeneratedColumn<DateTime>(
      'upload_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completeTimeMeta =
      const VerificationMeta('completeTime');
  @override
  late final GeneratedColumn<DateTime> completeTime = GeneratedColumn<DateTime>(
      'complete_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completePhotosMeta =
      const VerificationMeta('completePhotos');
  @override
  late final GeneratedColumn<String> completePhotos = GeneratedColumn<String>(
      'complete_photos', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        originalImage,
        uploadTime,
        completeTime,
        completePhotos,
        status,
        source,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patterns';
  @override
  VerificationContext validateIntegrity(Insertable<Pattern> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('original_image')) {
      context.handle(
          _originalImageMeta,
          originalImage.isAcceptableOrUnknown(
              data['original_image']!, _originalImageMeta));
    } else if (isInserting) {
      context.missing(_originalImageMeta);
    }
    if (data.containsKey('upload_time')) {
      context.handle(
          _uploadTimeMeta,
          uploadTime.isAcceptableOrUnknown(
              data['upload_time']!, _uploadTimeMeta));
    } else if (isInserting) {
      context.missing(_uploadTimeMeta);
    }
    if (data.containsKey('complete_time')) {
      context.handle(
          _completeTimeMeta,
          completeTime.isAcceptableOrUnknown(
              data['complete_time']!, _completeTimeMeta));
    }
    if (data.containsKey('complete_photos')) {
      context.handle(
          _completePhotosMeta,
          completePhotos.isAcceptableOrUnknown(
              data['complete_photos']!, _completePhotosMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pattern map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pattern(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      originalImage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_image'])!,
      uploadTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}upload_time'])!,
      completeTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}complete_time']),
      completePhotos: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}complete_photos']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PatternsTable createAlias(String alias) {
    return $PatternsTable(attachedDatabase, alias);
  }
}

class Pattern extends DataClass implements Insertable<Pattern> {
  final String id;
  final String title;
  final String originalImage;
  final DateTime uploadTime;
  final DateTime? completeTime;
  final String? completePhotos;
  final String status;
  final String source;
  final DateTime createdAt;
  const Pattern(
      {required this.id,
      required this.title,
      required this.originalImage,
      required this.uploadTime,
      this.completeTime,
      this.completePhotos,
      required this.status,
      required this.source,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['original_image'] = Variable<String>(originalImage);
    map['upload_time'] = Variable<DateTime>(uploadTime);
    if (!nullToAbsent || completeTime != null) {
      map['complete_time'] = Variable<DateTime>(completeTime);
    }
    if (!nullToAbsent || completePhotos != null) {
      map['complete_photos'] = Variable<String>(completePhotos);
    }
    map['status'] = Variable<String>(status);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PatternsCompanion toCompanion(bool nullToAbsent) {
    return PatternsCompanion(
      id: Value(id),
      title: Value(title),
      originalImage: Value(originalImage),
      uploadTime: Value(uploadTime),
      completeTime: completeTime == null && nullToAbsent
          ? const Value.absent()
          : Value(completeTime),
      completePhotos: completePhotos == null && nullToAbsent
          ? const Value.absent()
          : Value(completePhotos),
      status: Value(status),
      source: Value(source),
      createdAt: Value(createdAt),
    );
  }

  factory Pattern.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pattern(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      originalImage: serializer.fromJson<String>(json['originalImage']),
      uploadTime: serializer.fromJson<DateTime>(json['uploadTime']),
      completeTime: serializer.fromJson<DateTime?>(json['completeTime']),
      completePhotos: serializer.fromJson<String?>(json['completePhotos']),
      status: serializer.fromJson<String>(json['status']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'originalImage': serializer.toJson<String>(originalImage),
      'uploadTime': serializer.toJson<DateTime>(uploadTime),
      'completeTime': serializer.toJson<DateTime?>(completeTime),
      'completePhotos': serializer.toJson<String?>(completePhotos),
      'status': serializer.toJson<String>(status),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Pattern copyWith(
          {String? id,
          String? title,
          String? originalImage,
          DateTime? uploadTime,
          Value<DateTime?> completeTime = const Value.absent(),
          Value<String?> completePhotos = const Value.absent(),
          String? status,
          String? source,
          DateTime? createdAt}) =>
      Pattern(
        id: id ?? this.id,
        title: title ?? this.title,
        originalImage: originalImage ?? this.originalImage,
        uploadTime: uploadTime ?? this.uploadTime,
        completeTime:
            completeTime.present ? completeTime.value : this.completeTime,
        completePhotos:
            completePhotos.present ? completePhotos.value : this.completePhotos,
        status: status ?? this.status,
        source: source ?? this.source,
        createdAt: createdAt ?? this.createdAt,
      );
  Pattern copyWithCompanion(PatternsCompanion data) {
    return Pattern(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      originalImage: data.originalImage.present
          ? data.originalImage.value
          : this.originalImage,
      uploadTime:
          data.uploadTime.present ? data.uploadTime.value : this.uploadTime,
      completeTime: data.completeTime.present
          ? data.completeTime.value
          : this.completeTime,
      completePhotos: data.completePhotos.present
          ? data.completePhotos.value
          : this.completePhotos,
      status: data.status.present ? data.status.value : this.status,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pattern(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('originalImage: $originalImage, ')
          ..write('uploadTime: $uploadTime, ')
          ..write('completeTime: $completeTime, ')
          ..write('completePhotos: $completePhotos, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, originalImage, uploadTime,
      completeTime, completePhotos, status, source, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pattern &&
          other.id == this.id &&
          other.title == this.title &&
          other.originalImage == this.originalImage &&
          other.uploadTime == this.uploadTime &&
          other.completeTime == this.completeTime &&
          other.completePhotos == this.completePhotos &&
          other.status == this.status &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class PatternsCompanion extends UpdateCompanion<Pattern> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> originalImage;
  final Value<DateTime> uploadTime;
  final Value<DateTime?> completeTime;
  final Value<String?> completePhotos;
  final Value<String> status;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PatternsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.originalImage = const Value.absent(),
    this.uploadTime = const Value.absent(),
    this.completeTime = const Value.absent(),
    this.completePhotos = const Value.absent(),
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatternsCompanion.insert({
    required String id,
    required String title,
    required String originalImage,
    required DateTime uploadTime,
    this.completeTime = const Value.absent(),
    this.completePhotos = const Value.absent(),
    this.status = const Value.absent(),
    required String source,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        originalImage = Value(originalImage),
        uploadTime = Value(uploadTime),
        source = Value(source);
  static Insertable<Pattern> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? originalImage,
    Expression<DateTime>? uploadTime,
    Expression<DateTime>? completeTime,
    Expression<String>? completePhotos,
    Expression<String>? status,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (originalImage != null) 'original_image': originalImage,
      if (uploadTime != null) 'upload_time': uploadTime,
      if (completeTime != null) 'complete_time': completeTime,
      if (completePhotos != null) 'complete_photos': completePhotos,
      if (status != null) 'status': status,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatternsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? originalImage,
      Value<DateTime>? uploadTime,
      Value<DateTime?>? completeTime,
      Value<String?>? completePhotos,
      Value<String>? status,
      Value<String>? source,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PatternsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      originalImage: originalImage ?? this.originalImage,
      uploadTime: uploadTime ?? this.uploadTime,
      completeTime: completeTime ?? this.completeTime,
      completePhotos: completePhotos ?? this.completePhotos,
      status: status ?? this.status,
      source: source ?? this.source,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (originalImage.present) {
      map['original_image'] = Variable<String>(originalImage.value);
    }
    if (uploadTime.present) {
      map['upload_time'] = Variable<DateTime>(uploadTime.value);
    }
    if (completeTime.present) {
      map['complete_time'] = Variable<DateTime>(completeTime.value);
    }
    if (completePhotos.present) {
      map['complete_photos'] = Variable<String>(completePhotos.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
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
    return (StringBuffer('PatternsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('originalImage: $originalImage, ')
          ..write('uploadTime: $uploadTime, ')
          ..write('completeTime: $completeTime, ')
          ..write('completePhotos: $completePhotos, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryLogsTable extends InventoryLogs
    with TableInfo<$InventoryLogsTable, InventoryLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _colorIdMeta =
      const VerificationMeta('colorId');
  @override
  late final GeneratedColumn<int> colorId = GeneratedColumn<int>(
      'color_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES color_standards (color_id)'));
  static const VerificationMeta _changeTypeMeta =
      const VerificationMeta('changeType');
  @override
  late final GeneratedColumn<String> changeType = GeneratedColumn<String>(
      'change_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _resultQtyMeta =
      const VerificationMeta('resultQty');
  @override
  late final GeneratedColumn<int> resultQty = GeneratedColumn<int>(
      'result_qty', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _patternIdMeta =
      const VerificationMeta('patternId');
  @override
  late final GeneratedColumn<String> patternId = GeneratedColumn<String>(
      'pattern_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES patterns (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, colorId, changeType, quantity, resultQty, patternId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_logs';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('color_id')) {
      context.handle(_colorIdMeta,
          colorId.isAcceptableOrUnknown(data['color_id']!, _colorIdMeta));
    } else if (isInserting) {
      context.missing(_colorIdMeta);
    }
    if (data.containsKey('change_type')) {
      context.handle(
          _changeTypeMeta,
          changeType.isAcceptableOrUnknown(
              data['change_type']!, _changeTypeMeta));
    } else if (isInserting) {
      context.missing(_changeTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('result_qty')) {
      context.handle(_resultQtyMeta,
          resultQty.isAcceptableOrUnknown(data['result_qty']!, _resultQtyMeta));
    } else if (isInserting) {
      context.missing(_resultQtyMeta);
    }
    if (data.containsKey('pattern_id')) {
      context.handle(_patternIdMeta,
          patternId.isAcceptableOrUnknown(data['pattern_id']!, _patternIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      colorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_id'])!,
      changeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}change_type'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      resultQty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}result_qty'])!,
      patternId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pattern_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InventoryLogsTable createAlias(String alias) {
    return $InventoryLogsTable(attachedDatabase, alias);
  }
}

class InventoryLog extends DataClass implements Insertable<InventoryLog> {
  final int id;
  final int colorId;
  final String changeType;
  final int quantity;
  final int resultQty;
  final String? patternId;
  final DateTime createdAt;
  const InventoryLog(
      {required this.id,
      required this.colorId,
      required this.changeType,
      required this.quantity,
      required this.resultQty,
      this.patternId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['color_id'] = Variable<int>(colorId);
    map['change_type'] = Variable<String>(changeType);
    map['quantity'] = Variable<int>(quantity);
    map['result_qty'] = Variable<int>(resultQty);
    if (!nullToAbsent || patternId != null) {
      map['pattern_id'] = Variable<String>(patternId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InventoryLogsCompanion toCompanion(bool nullToAbsent) {
    return InventoryLogsCompanion(
      id: Value(id),
      colorId: Value(colorId),
      changeType: Value(changeType),
      quantity: Value(quantity),
      resultQty: Value(resultQty),
      patternId: patternId == null && nullToAbsent
          ? const Value.absent()
          : Value(patternId),
      createdAt: Value(createdAt),
    );
  }

  factory InventoryLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryLog(
      id: serializer.fromJson<int>(json['id']),
      colorId: serializer.fromJson<int>(json['colorId']),
      changeType: serializer.fromJson<String>(json['changeType']),
      quantity: serializer.fromJson<int>(json['quantity']),
      resultQty: serializer.fromJson<int>(json['resultQty']),
      patternId: serializer.fromJson<String?>(json['patternId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'colorId': serializer.toJson<int>(colorId),
      'changeType': serializer.toJson<String>(changeType),
      'quantity': serializer.toJson<int>(quantity),
      'resultQty': serializer.toJson<int>(resultQty),
      'patternId': serializer.toJson<String?>(patternId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InventoryLog copyWith(
          {int? id,
          int? colorId,
          String? changeType,
          int? quantity,
          int? resultQty,
          Value<String?> patternId = const Value.absent(),
          DateTime? createdAt}) =>
      InventoryLog(
        id: id ?? this.id,
        colorId: colorId ?? this.colorId,
        changeType: changeType ?? this.changeType,
        quantity: quantity ?? this.quantity,
        resultQty: resultQty ?? this.resultQty,
        patternId: patternId.present ? patternId.value : this.patternId,
        createdAt: createdAt ?? this.createdAt,
      );
  InventoryLog copyWithCompanion(InventoryLogsCompanion data) {
    return InventoryLog(
      id: data.id.present ? data.id.value : this.id,
      colorId: data.colorId.present ? data.colorId.value : this.colorId,
      changeType:
          data.changeType.present ? data.changeType.value : this.changeType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      resultQty: data.resultQty.present ? data.resultQty.value : this.resultQty,
      patternId: data.patternId.present ? data.patternId.value : this.patternId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryLog(')
          ..write('id: $id, ')
          ..write('colorId: $colorId, ')
          ..write('changeType: $changeType, ')
          ..write('quantity: $quantity, ')
          ..write('resultQty: $resultQty, ')
          ..write('patternId: $patternId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, colorId, changeType, quantity, resultQty, patternId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryLog &&
          other.id == this.id &&
          other.colorId == this.colorId &&
          other.changeType == this.changeType &&
          other.quantity == this.quantity &&
          other.resultQty == this.resultQty &&
          other.patternId == this.patternId &&
          other.createdAt == this.createdAt);
}

class InventoryLogsCompanion extends UpdateCompanion<InventoryLog> {
  final Value<int> id;
  final Value<int> colorId;
  final Value<String> changeType;
  final Value<int> quantity;
  final Value<int> resultQty;
  final Value<String?> patternId;
  final Value<DateTime> createdAt;
  const InventoryLogsCompanion({
    this.id = const Value.absent(),
    this.colorId = const Value.absent(),
    this.changeType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.resultQty = const Value.absent(),
    this.patternId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  InventoryLogsCompanion.insert({
    this.id = const Value.absent(),
    required int colorId,
    required String changeType,
    required int quantity,
    required int resultQty,
    this.patternId = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : colorId = Value(colorId),
        changeType = Value(changeType),
        quantity = Value(quantity),
        resultQty = Value(resultQty);
  static Insertable<InventoryLog> custom({
    Expression<int>? id,
    Expression<int>? colorId,
    Expression<String>? changeType,
    Expression<int>? quantity,
    Expression<int>? resultQty,
    Expression<String>? patternId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (colorId != null) 'color_id': colorId,
      if (changeType != null) 'change_type': changeType,
      if (quantity != null) 'quantity': quantity,
      if (resultQty != null) 'result_qty': resultQty,
      if (patternId != null) 'pattern_id': patternId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  InventoryLogsCompanion copyWith(
      {Value<int>? id,
      Value<int>? colorId,
      Value<String>? changeType,
      Value<int>? quantity,
      Value<int>? resultQty,
      Value<String?>? patternId,
      Value<DateTime>? createdAt}) {
    return InventoryLogsCompanion(
      id: id ?? this.id,
      colorId: colorId ?? this.colorId,
      changeType: changeType ?? this.changeType,
      quantity: quantity ?? this.quantity,
      resultQty: resultQty ?? this.resultQty,
      patternId: patternId ?? this.patternId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (colorId.present) {
      map['color_id'] = Variable<int>(colorId.value);
    }
    if (changeType.present) {
      map['change_type'] = Variable<String>(changeType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (resultQty.present) {
      map['result_qty'] = Variable<int>(resultQty.value);
    }
    if (patternId.present) {
      map['pattern_id'] = Variable<String>(patternId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryLogsCompanion(')
          ..write('id: $id, ')
          ..write('colorId: $colorId, ')
          ..write('changeType: $changeType, ')
          ..write('quantity: $quantity, ')
          ..write('resultQty: $resultQty, ')
          ..write('patternId: $patternId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PatternConsumptionsTable extends PatternConsumptions
    with TableInfo<$PatternConsumptionsTable, PatternConsumption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatternConsumptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _patternIdMeta =
      const VerificationMeta('patternId');
  @override
  late final GeneratedColumn<String> patternId = GeneratedColumn<String>(
      'pattern_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES patterns (id)'));
  static const VerificationMeta _colorIdMeta =
      const VerificationMeta('colorId');
  @override
  late final GeneratedColumn<int> colorId = GeneratedColumn<int>(
      'color_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES color_standards (color_id)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, patternId, colorId, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pattern_consumptions';
  @override
  VerificationContext validateIntegrity(Insertable<PatternConsumption> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pattern_id')) {
      context.handle(_patternIdMeta,
          patternId.isAcceptableOrUnknown(data['pattern_id']!, _patternIdMeta));
    } else if (isInserting) {
      context.missing(_patternIdMeta);
    }
    if (data.containsKey('color_id')) {
      context.handle(_colorIdMeta,
          colorId.isAcceptableOrUnknown(data['color_id']!, _colorIdMeta));
    } else if (isInserting) {
      context.missing(_colorIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {patternId, colorId},
      ];
  @override
  PatternConsumption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatternConsumption(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      patternId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pattern_id'])!,
      colorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
    );
  }

  @override
  $PatternConsumptionsTable createAlias(String alias) {
    return $PatternConsumptionsTable(attachedDatabase, alias);
  }
}

class PatternConsumption extends DataClass
    implements Insertable<PatternConsumption> {
  final int id;
  final String patternId;
  final int colorId;
  final int quantity;
  const PatternConsumption(
      {required this.id,
      required this.patternId,
      required this.colorId,
      required this.quantity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pattern_id'] = Variable<String>(patternId);
    map['color_id'] = Variable<int>(colorId);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  PatternConsumptionsCompanion toCompanion(bool nullToAbsent) {
    return PatternConsumptionsCompanion(
      id: Value(id),
      patternId: Value(patternId),
      colorId: Value(colorId),
      quantity: Value(quantity),
    );
  }

  factory PatternConsumption.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatternConsumption(
      id: serializer.fromJson<int>(json['id']),
      patternId: serializer.fromJson<String>(json['patternId']),
      colorId: serializer.fromJson<int>(json['colorId']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'patternId': serializer.toJson<String>(patternId),
      'colorId': serializer.toJson<int>(colorId),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  PatternConsumption copyWith(
          {int? id, String? patternId, int? colorId, int? quantity}) =>
      PatternConsumption(
        id: id ?? this.id,
        patternId: patternId ?? this.patternId,
        colorId: colorId ?? this.colorId,
        quantity: quantity ?? this.quantity,
      );
  PatternConsumption copyWithCompanion(PatternConsumptionsCompanion data) {
    return PatternConsumption(
      id: data.id.present ? data.id.value : this.id,
      patternId: data.patternId.present ? data.patternId.value : this.patternId,
      colorId: data.colorId.present ? data.colorId.value : this.colorId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatternConsumption(')
          ..write('id: $id, ')
          ..write('patternId: $patternId, ')
          ..write('colorId: $colorId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, patternId, colorId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatternConsumption &&
          other.id == this.id &&
          other.patternId == this.patternId &&
          other.colorId == this.colorId &&
          other.quantity == this.quantity);
}

class PatternConsumptionsCompanion extends UpdateCompanion<PatternConsumption> {
  final Value<int> id;
  final Value<String> patternId;
  final Value<int> colorId;
  final Value<int> quantity;
  const PatternConsumptionsCompanion({
    this.id = const Value.absent(),
    this.patternId = const Value.absent(),
    this.colorId = const Value.absent(),
    this.quantity = const Value.absent(),
  });
  PatternConsumptionsCompanion.insert({
    this.id = const Value.absent(),
    required String patternId,
    required int colorId,
    required int quantity,
  })  : patternId = Value(patternId),
        colorId = Value(colorId),
        quantity = Value(quantity);
  static Insertable<PatternConsumption> custom({
    Expression<int>? id,
    Expression<String>? patternId,
    Expression<int>? colorId,
    Expression<int>? quantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patternId != null) 'pattern_id': patternId,
      if (colorId != null) 'color_id': colorId,
      if (quantity != null) 'quantity': quantity,
    });
  }

  PatternConsumptionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? patternId,
      Value<int>? colorId,
      Value<int>? quantity}) {
    return PatternConsumptionsCompanion(
      id: id ?? this.id,
      patternId: patternId ?? this.patternId,
      colorId: colorId ?? this.colorId,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (patternId.present) {
      map['pattern_id'] = Variable<String>(patternId.value);
    }
    if (colorId.present) {
      map['color_id'] = Variable<int>(colorId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatternConsumptionsCompanion(')
          ..write('id: $id, ')
          ..write('patternId: $patternId, ')
          ..write('colorId: $colorId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ColorStandardsTable colorStandards = $ColorStandardsTable(this);
  late final $InventoryTable inventory = $InventoryTable(this);
  late final $PatternsTable patterns = $PatternsTable(this);
  late final $InventoryLogsTable inventoryLogs = $InventoryLogsTable(this);
  late final $PatternConsumptionsTable patternConsumptions =
      $PatternConsumptionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [colorStandards, inventory, patterns, inventoryLogs, patternConsumptions];
}

typedef $$ColorStandardsTableCreateCompanionBuilder = ColorStandardsCompanion
    Function({
  Value<int> colorId,
  required String colorName,
  required String hexValue,
  required int r,
  required int g,
  required int b,
  Value<int> defaultQty,
});
typedef $$ColorStandardsTableUpdateCompanionBuilder = ColorStandardsCompanion
    Function({
  Value<int> colorId,
  Value<String> colorName,
  Value<String> hexValue,
  Value<int> r,
  Value<int> g,
  Value<int> b,
  Value<int> defaultQty,
});

final class $$ColorStandardsTableReferences
    extends BaseReferences<_$AppDatabase, $ColorStandardsTable, ColorStandard> {
  $$ColorStandardsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InventoryTable, List<InventoryData>>
      _inventoryRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inventory,
              aliasName: $_aliasNameGenerator(
                  db.colorStandards.colorId, db.inventory.colorId));

  $$InventoryTableProcessedTableManager get inventoryRefs {
    final manager = $$InventoryTableTableManager($_db, $_db.inventory).filter(
        (f) => f.colorId.colorId.sqlEquals($_itemColumn<int>('color_id')!));

    final cache = $_typedResult.readTableOrNull(_inventoryRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InventoryLogsTable, List<InventoryLog>>
      _inventoryLogsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inventoryLogs,
              aliasName: $_aliasNameGenerator(
                  db.colorStandards.colorId, db.inventoryLogs.colorId));

  $$InventoryLogsTableProcessedTableManager get inventoryLogsRefs {
    final manager = $$InventoryLogsTableTableManager($_db, $_db.inventoryLogs)
        .filter(
            (f) => f.colorId.colorId.sqlEquals($_itemColumn<int>('color_id')!));

    final cache = $_typedResult.readTableOrNull(_inventoryLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PatternConsumptionsTable,
      List<PatternConsumption>> _patternConsumptionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.patternConsumptions,
          aliasName: $_aliasNameGenerator(
              db.colorStandards.colorId, db.patternConsumptions.colorId));

  $$PatternConsumptionsTableProcessedTableManager get patternConsumptionsRefs {
    final manager = $$PatternConsumptionsTableTableManager(
            $_db, $_db.patternConsumptions)
        .filter(
            (f) => f.colorId.colorId.sqlEquals($_itemColumn<int>('color_id')!));

    final cache =
        $_typedResult.readTableOrNull(_patternConsumptionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ColorStandardsTableFilterComposer
    extends Composer<_$AppDatabase, $ColorStandardsTable> {
  $$ColorStandardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get colorId => $composableBuilder(
      column: $table.colorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorName => $composableBuilder(
      column: $table.colorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hexValue => $composableBuilder(
      column: $table.hexValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get r => $composableBuilder(
      column: $table.r, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get g => $composableBuilder(
      column: $table.g, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get b => $composableBuilder(
      column: $table.b, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defaultQty => $composableBuilder(
      column: $table.defaultQty, builder: (column) => ColumnFilters(column));

  Expression<bool> inventoryRefs(
      Expression<bool> Function($$InventoryTableFilterComposer f) f) {
    final $$InventoryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.colorId,
        referencedTable: $db.inventory,
        getReferencedColumn: (t) => t.colorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryTableFilterComposer(
              $db: $db,
              $table: $db.inventory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> inventoryLogsRefs(
      Expression<bool> Function($$InventoryLogsTableFilterComposer f) f) {
    final $$InventoryLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.colorId,
        referencedTable: $db.inventoryLogs,
        getReferencedColumn: (t) => t.colorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryLogsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> patternConsumptionsRefs(
      Expression<bool> Function($$PatternConsumptionsTableFilterComposer f) f) {
    final $$PatternConsumptionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.colorId,
        referencedTable: $db.patternConsumptions,
        getReferencedColumn: (t) => t.colorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatternConsumptionsTableFilterComposer(
              $db: $db,
              $table: $db.patternConsumptions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ColorStandardsTableOrderingComposer
    extends Composer<_$AppDatabase, $ColorStandardsTable> {
  $$ColorStandardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get colorId => $composableBuilder(
      column: $table.colorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorName => $composableBuilder(
      column: $table.colorName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hexValue => $composableBuilder(
      column: $table.hexValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get r => $composableBuilder(
      column: $table.r, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get g => $composableBuilder(
      column: $table.g, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get b => $composableBuilder(
      column: $table.b, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defaultQty => $composableBuilder(
      column: $table.defaultQty, builder: (column) => ColumnOrderings(column));
}

class $$ColorStandardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ColorStandardsTable> {
  $$ColorStandardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get colorId =>
      $composableBuilder(column: $table.colorId, builder: (column) => column);

  GeneratedColumn<String> get colorName =>
      $composableBuilder(column: $table.colorName, builder: (column) => column);

  GeneratedColumn<String> get hexValue =>
      $composableBuilder(column: $table.hexValue, builder: (column) => column);

  GeneratedColumn<int> get r =>
      $composableBuilder(column: $table.r, builder: (column) => column);

  GeneratedColumn<int> get g =>
      $composableBuilder(column: $table.g, builder: (column) => column);

  GeneratedColumn<int> get b =>
      $composableBuilder(column: $table.b, builder: (column) => column);

  GeneratedColumn<int> get defaultQty => $composableBuilder(
      column: $table.defaultQty, builder: (column) => column);

  Expression<T> inventoryRefs<T extends Object>(
      Expression<T> Function($$InventoryTableAnnotationComposer a) f) {
    final $$InventoryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.colorId,
        referencedTable: $db.inventory,
        getReferencedColumn: (t) => t.colorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryTableAnnotationComposer(
              $db: $db,
              $table: $db.inventory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> inventoryLogsRefs<T extends Object>(
      Expression<T> Function($$InventoryLogsTableAnnotationComposer a) f) {
    final $$InventoryLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.colorId,
        referencedTable: $db.inventoryLogs,
        getReferencedColumn: (t) => t.colorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.inventoryLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> patternConsumptionsRefs<T extends Object>(
      Expression<T> Function($$PatternConsumptionsTableAnnotationComposer a)
          f) {
    final $$PatternConsumptionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.colorId,
            referencedTable: $db.patternConsumptions,
            getReferencedColumn: (t) => t.colorId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PatternConsumptionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.patternConsumptions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ColorStandardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ColorStandardsTable,
    ColorStandard,
    $$ColorStandardsTableFilterComposer,
    $$ColorStandardsTableOrderingComposer,
    $$ColorStandardsTableAnnotationComposer,
    $$ColorStandardsTableCreateCompanionBuilder,
    $$ColorStandardsTableUpdateCompanionBuilder,
    (ColorStandard, $$ColorStandardsTableReferences),
    ColorStandard,
    PrefetchHooks Function(
        {bool inventoryRefs,
        bool inventoryLogsRefs,
        bool patternConsumptionsRefs})> {
  $$ColorStandardsTableTableManager(
      _$AppDatabase db, $ColorStandardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ColorStandardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ColorStandardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ColorStandardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> colorId = const Value.absent(),
            Value<String> colorName = const Value.absent(),
            Value<String> hexValue = const Value.absent(),
            Value<int> r = const Value.absent(),
            Value<int> g = const Value.absent(),
            Value<int> b = const Value.absent(),
            Value<int> defaultQty = const Value.absent(),
          }) =>
              ColorStandardsCompanion(
            colorId: colorId,
            colorName: colorName,
            hexValue: hexValue,
            r: r,
            g: g,
            b: b,
            defaultQty: defaultQty,
          ),
          createCompanionCallback: ({
            Value<int> colorId = const Value.absent(),
            required String colorName,
            required String hexValue,
            required int r,
            required int g,
            required int b,
            Value<int> defaultQty = const Value.absent(),
          }) =>
              ColorStandardsCompanion.insert(
            colorId: colorId,
            colorName: colorName,
            hexValue: hexValue,
            r: r,
            g: g,
            b: b,
            defaultQty: defaultQty,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ColorStandardsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {inventoryRefs = false,
              inventoryLogsRefs = false,
              patternConsumptionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (inventoryRefs) db.inventory,
                if (inventoryLogsRefs) db.inventoryLogs,
                if (patternConsumptionsRefs) db.patternConsumptions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (inventoryRefs)
                    await $_getPrefetchedData<ColorStandard,
                            $ColorStandardsTable, InventoryData>(
                        currentTable: table,
                        referencedTable: $$ColorStandardsTableReferences
                            ._inventoryRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ColorStandardsTableReferences(db, table, p0)
                                .inventoryRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.colorId == item.colorId),
                        typedResults: items),
                  if (inventoryLogsRefs)
                    await $_getPrefetchedData<ColorStandard, $ColorStandardsTable,
                            InventoryLog>(
                        currentTable: table,
                        referencedTable: $$ColorStandardsTableReferences
                            ._inventoryLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ColorStandardsTableReferences(db, table, p0)
                                .inventoryLogsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.colorId == item.colorId),
                        typedResults: items),
                  if (patternConsumptionsRefs)
                    await $_getPrefetchedData<ColorStandard,
                            $ColorStandardsTable, PatternConsumption>(
                        currentTable: table,
                        referencedTable: $$ColorStandardsTableReferences
                            ._patternConsumptionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ColorStandardsTableReferences(db, table, p0)
                                .patternConsumptionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.colorId == item.colorId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ColorStandardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ColorStandardsTable,
    ColorStandard,
    $$ColorStandardsTableFilterComposer,
    $$ColorStandardsTableOrderingComposer,
    $$ColorStandardsTableAnnotationComposer,
    $$ColorStandardsTableCreateCompanionBuilder,
    $$ColorStandardsTableUpdateCompanionBuilder,
    (ColorStandard, $$ColorStandardsTableReferences),
    ColorStandard,
    PrefetchHooks Function(
        {bool inventoryRefs,
        bool inventoryLogsRefs,
        bool patternConsumptionsRefs})>;
typedef $$InventoryTableCreateCompanionBuilder = InventoryCompanion Function({
  Value<int> colorId,
  Value<int> currentQty,
  Value<DateTime> updatedAt,
});
typedef $$InventoryTableUpdateCompanionBuilder = InventoryCompanion Function({
  Value<int> colorId,
  Value<int> currentQty,
  Value<DateTime> updatedAt,
});

final class $$InventoryTableReferences
    extends BaseReferences<_$AppDatabase, $InventoryTable, InventoryData> {
  $$InventoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ColorStandardsTable _colorIdTable(_$AppDatabase db) =>
      db.colorStandards.createAlias($_aliasNameGenerator(
          db.inventory.colorId, db.colorStandards.colorId));

  $$ColorStandardsTableProcessedTableManager get colorId {
    final $_column = $_itemColumn<int>('color_id')!;

    final manager = $$ColorStandardsTableTableManager($_db, $_db.colorStandards)
        .filter((f) => f.colorId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_colorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InventoryTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get currentQty => $composableBuilder(
      column: $table.currentQty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ColorStandardsTableFilterComposer get colorId {
    final $$ColorStandardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.colorId,
        referencedTable: $db.colorStandards,
        getReferencedColumn: (t) => t.colorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ColorStandardsTableFilterComposer(
              $db: $db,
              $table: $db.colorStandards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get currentQty => $composableBuilder(
      column: $table.currentQty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ColorStandardsTableOrderingComposer get colorId {
    final $$ColorStandardsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.colorId,
        referencedTable: $db.colorStandards,
        getReferencedColumn: (t) => t.colorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ColorStandardsTableOrderingComposer(
              $db: $db,
              $table: $db.colorStandards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get currentQty => $composableBuilder(
      column: $table.currentQty, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ColorStandardsTableAnnotationComposer get colorId {
    final $$ColorStandardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.colorId,
        referencedTable: $db.colorStandards,
        getReferencedColumn: (t) => t.colorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ColorStandardsTableAnnotationComposer(
              $db: $db,
              $table: $db.colorStandards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryTable,
    InventoryData,
    $$InventoryTableFilterComposer,
    $$InventoryTableOrderingComposer,
    $$InventoryTableAnnotationComposer,
    $$InventoryTableCreateCompanionBuilder,
    $$InventoryTableUpdateCompanionBuilder,
    (InventoryData, $$InventoryTableReferences),
    InventoryData,
    PrefetchHooks Function({bool colorId})> {
  $$InventoryTableTableManager(_$AppDatabase db, $InventoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> colorId = const Value.absent(),
            Value<int> currentQty = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              InventoryCompanion(
            colorId: colorId,
            currentQty: currentQty,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> colorId = const Value.absent(),
            Value<int> currentQty = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              InventoryCompanion.insert(
            colorId: colorId,
            currentQty: currentQty,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InventoryTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({colorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (colorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.colorId,
                    referencedTable:
                        $$InventoryTableReferences._colorIdTable(db),
                    referencedColumn:
                        $$InventoryTableReferences._colorIdTable(db).colorId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InventoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InventoryTable,
    InventoryData,
    $$InventoryTableFilterComposer,
    $$InventoryTableOrderingComposer,
    $$InventoryTableAnnotationComposer,
    $$InventoryTableCreateCompanionBuilder,
    $$InventoryTableUpdateCompanionBuilder,
    (InventoryData, $$InventoryTableReferences),
    InventoryData,
    PrefetchHooks Function({bool colorId})>;
typedef $$PatternsTableCreateCompanionBuilder = PatternsCompanion Function({
  required String id,
  required String title,
  required String originalImage,
  required DateTime uploadTime,
  Value<DateTime?> completeTime,
  Value<String?> completePhotos,
  Value<String> status,
  required String source,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$PatternsTableUpdateCompanionBuilder = PatternsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> originalImage,
  Value<DateTime> uploadTime,
  Value<DateTime?> completeTime,
  Value<String?> completePhotos,
  Value<String> status,
  Value<String> source,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$PatternsTableReferences
    extends BaseReferences<_$AppDatabase, $PatternsTable, Pattern> {
  $$PatternsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InventoryLogsTable, List<InventoryLog>>
      _inventoryLogsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inventoryLogs,
              aliasName: $_aliasNameGenerator(
                  db.patterns.id, db.inventoryLogs.patternId));

  $$InventoryLogsTableProcessedTableManager get inventoryLogsRefs {
    final manager = $$InventoryLogsTableTableManager($_db, $_db.inventoryLogs)
        .filter((f) => f.patternId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_inventoryLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PatternConsumptionsTable,
      List<PatternConsumption>> _patternConsumptionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.patternConsumptions,
          aliasName: $_aliasNameGenerator(
              db.patterns.id, db.patternConsumptions.patternId));

  $$PatternConsumptionsTableProcessedTableManager get patternConsumptionsRefs {
    final manager = $$PatternConsumptionsTableTableManager(
            $_db, $_db.patternConsumptions)
        .filter((f) => f.patternId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_patternConsumptionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PatternsTableFilterComposer
    extends Composer<_$AppDatabase, $PatternsTable> {
  $$PatternsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalImage => $composableBuilder(
      column: $table.originalImage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get uploadTime => $composableBuilder(
      column: $table.uploadTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completeTime => $composableBuilder(
      column: $table.completeTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completePhotos => $composableBuilder(
      column: $table.completePhotos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> inventoryLogsRefs(
      Expression<bool> Function($$InventoryLogsTableFilterComposer f) f) {
    final $$InventoryLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryLogs,
        getReferencedColumn: (t) => t.patternId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryLogsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> patternConsumptionsRefs(
      Expression<bool> Function($$PatternConsumptionsTableFilterComposer f) f) {
    final $$PatternConsumptionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.patternConsumptions,
        getReferencedColumn: (t) => t.patternId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatternConsumptionsTableFilterComposer(
              $db: $db,
              $table: $db.patternConsumptions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PatternsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatternsTable> {
  $$PatternsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalImage => $composableBuilder(
      column: $table.originalImage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get uploadTime => $composableBuilder(
      column: $table.uploadTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completeTime => $composableBuilder(
      column: $table.completeTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get completePhotos => $composableBuilder(
      column: $table.completePhotos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PatternsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatternsTable> {
  $$PatternsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get originalImage => $composableBuilder(
      column: $table.originalImage, builder: (column) => column);

  GeneratedColumn<DateTime> get uploadTime => $composableBuilder(
      column: $table.uploadTime, builder: (column) => column);

  GeneratedColumn<DateTime> get completeTime => $composableBuilder(
      column: $table.completeTime, builder: (column) => column);

  GeneratedColumn<String> get completePhotos => $composableBuilder(
      column: $table.completePhotos, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> inventoryLogsRefs<T extends Object>(
      Expression<T> Function($$InventoryLogsTableAnnotationComposer a) f) {
    final $$InventoryLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryLogs,
        getReferencedColumn: (t) => t.patternId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.inventoryLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> patternConsumptionsRefs<T extends Object>(
      Expression<T> Function($$PatternConsumptionsTableAnnotationComposer a)
          f) {
    final $$PatternConsumptionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.patternConsumptions,
            getReferencedColumn: (t) => t.patternId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PatternConsumptionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.patternConsumptions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PatternsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PatternsTable,
    Pattern,
    $$PatternsTableFilterComposer,
    $$PatternsTableOrderingComposer,
    $$PatternsTableAnnotationComposer,
    $$PatternsTableCreateCompanionBuilder,
    $$PatternsTableUpdateCompanionBuilder,
    (Pattern, $$PatternsTableReferences),
    Pattern,
    PrefetchHooks Function(
        {bool inventoryLogsRefs, bool patternConsumptionsRefs})> {
  $$PatternsTableTableManager(_$AppDatabase db, $PatternsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatternsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatternsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatternsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> originalImage = const Value.absent(),
            Value<DateTime> uploadTime = const Value.absent(),
            Value<DateTime?> completeTime = const Value.absent(),
            Value<String?> completePhotos = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatternsCompanion(
            id: id,
            title: title,
            originalImage: originalImage,
            uploadTime: uploadTime,
            completeTime: completeTime,
            completePhotos: completePhotos,
            status: status,
            source: source,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String originalImage,
            required DateTime uploadTime,
            Value<DateTime?> completeTime = const Value.absent(),
            Value<String?> completePhotos = const Value.absent(),
            Value<String> status = const Value.absent(),
            required String source,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatternsCompanion.insert(
            id: id,
            title: title,
            originalImage: originalImage,
            uploadTime: uploadTime,
            completeTime: completeTime,
            completePhotos: completePhotos,
            status: status,
            source: source,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PatternsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {inventoryLogsRefs = false, patternConsumptionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (inventoryLogsRefs) db.inventoryLogs,
                if (patternConsumptionsRefs) db.patternConsumptions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (inventoryLogsRefs)
                    await $_getPrefetchedData<Pattern, $PatternsTable,
                            InventoryLog>(
                        currentTable: table,
                        referencedTable: $$PatternsTableReferences
                            ._inventoryLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PatternsTableReferences(db, table, p0)
                                .inventoryLogsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.patternId == item.id),
                        typedResults: items),
                  if (patternConsumptionsRefs)
                    await $_getPrefetchedData<Pattern, $PatternsTable,
                            PatternConsumption>(
                        currentTable: table,
                        referencedTable: $$PatternsTableReferences
                            ._patternConsumptionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PatternsTableReferences(db, table, p0)
                                .patternConsumptionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.patternId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PatternsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PatternsTable,
    Pattern,
    $$PatternsTableFilterComposer,
    $$PatternsTableOrderingComposer,
    $$PatternsTableAnnotationComposer,
    $$PatternsTableCreateCompanionBuilder,
    $$PatternsTableUpdateCompanionBuilder,
    (Pattern, $$PatternsTableReferences),
    Pattern,
    PrefetchHooks Function(
        {bool inventoryLogsRefs, bool patternConsumptionsRefs})>;
typedef $$InventoryLogsTableCreateCompanionBuilder = InventoryLogsCompanion
    Function({
  Value<int> id,
  required int colorId,
  required String changeType,
  required int quantity,
  required int resultQty,
  Value<String?> patternId,
  Value<DateTime> createdAt,
});
typedef $$InventoryLogsTableUpdateCompanionBuilder = InventoryLogsCompanion
    Function({
  Value<int> id,
  Value<int> colorId,
  Value<String> changeType,
  Value<int> quantity,
  Value<int> resultQty,
  Value<String?> patternId,
  Value<DateTime> createdAt,
});

final class $$InventoryLogsTableReferences
    extends BaseReferences<_$AppDatabase, $InventoryLogsTable, InventoryLog> {
  $$InventoryLogsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ColorStandardsTable _colorIdTable(_$AppDatabase db) =>
      db.colorStandards.createAlias($_aliasNameGenerator(
          db.inventoryLogs.colorId, db.colorStandards.colorId));

  $$ColorStandardsTableProcessedTableManager get colorId {
    final $_column = $_itemColumn<int>('color_id')!;

    final manager = $$ColorStandardsTableTableManager($_db, $_db.colorStandards)
        .filter((f) => f.colorId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_colorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PatternsTable _patternIdTable(_$AppDatabase db) =>
      db.patterns.createAlias(
          $_aliasNameGenerator(db.inventoryLogs.patternId, db.patterns.id));

  $$PatternsTableProcessedTableManager? get patternId {
    final $_column = $_itemColumn<String>('pattern_id');
    if ($_column == null) return null;
    final manager = $$PatternsTableTableManager($_db, $_db.patterns)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patternIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InventoryLogsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryLogsTable> {
  $$InventoryLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changeType => $composableBuilder(
      column: $table.changeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get resultQty => $composableBuilder(
      column: $table.resultQty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ColorStandardsTableFilterComposer get colorId {
    final $$ColorStandardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.colorId,
        referencedTable: $db.colorStandards,
        getReferencedColumn: (t) => t.colorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ColorStandardsTableFilterComposer(
              $db: $db,
              $table: $db.colorStandards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PatternsTableFilterComposer get patternId {
    final $$PatternsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patternId,
        referencedTable: $db.patterns,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatternsTableFilterComposer(
              $db: $db,
              $table: $db.patterns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryLogsTable> {
  $$InventoryLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changeType => $composableBuilder(
      column: $table.changeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get resultQty => $composableBuilder(
      column: $table.resultQty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ColorStandardsTableOrderingComposer get colorId {
    final $$ColorStandardsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.colorId,
        referencedTable: $db.colorStandards,
        getReferencedColumn: (t) => t.colorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ColorStandardsTableOrderingComposer(
              $db: $db,
              $table: $db.colorStandards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PatternsTableOrderingComposer get patternId {
    final $$PatternsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patternId,
        referencedTable: $db.patterns,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatternsTableOrderingComposer(
              $db: $db,
              $table: $db.patterns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryLogsTable> {
  $$InventoryLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get changeType => $composableBuilder(
      column: $table.changeType, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get resultQty =>
      $composableBuilder(column: $table.resultQty, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ColorStandardsTableAnnotationComposer get colorId {
    final $$ColorStandardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.colorId,
        referencedTable: $db.colorStandards,
        getReferencedColumn: (t) => t.colorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ColorStandardsTableAnnotationComposer(
              $db: $db,
              $table: $db.colorStandards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PatternsTableAnnotationComposer get patternId {
    final $$PatternsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patternId,
        referencedTable: $db.patterns,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatternsTableAnnotationComposer(
              $db: $db,
              $table: $db.patterns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryLogsTable,
    InventoryLog,
    $$InventoryLogsTableFilterComposer,
    $$InventoryLogsTableOrderingComposer,
    $$InventoryLogsTableAnnotationComposer,
    $$InventoryLogsTableCreateCompanionBuilder,
    $$InventoryLogsTableUpdateCompanionBuilder,
    (InventoryLog, $$InventoryLogsTableReferences),
    InventoryLog,
    PrefetchHooks Function({bool colorId, bool patternId})> {
  $$InventoryLogsTableTableManager(_$AppDatabase db, $InventoryLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> colorId = const Value.absent(),
            Value<String> changeType = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> resultQty = const Value.absent(),
            Value<String?> patternId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InventoryLogsCompanion(
            id: id,
            colorId: colorId,
            changeType: changeType,
            quantity: quantity,
            resultQty: resultQty,
            patternId: patternId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int colorId,
            required String changeType,
            required int quantity,
            required int resultQty,
            Value<String?> patternId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InventoryLogsCompanion.insert(
            id: id,
            colorId: colorId,
            changeType: changeType,
            quantity: quantity,
            resultQty: resultQty,
            patternId: patternId,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InventoryLogsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({colorId = false, patternId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (colorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.colorId,
                    referencedTable:
                        $$InventoryLogsTableReferences._colorIdTable(db),
                    referencedColumn: $$InventoryLogsTableReferences
                        ._colorIdTable(db)
                        .colorId,
                  ) as T;
                }
                if (patternId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.patternId,
                    referencedTable:
                        $$InventoryLogsTableReferences._patternIdTable(db),
                    referencedColumn:
                        $$InventoryLogsTableReferences._patternIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InventoryLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InventoryLogsTable,
    InventoryLog,
    $$InventoryLogsTableFilterComposer,
    $$InventoryLogsTableOrderingComposer,
    $$InventoryLogsTableAnnotationComposer,
    $$InventoryLogsTableCreateCompanionBuilder,
    $$InventoryLogsTableUpdateCompanionBuilder,
    (InventoryLog, $$InventoryLogsTableReferences),
    InventoryLog,
    PrefetchHooks Function({bool colorId, bool patternId})>;
typedef $$PatternConsumptionsTableCreateCompanionBuilder
    = PatternConsumptionsCompanion Function({
  Value<int> id,
  required String patternId,
  required int colorId,
  required int quantity,
});
typedef $$PatternConsumptionsTableUpdateCompanionBuilder
    = PatternConsumptionsCompanion Function({
  Value<int> id,
  Value<String> patternId,
  Value<int> colorId,
  Value<int> quantity,
});

final class $$PatternConsumptionsTableReferences extends BaseReferences<
    _$AppDatabase, $PatternConsumptionsTable, PatternConsumption> {
  $$PatternConsumptionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PatternsTable _patternIdTable(_$AppDatabase db) =>
      db.patterns.createAlias($_aliasNameGenerator(
          db.patternConsumptions.patternId, db.patterns.id));

  $$PatternsTableProcessedTableManager get patternId {
    final $_column = $_itemColumn<String>('pattern_id')!;

    final manager = $$PatternsTableTableManager($_db, $_db.patterns)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patternIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ColorStandardsTable _colorIdTable(_$AppDatabase db) =>
      db.colorStandards.createAlias($_aliasNameGenerator(
          db.patternConsumptions.colorId, db.colorStandards.colorId));

  $$ColorStandardsTableProcessedTableManager get colorId {
    final $_column = $_itemColumn<int>('color_id')!;

    final manager = $$ColorStandardsTableTableManager($_db, $_db.colorStandards)
        .filter((f) => f.colorId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_colorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PatternConsumptionsTableFilterComposer
    extends Composer<_$AppDatabase, $PatternConsumptionsTable> {
  $$PatternConsumptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  $$PatternsTableFilterComposer get patternId {
    final $$PatternsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patternId,
        referencedTable: $db.patterns,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatternsTableFilterComposer(
              $db: $db,
              $table: $db.patterns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ColorStandardsTableFilterComposer get colorId {
    final $$ColorStandardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.colorId,
        referencedTable: $db.colorStandards,
        getReferencedColumn: (t) => t.colorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ColorStandardsTableFilterComposer(
              $db: $db,
              $table: $db.colorStandards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PatternConsumptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatternConsumptionsTable> {
  $$PatternConsumptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  $$PatternsTableOrderingComposer get patternId {
    final $$PatternsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patternId,
        referencedTable: $db.patterns,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatternsTableOrderingComposer(
              $db: $db,
              $table: $db.patterns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ColorStandardsTableOrderingComposer get colorId {
    final $$ColorStandardsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.colorId,
        referencedTable: $db.colorStandards,
        getReferencedColumn: (t) => t.colorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ColorStandardsTableOrderingComposer(
              $db: $db,
              $table: $db.colorStandards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PatternConsumptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatternConsumptionsTable> {
  $$PatternConsumptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  $$PatternsTableAnnotationComposer get patternId {
    final $$PatternsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patternId,
        referencedTable: $db.patterns,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatternsTableAnnotationComposer(
              $db: $db,
              $table: $db.patterns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ColorStandardsTableAnnotationComposer get colorId {
    final $$ColorStandardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.colorId,
        referencedTable: $db.colorStandards,
        getReferencedColumn: (t) => t.colorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ColorStandardsTableAnnotationComposer(
              $db: $db,
              $table: $db.colorStandards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PatternConsumptionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PatternConsumptionsTable,
    PatternConsumption,
    $$PatternConsumptionsTableFilterComposer,
    $$PatternConsumptionsTableOrderingComposer,
    $$PatternConsumptionsTableAnnotationComposer,
    $$PatternConsumptionsTableCreateCompanionBuilder,
    $$PatternConsumptionsTableUpdateCompanionBuilder,
    (PatternConsumption, $$PatternConsumptionsTableReferences),
    PatternConsumption,
    PrefetchHooks Function({bool patternId, bool colorId})> {
  $$PatternConsumptionsTableTableManager(
      _$AppDatabase db, $PatternConsumptionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatternConsumptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatternConsumptionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatternConsumptionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> patternId = const Value.absent(),
            Value<int> colorId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
          }) =>
              PatternConsumptionsCompanion(
            id: id,
            patternId: patternId,
            colorId: colorId,
            quantity: quantity,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String patternId,
            required int colorId,
            required int quantity,
          }) =>
              PatternConsumptionsCompanion.insert(
            id: id,
            patternId: patternId,
            colorId: colorId,
            quantity: quantity,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PatternConsumptionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({patternId = false, colorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (patternId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.patternId,
                    referencedTable: $$PatternConsumptionsTableReferences
                        ._patternIdTable(db),
                    referencedColumn: $$PatternConsumptionsTableReferences
                        ._patternIdTable(db)
                        .id,
                  ) as T;
                }
                if (colorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.colorId,
                    referencedTable:
                        $$PatternConsumptionsTableReferences._colorIdTable(db),
                    referencedColumn: $$PatternConsumptionsTableReferences
                        ._colorIdTable(db)
                        .colorId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PatternConsumptionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PatternConsumptionsTable,
    PatternConsumption,
    $$PatternConsumptionsTableFilterComposer,
    $$PatternConsumptionsTableOrderingComposer,
    $$PatternConsumptionsTableAnnotationComposer,
    $$PatternConsumptionsTableCreateCompanionBuilder,
    $$PatternConsumptionsTableUpdateCompanionBuilder,
    (PatternConsumption, $$PatternConsumptionsTableReferences),
    PatternConsumption,
    PrefetchHooks Function({bool patternId, bool colorId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ColorStandardsTableTableManager get colorStandards =>
      $$ColorStandardsTableTableManager(_db, _db.colorStandards);
  $$InventoryTableTableManager get inventory =>
      $$InventoryTableTableManager(_db, _db.inventory);
  $$PatternsTableTableManager get patterns =>
      $$PatternsTableTableManager(_db, _db.patterns);
  $$InventoryLogsTableTableManager get inventoryLogs =>
      $$InventoryLogsTableTableManager(_db, _db.inventoryLogs);
  $$PatternConsumptionsTableTableManager get patternConsumptions =>
      $$PatternConsumptionsTableTableManager(_db, _db.patternConsumptions);
}
