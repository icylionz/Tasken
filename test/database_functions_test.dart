import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasken/dbms/databasehandler.dart';
import 'package:tasken/models/models.dart';
import 'package:path/path.dart';

void main() async {
  setUp(() async {
    Directory(join(Directory.current.path, "storage", "mainDB"))
        .delete(recursive: true);
    TaskenDatabase.init();
  });
  test("Testing the Database functions - Insert", () async {
    int insertTestResult = await TaskenDatabase.insertMain(
        record: JobType(name: "Rad", description: "bruh"));
    expect(1, insertTestResult);
  });
}
