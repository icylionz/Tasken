import 'package:tasken/dbms/databasehandler.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Log {
  @Id()
  int? id;
  LogCode code;
  String description;
  DateTime? dateCreated;
  Log(
      {this.id,
      this.code = LogCode.MISC,
      required this.description,
      this.dateCreated});

  Future<bool> log() async {
    final logDB = await TaskenDatabase.logDB;
    return await logDB.box<Log>().putAsync(this) > 0 ? true : false;
  }

  int? get dbCode {
    return code.index;
  }

  set dbCode(int? value) {
    code = value != null && value >= 0 && value < LogCode.values.length
        ? LogCode.values[value]
        : LogCode.MISC;
  }
}

enum LogCode {
  MISC, //Uncategorized action
  WDATA, // Writing data to database
  UDATA, // Updating data to database
  RDATA, // Reading data to database
  DDATA, // Deleting data to database
  START, // Starting job
  STOP, // Stopping job
  PAUSE, // Pausing job
  UPREF, // Update Preferences
  RESETPREF, // Reset preferences
  RESETLOG, // Reset logs
}
