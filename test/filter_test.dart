import 'package:flutter_test/flutter_test.dart';
import 'package:tasken/Tools/customtools.dart';
import 'package:tasken/dbms/databasehandler.dart';
import 'dart:io';
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
  - Insert new values
  */
  setUp(() async {
    await TaskenSQLDatabase.reset();

    await TaskenSQLDatabase.insert(
        table: "job_statuses", values: {"name": "bruh", "description": "bruh"});
    await TaskenSQLDatabase.insert(
        table: "job_statuses",
        values: {"name": "bruh2", "description": "bruh bruh"});
  });
  test("Testing the effectiveness of the filter", () async {
    expect(
        await TaskenSQLDatabase.query("job_statuses",
            filters: [Filter("description", MathSign.contains, "%bruh bruh%")]),
        [
          {"id": 2, "name": "bruh2", "description": "bruh bruh"}
        ]);
  });
}
