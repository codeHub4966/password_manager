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
    final currentData = await select(passwordEntries).get();
    
    // FIX: Auto-Heal corrupted "Decryption Error" data
    if (currentData.isNotEmpty) {
      try {
        final testDecrypt = EncryptionService.decryptData(currentData.first.encryptedPassword);
        if (testDecrypt == 'Decryption Error' || testDecrypt.isEmpty) {
          await delete(passwordEntries).go();
        }
      } catch (e) {
        await delete(passwordEntries).go();
      }
    }

    final count = await select(passwordEntries).get();
    if (count.isEmpty) {
      await batch((batch) {
        batch.insertAll(passwordEntries, [
          // WEAK: length 14, 1 criteria (lowercase only)
          _createMock('University Portal', 'student123', 'simplepassword', 'Main login', 'Work', 'First pet name? Max'),
          
          // STRONG: length 13, 4 criteria (Caps, lowercase, numbers, symbols)
          _createMock('Maybank', 'user_bank', 'Super\$ecure99!', 'Do not share', 'Banking', 'Mother maiden name? Smith'),
          
          // FAIR: length 12, 3 criteria (Caps, lowercase, numbers. NO symbols)
          _createMock('Instagram', 'cool_user', 'FairPass2026', 'Private account', 'Social', 'Childhood hero? Batman'),
          
          // WEAK: length 6, 2 criteria (Caps, lowercase, numbers, but length < 8)
          _createMock('Google', 'user@gmail.com', 'Goog1e', 'Primary email', 'Other', 'Favorite color? Blue'),
          
          // STRONG: length 11, 4 criteria (Caps, lowercase, numbers, symbols)
          _createMock('GitHub', 'dev_student', 'Dev#Code123', 'Repo access', 'Work', 'First car? Civic'),
        ]);
      });
    }
  }

  PasswordEntriesCompanion _createMock(String site, String user, String pass, String note, String category, String sq) {
    return PasswordEntriesCompanion.insert(
      siteName: site,
      username: user,
      // The password is encrypted here. Make sure the Master PIN is set before this runs!
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