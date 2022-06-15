import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:tasken/Tools/customtools.dart';
import 'package:tasken/models/models.dart';
import 'package:tasken/objectbox.g.dart';

class TaskenDatabase {
  static late final Store? mainStore;
  static late final Store? logStore;
  static late File? prefFile;
  static init() async {
    mainStore = await openStore(directory: join("storage", "mainDB"));

    logStore = await openStore(directory: join("storage", "logDB"));
  }

  static Future<Store> get mainDB async {
    Directory("storage").create(recursive: true);
    print("Initializing Main Store");
    mainStore ??= await openStore(directory: join("storage", "mainDB"));
    return mainStore!;
  }

  static Future<Store> get logDB async {
    Directory("storage").create(recursive: true);
    logStore ??= await openStore(directory: join("storage", "logDB"));
    return logStore!;
  }

  static Future<File?> get prefDB async {
    try {
      prefFile ??
          await File(join("storage", "preferences.json"))
              .create(recursive: true);
      await prefFile?.writeAsString(json.encode(Preferences.defaultPref));
    } catch (e) {
      throw Exception("Error creating file: ${e.toString()}");
    } finally {}
    return prefFile;
  }

// Reads json preferences and returns them
  static Future<Map<String, dynamic>> get preferences async {
    return await prefDB.then((value) async =>
        await value?.readAsString().then((value) => json.decode(value)) ??
        Preferences.defaultPref);
  }

  static set setPref(Map<String, dynamic> pref) {
    prefDB.then((file) => file?.writeAsString(json.encode(pref)).then((file) {
          prefFile = file;
        }));
  }

  static Future<int> insertMain({required dynamic record}) async {
    return getBoxMain(record)
        .then((box) => box.putAsync(record, mode: PutMode.insert));
  }

  static Future<int> updateMain({required Object record}) async {
    return getBoxMain(record)
        .then((box) => box.putAsync(record, mode: PutMode.put));
  }

  static Future<bool> deleteMain(
      {required Object record, required int recordID}) async {
    return getBoxMain(record).then((box) => box.remove(recordID));
  }

  static Future<List<dynamic>> getRecords(
      {required Box<Object> box,
      Filter? filter,
      int limit = 10,
      int offset = 0}) async {
    final QueryBuilder<Object> queryBuilder = box.query(filter?.condition)
      ..order(filter?.orderBy, flags: filter?.order ?? 0);
    final Query query = queryBuilder.build();
    query
      ..limit = limit
      ..offset = offset;
    return query.find();
  }

  static Future<Box<Object>> getBoxMain(record) async {
    final db = await mainDB;
    return record is Invoice
        ? db.box<Invoice>()
        : record is InvoiceStatus
            ? db.box<InvoiceStatus>()
            : record is Report
                ? db.box<Report>()
                : record is Job
                    ? db.box<Job>()
                    : record is JobStatus
                        ? db.box<JobStatus>()
                        : record is Session
                            ? db.box<Session>()
                            : record is JobType
                                ? db.box<JobType>()
                                : record is Client
                                    ? db.box<Client>()
                                    : db.box<Representative>();
  }
}
