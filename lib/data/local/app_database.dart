import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class CachedCompanies extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get pack => text().withDefault(const Constant('finishing'))();

  @override
  String get tableName => 'companies';

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedUsers extends Table {
  IntColumn get id => integer()();
  IntColumn get companyId => integer()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get role => text()();

  @override
  String get tableName => 'users_cache';

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedParties extends Table {
  IntColumn get id => integer()();
  IntColumn get companyId => integer().withDefault(const Constant(0))();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get kind => text().nullable()();
  TextColumn get openingBalance => text().withDefault(const Constant('0.00'))();
  TextColumn get agreementEstimate => text().nullable()();
  IntColumn get supervisionPercent => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  String get tableName => 'parties';

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedWorkTypes extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  String get tableName => 'work_types';

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedExpenseCategories extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  String get tableName => 'expense_categories';

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedEntries extends Table {
  IntColumn get id => integer()();
  IntColumn get customerId => integer()();
  TextColumn get entryDate => text()();
  TextColumn get entryType => text()();
  TextColumn get title => text()();
  TextColumn get amount => text().withDefault(const Constant('0.00'))();
  TextColumn get laborAmount => text().withDefault(const Constant('0.00'))();
  TextColumn get returnAmount => text().withDefault(const Constant('0.00'))();
  TextColumn get notes => text().nullable()();
  TextColumn get customerName => text().nullable()();

  @override
  String get tableName => 'journal_entries';

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedExpenses extends Table {
  IntColumn get id => integer()();
  IntColumn get categoryId => integer().nullable()();
  TextColumn get entryDate => text()();
  TextColumn get title => text()();
  TextColumn get amount => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get categoryName => text().nullable()();

  @override
  String get tableName => 'expenses';

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedJobs extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get qty => text()();
  TextColumn get unitPrice => text()();
  TextColumn get total => text()();
  TextColumn get paid => text()();
  TextColumn get remaining => text()();
  TextColumn get contractorName => text().nullable()();
  IntColumn get contractorId => integer().nullable()();

  @override
  String get tableName => 'jobs';

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedJobPayments extends Table {
  IntColumn get id => integer()();
  IntColumn get jobId => integer()();
  IntColumn get sequence => integer()();
  TextColumn get amount => text()();
  TextColumn get paidOn => text()();

  @override
  String get tableName => 'job_payments';

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get method => text()();
  TextColumn get path => text()();
  TextColumn get payload => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  String get tableName => 'sync_outbox';
}

@DriftDatabase(
  tables: [
    CachedCompanies,
    CachedUsers,
    CachedParties,
    CachedWorkTypes,
    CachedExpenseCategories,
    CachedEntries,
    CachedExpenses,
    CachedJobs,
    CachedJobPayments,
    SyncOutbox,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'shatbha'));

  @override
  int get schemaVersion => 1;

  Future<List<SyncOutboxData>> pendingOutbox() {
    return (select(syncOutbox)..where((t) => t.status.equals('pending'))).get();
  }

  Future<void> markOutbox(int id, String status) {
    return (update(syncOutbox)..where((t) => t.id.equals(id)))
        .write(SyncOutboxCompanion(status: Value(status)));
  }

  Future<int> enqueue(String method, String path, String payload) {
    return into(syncOutbox).insert(
      SyncOutboxCompanion.insert(
        method: method,
        path: path,
        payload: payload,
        createdAt: DateTime.now(),
      ),
    );
  }
}
