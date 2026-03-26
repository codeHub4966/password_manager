import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../core/encryption_service.dart';

part 'database.g.dart';

@DataClassName('PasswordEntry')
class PasswordEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get siteName => text()();
  TextColumn get username => text()();
  TextColumn get encryptedPassword => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get securityQuestion => text().nullable()();
  
  // NEW FIELDS: Category and Last Modified
  TextColumn get category => text().withDefault(const Constant('Other'))();
  DateTimeColumn get lastModified => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [PasswordEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // Bumped version for new features

  // --- CRUD OPERATIONS ---
  Stream<List<PasswordEntry>> watchAllEntries() => select(passwordEntries).watch();
  Future<int> addEntry(PasswordEntriesCompanion entry) => into(passwordEntries).insert(entry);
  Future<bool> updateEntry(PasswordEntry entry) => update(passwordEntries).replace(entry);
  Future<int> deleteEntry(PasswordEntry entry) => delete(passwordEntries).delete(entry);

  // --- MOCK DATA ---
  Future<void> seedInitialData() async {
    final count = await select(passwordEntries).get();
    if (count.isEmpty) {
      await batch((batch) {
        batch.insertAll(passwordEntries, [
          // WEAK: length 7, 1 criteria (numbers)
          _createMock('University Portal', 'student123', 'pass123', 'Main login', 'Work', 'First pet name? Max'),
          // STRONG: length 12, 4 criteria
          _createMock('Maybank', 'user_bank', 'MoneySave\$20', 'Do not share', 'Banking', 'Mother maiden name? Smith'),
          // FAIR: length 12, 3 criteria (no symbols)
          _createMock('Instagram', 'cool_user', 'PhotoGram123', 'Private account', 'Social', 'Childhood hero? Batman'),
          // WEAK: length 5, 0 criteria
          _createMock('Google', 'user@gmail.com', 'hello', 'Primary email', 'Other', 'Favorite color? Blue'),
          // STRONG: length 14, 4 criteria
          _createMock('GitHub', 'dev_student', 'CommitPush123!', 'Repo access', 'Work', 'First car? Civic'),
        ]);
      });
    }
  }

  PasswordEntriesCompanion _createMock(String site, String user, String pass, String note, String category, String sq) {
    return PasswordEntriesCompanion.insert(
      siteName: site,
      username: user,
      encryptedPassword: EncryptionService.encryptData(pass),
      notes: Value(note),
      category: Value(category),
      securityQuestion: Value(sq),
      lastModified: Value(DateTime.now()),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vaultify.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}