import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

import '../constants/app_constants.dart';
import 'tables/app_settings_table.dart';
import 'tables/budget_periods_table.dart';
import 'tables/planned_expenses_table.dart';
import 'tables/project_contributions_table.dart';
import 'tables/savings_projects_table.dart';
import 'tables/subscriptions_table.dart';
import 'tables/transactions_table.dart';
import 'tables/user_streaks_table.dart';

part 'app_database.g.dart';

/// Main application database with SQLCipher encryption.
///
/// Uses drift for type-safe database access and SQLCipher for AES-256 encryption.
/// All monetary values are stored as integers (FCFA).
@DriftDatabase(tables: [BudgetPeriods, AppSettings, Transactions, Subscriptions, PlannedExpenses, UserStreaks, SavingsProjects, ProjectContributions])
class AppDatabase extends _$AppDatabase {
  /// Creates an encrypted database instance.
  ///
  /// The [encryptionKey] is used for SQLCipher AES-256 encryption.
  /// Key should be retrieved from secure storage (Android Keystore).
  AppDatabase({required String encryptionKey})
      : super(_openConnection(encryptionKey));

  /// Creates an in-memory database for testing.
  ///
  /// No encryption is used in test mode.
  AppDatabase.inMemory() : super(_openInMemoryConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migration from version 1 to 2: Add transactions table
        if (from < 2) {
          await m.createTable(transactions);
        }
        // Migration from version 2 to 3: Add subscriptions table
        if (from < 3) {
          await m.createTable(subscriptions);
        }
        // Migration from version 3 to 4: Add planned_expenses table
        if (from < 4) {
          await m.createTable(plannedExpenses);
        }
        // Migration from version 4 to 5: Add user_streaks table
        if (from < 5) {
          await m.createTable(userStreaks);
        }
        // Migration from version 5 to 6: Add savings projects tables
        if (from < 6) {
          await m.createTable(savingsProjects);
          await m.createTable(projectContributions);
        }
      },
    );
  }
}

/// Opens an encrypted database connection using SQLCipher.
LazyDatabase _openConnection(String encryptionKey) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));

    return NativeDatabase(
      file,
      setup: (db) {
        // Set the encryption key using PRAGMA
        db.execute("PRAGMA key = '$encryptionKey'");
      },
    );
  });
}

/// Opens an in-memory database for testing (no encryption).
LazyDatabase _openInMemoryConnection() {
  return LazyDatabase(() async {
    return NativeDatabase.memory();
  });
}

/// Sets up SQLCipher libraries for the current platform.
Future<void> setupSqlCipher() async {
  if (Platform.isAndroid) {
    // On Android, we need to open SQLCipher libraries
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
  }
}
