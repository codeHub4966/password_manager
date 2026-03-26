// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PasswordEntriesTable extends PasswordEntries
    with TableInfo<$PasswordEntriesTable, PasswordEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PasswordEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _siteNameMeta = const VerificationMeta(
    'siteName',
  );
  @override
  late final GeneratedColumn<String> siteName = GeneratedColumn<String>(
    'site_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedPasswordMeta = const VerificationMeta(
    'encryptedPassword',
  );
  @override
  late final GeneratedColumn<String> encryptedPassword =
      GeneratedColumn<String>(
        'encrypted_password',
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
  static const VerificationMeta _securityQuestionMeta = const VerificationMeta(
    'securityQuestion',
  );
  @override
  late final GeneratedColumn<String> securityQuestion = GeneratedColumn<String>(
    'security_question',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Other'),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    siteName,
    username,
    encryptedPassword,
    notes,
    securityQuestion,
    category,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'password_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PasswordEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('site_name')) {
      context.handle(
        _siteNameMeta,
        siteName.isAcceptableOrUnknown(data['site_name']!, _siteNameMeta),
      );
    } else if (isInserting) {
      context.missing(_siteNameMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('encrypted_password')) {
      context.handle(
        _encryptedPasswordMeta,
        encryptedPassword.isAcceptableOrUnknown(
          data['encrypted_password']!,
          _encryptedPasswordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedPasswordMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('security_question')) {
      context.handle(
        _securityQuestionMeta,
        securityQuestion.isAcceptableOrUnknown(
          data['security_question']!,
          _securityQuestionMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PasswordEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PasswordEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      siteName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_name'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      encryptedPassword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_password'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      securityQuestion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}security_question'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $PasswordEntriesTable createAlias(String alias) {
    return $PasswordEntriesTable(attachedDatabase, alias);
  }
}

class PasswordEntry extends DataClass implements Insertable<PasswordEntry> {
  final int id;
  final String siteName;
  final String username;
  final String encryptedPassword;
  final String? notes;
  final String? securityQuestion;
  final String category;
  final DateTime lastModified;
  const PasswordEntry({
    required this.id,
    required this.siteName,
    required this.username,
    required this.encryptedPassword,
    this.notes,
    this.securityQuestion,
    required this.category,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['site_name'] = Variable<String>(siteName);
    map['username'] = Variable<String>(username);
    map['encrypted_password'] = Variable<String>(encryptedPassword);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || securityQuestion != null) {
      map['security_question'] = Variable<String>(securityQuestion);
    }
    map['category'] = Variable<String>(category);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  PasswordEntriesCompanion toCompanion(bool nullToAbsent) {
    return PasswordEntriesCompanion(
      id: Value(id),
      siteName: Value(siteName),
      username: Value(username),
      encryptedPassword: Value(encryptedPassword),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      securityQuestion: securityQuestion == null && nullToAbsent
          ? const Value.absent()
          : Value(securityQuestion),
      category: Value(category),
      lastModified: Value(lastModified),
    );
  }

  factory PasswordEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PasswordEntry(
      id: serializer.fromJson<int>(json['id']),
      siteName: serializer.fromJson<String>(json['siteName']),
      username: serializer.fromJson<String>(json['username']),
      encryptedPassword: serializer.fromJson<String>(json['encryptedPassword']),
      notes: serializer.fromJson<String?>(json['notes']),
      securityQuestion: serializer.fromJson<String?>(json['securityQuestion']),
      category: serializer.fromJson<String>(json['category']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'siteName': serializer.toJson<String>(siteName),
      'username': serializer.toJson<String>(username),
      'encryptedPassword': serializer.toJson<String>(encryptedPassword),
      'notes': serializer.toJson<String?>(notes),
      'securityQuestion': serializer.toJson<String?>(securityQuestion),
      'category': serializer.toJson<String>(category),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  PasswordEntry copyWith({
    int? id,
    String? siteName,
    String? username,
    String? encryptedPassword,
    Value<String?> notes = const Value.absent(),
    Value<String?> securityQuestion = const Value.absent(),
    String? category,
    DateTime? lastModified,
  }) => PasswordEntry(
    id: id ?? this.id,
    siteName: siteName ?? this.siteName,
    username: username ?? this.username,
    encryptedPassword: encryptedPassword ?? this.encryptedPassword,
    notes: notes.present ? notes.value : this.notes,
    securityQuestion: securityQuestion.present
        ? securityQuestion.value
        : this.securityQuestion,
    category: category ?? this.category,
    lastModified: lastModified ?? this.lastModified,
  );
  PasswordEntry copyWithCompanion(PasswordEntriesCompanion data) {
    return PasswordEntry(
      id: data.id.present ? data.id.value : this.id,
      siteName: data.siteName.present ? data.siteName.value : this.siteName,
      username: data.username.present ? data.username.value : this.username,
      encryptedPassword: data.encryptedPassword.present
          ? data.encryptedPassword.value
          : this.encryptedPassword,
      notes: data.notes.present ? data.notes.value : this.notes,
      securityQuestion: data.securityQuestion.present
          ? data.securityQuestion.value
          : this.securityQuestion,
      category: data.category.present ? data.category.value : this.category,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PasswordEntry(')
          ..write('id: $id, ')
          ..write('siteName: $siteName, ')
          ..write('username: $username, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('notes: $notes, ')
          ..write('securityQuestion: $securityQuestion, ')
          ..write('category: $category, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    siteName,
    username,
    encryptedPassword,
    notes,
    securityQuestion,
    category,
    lastModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PasswordEntry &&
          other.id == this.id &&
          other.siteName == this.siteName &&
          other.username == this.username &&
          other.encryptedPassword == this.encryptedPassword &&
          other.notes == this.notes &&
          other.securityQuestion == this.securityQuestion &&
          other.category == this.category &&
          other.lastModified == this.lastModified);
}

class PasswordEntriesCompanion extends UpdateCompanion<PasswordEntry> {
  final Value<int> id;
  final Value<String> siteName;
  final Value<String> username;
  final Value<String> encryptedPassword;
  final Value<String?> notes;
  final Value<String?> securityQuestion;
  final Value<String> category;
  final Value<DateTime> lastModified;
  const PasswordEntriesCompanion({
    this.id = const Value.absent(),
    this.siteName = const Value.absent(),
    this.username = const Value.absent(),
    this.encryptedPassword = const Value.absent(),
    this.notes = const Value.absent(),
    this.securityQuestion = const Value.absent(),
    this.category = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  PasswordEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String siteName,
    required String username,
    required String encryptedPassword,
    this.notes = const Value.absent(),
    this.securityQuestion = const Value.absent(),
    this.category = const Value.absent(),
    this.lastModified = const Value.absent(),
  }) : siteName = Value(siteName),
       username = Value(username),
       encryptedPassword = Value(encryptedPassword);
  static Insertable<PasswordEntry> custom({
    Expression<int>? id,
    Expression<String>? siteName,
    Expression<String>? username,
    Expression<String>? encryptedPassword,
    Expression<String>? notes,
    Expression<String>? securityQuestion,
    Expression<String>? category,
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteName != null) 'site_name': siteName,
      if (username != null) 'username': username,
      if (encryptedPassword != null) 'encrypted_password': encryptedPassword,
      if (notes != null) 'notes': notes,
      if (securityQuestion != null) 'security_question': securityQuestion,
      if (category != null) 'category': category,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  PasswordEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? siteName,
    Value<String>? username,
    Value<String>? encryptedPassword,
    Value<String?>? notes,
    Value<String?>? securityQuestion,
    Value<String>? category,
    Value<DateTime>? lastModified,
  }) {
    return PasswordEntriesCompanion(
      id: id ?? this.id,
      siteName: siteName ?? this.siteName,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      notes: notes ?? this.notes,
      securityQuestion: securityQuestion ?? this.securityQuestion,
      category: category ?? this.category,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (siteName.present) {
      map['site_name'] = Variable<String>(siteName.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (encryptedPassword.present) {
      map['encrypted_password'] = Variable<String>(encryptedPassword.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (securityQuestion.present) {
      map['security_question'] = Variable<String>(securityQuestion.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PasswordEntriesCompanion(')
          ..write('id: $id, ')
          ..write('siteName: $siteName, ')
          ..write('username: $username, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('notes: $notes, ')
          ..write('securityQuestion: $securityQuestion, ')
          ..write('category: $category, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PasswordEntriesTable passwordEntries = $PasswordEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [passwordEntries];
}

typedef $$PasswordEntriesTableCreateCompanionBuilder =
    PasswordEntriesCompanion Function({
      Value<int> id,
      required String siteName,
      required String username,
      required String encryptedPassword,
      Value<String?> notes,
      Value<String?> securityQuestion,
      Value<String> category,
      Value<DateTime> lastModified,
    });
typedef $$PasswordEntriesTableUpdateCompanionBuilder =
    PasswordEntriesCompanion Function({
      Value<int> id,
      Value<String> siteName,
      Value<String> username,
      Value<String> encryptedPassword,
      Value<String?> notes,
      Value<String?> securityQuestion,
      Value<String> category,
      Value<DateTime> lastModified,
    });

class $$PasswordEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PasswordEntriesTable> {
  $$PasswordEntriesTableFilterComposer({
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

  ColumnFilters<String> get siteName => $composableBuilder(
    column: $table.siteName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get securityQuestion => $composableBuilder(
    column: $table.securityQuestion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PasswordEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PasswordEntriesTable> {
  $$PasswordEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get siteName => $composableBuilder(
    column: $table.siteName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get securityQuestion => $composableBuilder(
    column: $table.securityQuestion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PasswordEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PasswordEntriesTable> {
  $$PasswordEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get siteName =>
      $composableBuilder(column: $table.siteName, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get securityQuestion => $composableBuilder(
    column: $table.securityQuestion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );
}

class $$PasswordEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PasswordEntriesTable,
          PasswordEntry,
          $$PasswordEntriesTableFilterComposer,
          $$PasswordEntriesTableOrderingComposer,
          $$PasswordEntriesTableAnnotationComposer,
          $$PasswordEntriesTableCreateCompanionBuilder,
          $$PasswordEntriesTableUpdateCompanionBuilder,
          (
            PasswordEntry,
            BaseReferences<_$AppDatabase, $PasswordEntriesTable, PasswordEntry>,
          ),
          PasswordEntry,
          PrefetchHooks Function()
        > {
  $$PasswordEntriesTableTableManager(
    _$AppDatabase db,
    $PasswordEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PasswordEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PasswordEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PasswordEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> siteName = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> encryptedPassword = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> securityQuestion = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
              }) => PasswordEntriesCompanion(
                id: id,
                siteName: siteName,
                username: username,
                encryptedPassword: encryptedPassword,
                notes: notes,
                securityQuestion: securityQuestion,
                category: category,
                lastModified: lastModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String siteName,
                required String username,
                required String encryptedPassword,
                Value<String?> notes = const Value.absent(),
                Value<String?> securityQuestion = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
              }) => PasswordEntriesCompanion.insert(
                id: id,
                siteName: siteName,
                username: username,
                encryptedPassword: encryptedPassword,
                notes: notes,
                securityQuestion: securityQuestion,
                category: category,
                lastModified: lastModified,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PasswordEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PasswordEntriesTable,
      PasswordEntry,
      $$PasswordEntriesTableFilterComposer,
      $$PasswordEntriesTableOrderingComposer,
      $$PasswordEntriesTableAnnotationComposer,
      $$PasswordEntriesTableCreateCompanionBuilder,
      $$PasswordEntriesTableUpdateCompanionBuilder,
      (
        PasswordEntry,
        BaseReferences<_$AppDatabase, $PasswordEntriesTable, PasswordEntry>,
      ),
      PasswordEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PasswordEntriesTableTableManager get passwordEntries =>
      $$PasswordEntriesTableTableManager(_db, _db.passwordEntries);
}
