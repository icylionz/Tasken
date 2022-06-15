import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:pdf/widgets.dart' as pdf;
import 'package:objectbox/objectbox.dart';
import 'package:system_tray/system_tray.dart';
import 'package:tasken/Tools/customtools.dart';
import 'package:tasken/dbms/databasehandler.dart';

/*@JsonSerializable()*/
@Entity()
class Invoice {
  @Id()
  int? id;
  String? name;
  DateTime? dateCreated;
  String? currency;
  dynamic status = ToOne<InvoiceStatus>();
  List<Job>? jobs = ToMany<Job>();
  String? notes;
  double taxRate = 0;
  Invoice(
      {this.id,
      this.name,
      this.dateCreated,
      this.currency,
      this.notes,
      this.jobs,
      this.status,this.taxRate = 0});

  edit(
      {int? id,
      String? name,
      DateTime? dateCreated,
      String? currency,
      InvoiceStatus? status,
      List<Job>? jobs,
      String? notes}) {
    id != null ? this.id = id : null;
    name != null ? this.name = name : null;
    dateCreated != null ? this.dateCreated = dateCreated : null;
    currency != null ? this.currency = currency : null;
    status != null ? this.status = status : null;
    jobs != null ? this.jobs = jobs : null;
    notes != null ? this.notes = notes : null;
    save();
  }

  Future<bool>? delete() async => id != null
      ? await TaskenDatabase.deleteMain(record: this, recordID: id!)
          .then((value) => value)
      : false;

  addJobs(List<Job> jobs) {
    //Insert
    jobs.addAll(jobs);
    save();
  }

  removeJobs({List<int>? indexes, List<Job>? jobs}) {
    if (indexes != null) {
      indexes.map((index) {
        this.jobs?.removeAt(index);
      });
    } else if (jobs != null) {
      jobs.map((job) {
        this.jobs?.remove(job);
      });
    }
    save();
  }

  save() {
    TaskenDatabase.updateMain(record: this);
  }

  pdf.Document createInvoicePDF() {
    final invoicePDF = pdf.Document();

    invoicePDF.addPage(pdf.Page(
      build: (context) => pdf.Column(children: [
        pdf.SizedBox(
            child: pdf.Row(
          children: [
            pdf.Text("INVOICE"),
            pdf.Image(pdf.MemoryImage(File("")
                .readAsBytesSync())), // TODO: Place the logo path from settings
          ],
        )),
        pdf.SizedBox(
            child: pdf.Row(children: [
          pdf.RichText(
              // TODO: place company info from settings into spans
              text: const pdf.TextSpan(children: [
            pdf.TextSpan(text: ""),
            pdf.TextSpan(text: ""),
            pdf.TextSpan(text: ""),
            pdf.TextSpan(text: ""),
            pdf.TextSpan(text: ""),
          ])),
          pdf.RichText(
              text: pdf.TextSpan(
                  style: pdf.TextStyle(
                      fontWeight: pdf.FontWeight.bold,
                      decoration: pdf.TextDecoration.underline),
                  children: [
                pdf.TextSpan(
                    text:
                        "${DateTime.now().toLocal().year} - ${DateTime.now().toLocal().month} - ${DateTime.now().toLocal().day}"),
                pdf.TextSpan(text: "Invoice #${id.toString()}")
              ]))
        ])),
      ]),
    ));

    return invoicePDF;
  }
}

/*@JsonSerializable()*/
@Entity()
class InvoiceStatus {
  @Id()
  int? id;
  String? name;
  String? description;
  InvoiceStatus({this.id, this.name, this.description});
  edit({int? id, String? name, String? description}) {
    id != null ? this.id = id : null;
    name != null ? this.name = name : null;
    description != null ? this.description = description : null;
    save();
  }

  Future<bool>? delete() async => id != null
      ? await TaskenDatabase.deleteMain(record: this, recordID: id!)
          .then((value) => value)
      : false;

  save() {
    TaskenDatabase.updateMain(record: this);
  }
}

