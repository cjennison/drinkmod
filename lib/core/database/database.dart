import 'package:drift/drift.dart';

// Conditional imports based on platform
import 'database_stub.dart'
    if (dart.library.ffi) 'database_native.dart'
    if (dart.library.html) 'database_web.dart';

part 'database.g.dart';

// User profile table
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100).nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Drinking schedule configuration
class DrinkSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get scheduleType => text()(); // 'weekends', 'friday_only', 'custom', 'social'
  TextColumn get customDays => text().nullable()(); // JSON array for custom schedules
  IntColumn get dailyLimit => integer()(); // drinks per allowed day
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Individual drink entries/logs
class DrinkEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  DateTimeColumn get drinkDate => dateTime()();
  TextColumn get drinkName => text()();
  RealColumn get standardDrinks => real()(); // calculated standard drinks
  TextColumn get drinkType => text()(); // 'beer', 'wine', 'spirits', 'cocktail'
  TextColumn get reason => text().nullable()(); // why they drank
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Favorite drinks library
class FavoriteDrinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get name => text()();
  TextColumn get drinkType => text()();
  RealColumn get standardDrinks => real()();
  TextColumn get ingredients => text().nullable()(); // JSON or simple text
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Milestones and achievements
class Milestones extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get milestoneType => text()(); // 'preset', 'custom'
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get targetDays => integer()(); // days to achieve milestone
  TextColumn get reward => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Users, DrinkSchedules, DrinkEntries, FavoriteDrinks, Milestones])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );
}
