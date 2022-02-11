import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasken/dbms/databasehandler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }
  /* 
  - Clear the database
  */
  setUp(() async {
    List<String> usedTables = ["job_statuses"];
    for (var table in usedTables) {
      await TaskenSQLDatabase.delete(table: table);
    }
  });
  test("Testing the Database functions - Insert", () async {
    int? insertTestResult = await TaskenSQLDatabase.insert(
        table: "job_statuses",
        values: {"name": "bruh2", "description": "bruh bruh"});
    expect(1, insertTestResult);
  });
}