/*@JsonSerializable()*/
@Entity()
class Report {
  @Id()
  int? id;
  DateTime? dateCreated;
  DateTime? minDateAccountFor;
  DateTime? maxDateAccountFor;
  String? notes;
  List<Job>? jobs = ToMany<Job>();
  Report(
      {this.id,
      this.dateCreated,
      this.minDateAccountFor,
      this.maxDateAccountFor,
      this.notes,
      this.jobs});
  edit(
      {int? id,
      DateTime? dateCreated,
      DateTime? minDateAccountFor,
      DateTime? maxDateAccountFor,
      List<Job>? jobs,
      String? notes}) {
    id != null ? this.id = id : null;
    dateCreated != null ? this.dateCreated = dateCreated : null;
    minDateAccountFor != null
        ? this.minDateAccountFor = minDateAccountFor
        : null;
    maxDateAccountFor != null
        ? this.maxDateAccountFor = maxDateAccountFor
        : null;
    jobs != null ? this.jobs = jobs : null;
    notes != null ? this.notes = notes : null;
    save();
  }

  Future<bool>? delete() async => id != null
      ? await TaskenDatabase.deleteMain(record: this, recordID: id!)
          .then((value) => value)
      : false;

  addJobs(List<Job> jobs) {
    //Insert
    jobs.addAll(jobs);
    save();
  }

  removeJobs({List<int>? indexes, List<Job>? jobs}) {
    if (indexes != null) {
      indexes.map((index) {
        this.jobs?.removeAt(index);
      });
    } else if (jobs != null) {
      jobs.map((job) {
        this.jobs?.remove(job);
      });
    }
    save();
  }

  save() {
    TaskenDatabase.updateMain(record: this);
  }

  pdf.Document createInvoicePDF() {
    final invoice = pdf.Document();
    invoice.addPage(pdf.Page(
      build: (context) => pdf.Column(children: []),
    ));
    return invoice;
  }
}

/*@JsonSerializable()*/
@Entity()
class JobStatus {
  @Id()
  int? id;
  String? name;
  String? description;
  JobStatus({this.id, this.name, this.description});

  edit({int? id, String? name, String? description}) {
    id != null ? this.id = id : null;
    name != null ? this.name = name : null;
    description != null ? this.description = description : null;
  }

  Future<bool>? delete() async => id != null
      ? await TaskenDatabase.deleteMain(record: this, recordID: id!)
          .then((value) => value)
      : false;
  save() {
    TaskenDatabase.updateMain(record: this);
  }
}

/*@JsonSerializable()*/
@Entity()
class Job {
  @Id()
  int? id;
  String? name;
  double? rate;
  double? flatRate;
  double? expenses;
  bool useFlatRate = false;
  DateTime? dateCreated;
  int? inactivityTimeoutPeriod;
  bool timerLocked = false;
  dynamic client = ToOne<Client>();
  dynamic status = ToOne<JobStatus>();
  dynamic type = ToOne<JobType>();
  dynamic assignedRepresentative = ToOne<Representative>();
  String? notes;

  @Transient()
  bool timerLoopRunning = false;
  @Transient()
  bool trayOpen = false;
  @Backlink('job')
  List<Session>? sessions = ToMany<Session>();
  Job(
      {this.id,
      this.name,
      this.rate,
      this.flatRate,
      this.expenses,
      this.useFlatRate = false,
      this.dateCreated,
      this.inactivityTimeoutPeriod,
      this.timerLocked = false,
      this.notes,
      this.client,
      this.status,
      this.type,
      this.assignedRepresentative,
      this.sessions}) {
    sessions ??= [];
  }

/* Fetches the Job Data from the sql database using the given {id} */

  /* Start Job Timer */

  startTimer() async {
    print("Starting Timer");
    /* Add a new session if the previous one has been stopped or there are no sessions */
    if (sessions!.isEmpty || sessions!.last.dateTimeEnded != null) {
      /* create new session */
      print("Creating session");
      sessions = [];
      sessions?.add(Session());
    }

    try {
      print("Start session");
      sessions?.last
          .startTimer(inactivityTimeoutPeriod: inactivityTimeoutPeriod ?? 0);
    } catch (e) {
      throw const TimerException(
          "Inactivity Timeout Functionality not available. Please contact the developers or reinstall the app.");
    }

    /* Open system tray icon */
    if (!trayOpen) {
      print("Opening Tray");
      trayOpen = true;
      compute(startTray(), null);
    }
  }

  pauseTimer() {
    sessions?.last.pauseTimer();
    save();
  }

