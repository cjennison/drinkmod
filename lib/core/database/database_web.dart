import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'drinkmod_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );
    
    // Return the resolved executor directly (it's already a DatabaseConnection)
    return result.resolvedExecutor;
  });
}