  stopTimer() {
    sessions?.last.stopTimer();
    save();
  }

  edit(
      {int? id,
      String? name,
      double? rate,
      double? flatRate,
      bool? useFlatRate,
      DateTime? dateCreated,
      int? inactivityTimeoutPeriod,
      bool? timerLocked,
      Client? client,
      JobStatus? status,
      JobType? type,
      Representative? assignedRepresentative,
      String? notes,
      List<Session>? sessions}) {
    id != null ? this.id = id : null;
    name != null ? this.name = name : null;
    rate != null ? this.rate = rate : null;
    flatRate != null ? this.flatRate = flatRate : null;
    useFlatRate != null ? this.useFlatRate = useFlatRate : null;
    dateCreated != null ? this.dateCreated = dateCreated : null;
    inactivityTimeoutPeriod != null
        ? this.inactivityTimeoutPeriod = inactivityTimeoutPeriod
        : null;
    timerLocked != null ? this.timerLocked = timerLocked : null;
    client != null ? this.client = client : null;
    status != null ? this.status = status : null;
    type != null ? this.type = type : null;
    assignedRepresentative != null
        ? this.assignedRepresentative = assignedRepresentative
        : null;
    notes != null ? this.notes = notes : null;
    sessions != null ? this.sessions = sessions : null;
    save();
  }

  Future<bool>? delete() async => id != null
      ? await TaskenDatabase.deleteMain(record: this, recordID: id!)
          .then((value) => value)
      : false;
  save() {
    TaskenDatabase.updateMain(record: this);
  }

  startTray() async {
    SystemTray systemTray = SystemTray();
    await systemTray.initSystemTray(
      title: "system tray",
      iconPath:
          "C:/Users/Uwi/Documents/Computer_projects/Tasken/App/tasken/assets/app_icon.ico",
    );

    systemTray.registerSystemTrayEventHandler(((eventName) async {
      if (eventName == "leftMouseUp") {
        await systemTray.setContextMenu([
          MenuItem(
            label:
                "Time: ${Duration(milliseconds: sessions!.last.stopwatch!.totalMilliseconds).toString()}",
          ),
          MenuItem(
              label: sessions!.last.stopwatch!.isRunning ? "Pause" : "Play",
              onClicked: () {
                print("pause timer");
                sessions!.last.stopwatch!.isRunning
                    ? pauseTimer()
                    : startTimer();
              }),
          MenuItem(label: "Open", onClicked: () => appWindow.show()),
        ]);
        systemTray.popUpContextMenu();
      }
    }));
  }

  /* -- Useless until solution found (See clickup task #1vdyabh) 
  _runUpdateTimeLoop(SystemTray systemTray) async {
    print("starting loop");

    while (true) {
      await systemTray.setContextMenu([
        MenuItem(
          label:
              "Time: ${Duration(milliseconds: sessions!.last.stopwatch!.totalMilliseconds).toString()}",
        ),
        MenuItem(
            label: sessions!.last.stopwatch!.isRunning ? "Pause" : "Play",
            onClicked: () => pauseTimer()),
        MenuItem(label: "Open", onClicked: () => appWindow.show()),
      ]);
      if (!sessions!.last.stopwatch!.isRunning) {
        // stop update loop if timer is not running
        break;
      }
      if (!timerLoopRunning) break;
    }
    timerLoopRunning = false;
  } */
}

/*@JsonSerializable()*/
@Entity()
class Session {
  @Id()
  int? id;
  dynamic job = ToOne<Job>();
  int timeElapsed = 0;
  @Transient()
  CustomStopwatch? stopwatch;
  DateTime? dateTimeEnded;
  DateTime? dateTimeStarted;

  Session(
      {this.id,
      this.dateTimeEnded,
      this.dateTimeStarted,
      this.job,
      this.timeElapsed = 0,
      this.stopwatch}) {
    stopwatch ??= CustomStopwatch(initialMilliseconds: timeElapsed);
  }

  /* Start Session Timer */
  startTimer({int inactivityTimeoutPeriod = 0}) {
    dateTimeStarted ??= DateTime.now();
    stopwatch?.start();
    if (inactivityTimeoutPeriod > 0) {
      try {
        compute(_listenForInactivity, inactivityTimeoutPeriod);
      } catch (e) {
        throw const TimerException(
            "Inactivity Timeout Functionality not available. Please contact the developers or reinstall the app.");
      }
    }
  }

  _listenForInactivity(int inactivityTimeoutPeriod) async {
    try {
      CustomSystemTools idleTimer = CustomSystemTools();

      while (true) {
        if (idleTimer.idleTime() >= inactivityTimeoutPeriod) {
          pauseTimer();
          break;
        }
        if (!stopwatch!.isRunning) break;
      }
    } catch (e) {
      throw const TimerException(
          "Inactivity Timeout Functionality not available. Please contact the developers or reinstall the app.");
    }
  }

  /* Pause Session Timer */
  pauseTimer() {
    stopwatch?.stop();

    save();
  }

  /* Stop Session Timer and Complete Session */
  stopTimer() {
    if (stopwatch!.isRunning) {
      stopwatch?.stop();
      dateTimeEnded = DateTime.now();
    }
    /* Save Session Value */
    save();
  }

  /* Edit Session Model */
  edit(
      {int? id,
      Job? job,
      int? timeElapsed,
      DateTime? dateTimeEnded,
      DateTime? dateTimeStarted}) {
    if (id != null) this.id = id;
    if (job != null) this.job = job;
    if (timeElapsed != null) this.timeElapsed = timeElapsed;
    if (dateTimeEnded != null) this.dateTimeEnded = dateTimeEnded;
    if (dateTimeStarted != null) this.dateTimeStarted = dateTimeStarted;
  }

  Future<bool>? delete() async => id != null
      ? await TaskenDatabase.deleteMain(record: this, recordID: id!)
          .then((value) => value)
      : false;

  save() {
    TaskenDatabase.updateMain(record: this);
  }
}

/*@JsonSerializable()*/
@Entity()
class JobType {
  @Id()
  int? id;
  String? name;
  String? description;
  JobType({this.id, this.name, this.description});

  edit({int? id, String? name, String? description}) {
    id != null ? this.id = id : null;
    name != null ? this.name = name : null;
    description != null ? this.description = description : null;
  }

  Future<bool>? delete() async => id != null
      ? await TaskenDatabase.deleteMain(record: this, recordID: id!)
          .then((value) => value)
      : false;
  save() {
    TaskenDatabase.updateMain(record: this);
  }
}

/*@JsonSerializable()*/
@Entity()
class Client {
  @Id()
  int? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  @Backlink('client')
  List<Representative>? representatives = ToMany<Representative>();
  String? notes;
  Client(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.address,
      this.representatives});
  edit(
      {int? id,
      String? name,
      String? email,
      String? phone,
      String? notes,
      String? address,
      List<Representative>? representatives}) {
    id != null ? this.id = id : null;
    name != null ? this.name = name : null;
    email != null ? this.email = email : null;
    phone != null ? this.phone = phone : null;
    notes != null ? this.notes = notes : null;
    address != null ? this.address = address : null;
    representatives != null ? this.representatives = representatives : null;
  }

  Future<bool>? delete() async => id != null
      ? await TaskenDatabase.deleteMain(record: this, recordID: id!)
          .then((value) => value)
      : false;
  save() {
    TaskenDatabase.updateMain(record: this);
  }
}

/*@JsonSerializable()*/
@Entity()
class Representative {
  @Id()
  int? id;
  String? name;
  String? email;
  String? phone;
  String? notes;
  String? address;
  Representative({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.notes,
    this.address,
  });
  edit({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? notes,
    String? address,
  }) {
    id != null ? this.id = id : null;
    name != null ? this.name = name : null;
    email != null ? this.email = email : null;
    phone != null ? this.phone = phone : null;
    notes != null ? this.notes = notes : null;
    address != null ? this.address = address : null;
  }

  Future<bool>? delete() async => id != null
      ? await TaskenDatabase.deleteMain(record: this, recordID: id!)
          .then((value) => value)
      : false;
  save() {
    TaskenDatabase.updateMain(record: this);
  }
}

// Preferences
class Preferences {
  static Map<String, dynamic> preferences = {};
  static final Map<String, dynamic> defaultPref = {
    "darkMode": true,
  };
  static retrieve() async {
    preferences = await TaskenDatabase.preferences;
  }

  static save() async {
    TaskenDatabase.setPref = preferences;
  }
}
