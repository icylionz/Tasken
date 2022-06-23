import 'dart:ffi';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:objectbox/objectbox.dart';
import 'package:system_tray/system_tray.dart';
import 'package:tasken/Tools/customtools.dart';
import 'package:tasken/dbms/databasehandler.dart';
import 'package:tasken/models/settings.dart';

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
      this.status,
      this.taxRate = 0});

  edit(
      {int? id,
      String? name,
      DateTime? dateCreated,
      String? currency,
      InvoiceStatus? status,
      List<Job>? jobs,
      String? notes,
      double? taxRate}) {
    id != null ? this.id = id : null;
    name != null ? this.name = name : null;
    dateCreated != null ? this.dateCreated = dateCreated : null;
    currency != null ? this.currency = currency : null;
    status != null ? this.status = status : null;
    jobs != null ? this.jobs = jobs : null;
    notes != null ? this.notes = notes : null;
    taxRate != null ? this.taxRate = taxRate : null;
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
    String missingInfoText = "Not Provided";
    pdf.ThemeData invoicePDFTheme = pdf.ThemeData(
        defaultTextStyle: const pdf.TextStyle(fontSize: 15, lineSpacing: 2));
    pdf.PageTheme invoicePageTheme = pdf.PageTheme(
        orientation: Settings.orientation,
        pageFormat: Settings.format,
        margin: const pdf.EdgeInsets.fromLTRB(20, 10, 20, 10),
        theme: invoicePDFTheme);

    final invoicePDF = pdf.Document();
    final client = jobs?.first.client;
    double totalCost = 0.00;
    jobs?.forEach((e) => totalCost + e.cost);
    int totalHours = 0;
    jobs?.forEach((e) => totalHours + e.timeElapsed);
    invoicePDF.addPage(pdf.Page(
      pageTheme: invoicePageTheme,
      build: (context) => pdf.Column(children: [
        //Header
        pdf.SizedBox(
            child: pdf.Row(
          mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            pdf.Image(pdf.MemoryImage(File("assets/4912-sexy-squirt.png")
                .readAsBytesSync())), // TODO: Place the logo path from settings
            pdf.Spacer(),
            // User Info
            pdf.Flexible(
              child: pdf.RichText(
                  softWrap: true,
                  text: pdf.TextSpan(children: [
                    pdf.TextSpan(text: "${Settings.userName}\n"),
                    pdf.TextSpan(text: "${Settings.address}\n"),
                    pdf.TextSpan(text: "${Settings.phone}\n"),
                    pdf.TextSpan(text: "${Settings.email}\n"),
                    pdf.TextSpan(
                        style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold),
                        text:
                            "Date: ${DateTime.now().toLocal().year} - ${DateTime.now().toLocal().month} - ${DateTime.now().toLocal().day}"),
                  ])),
            )
          ],
        )),
        pdf.Divider(thickness: 0.01, color: PdfColor.fromHex("232323")),
        // Other Header
        pdf.Padding(
          padding: const pdf.EdgeInsets.only(top: 20),
          child: pdf.SizedBox(
              child: pdf.Row(
                  crossAxisAlignment: pdf.CrossAxisAlignment.start,
                  mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
                  children: [
                pdf.Flexible(
                  child: pdf.RichText(
                      softWrap: true,
                      text: pdf.TextSpan(children: [
                        pdf.TextSpan(
                            text: "Bill to:\n",
                            style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold, fontSize: 16)),
                        pdf.TextSpan(
                            text:
                                "${jobs?.first.assignedRepresentative.name}\n"),
                        pdf.TextSpan(text: "${jobs?.first.client.name}\n"),
                        pdf.TextSpan(
                            text:
                                "${jobs?.first.assignedRepresentative.address}\n"),
                        pdf.TextSpan(
                            text:
                                "${jobs?.first.assignedRepresentative.phone}\n"),
                        pdf.TextSpan(
                            text:
                                "${jobs?.first.assignedRepresentative.email}\n"),
                      ])),
                ),
                pdf.RichText(
                    text: pdf.TextSpan(
                  text: "\nInvoice #$id",
                  style: pdf.TextStyle(
                      fontSize: 30,
                      fontWeight: pdf.FontWeight.bold,
                      decoration: pdf.TextDecoration.underline),
                ))
              ])),
        ),
        //Table
        pdf.Padding(
            padding: pdf.EdgeInsets.only(top: 10, bottom: 10),
            child: pdf.Table(
                border: pdf.TableBorder.all(color: PdfColor.fromHex("333333")),
                defaultVerticalAlignment: pdf.TableCellVerticalAlignment.middle,
                children: [
                  // Table Header
                  pdf.TableRow(
                      verticalAlignment: pdf.TableCellVerticalAlignment.middle,
                      children: [
                        pdf.Padding(
                            child: pdf.Text(
                              "Job Name",
                              textAlign: pdf.TextAlign.center,
                            ),
                            padding: const pdf.EdgeInsets.all(5)),
                        pdf.Padding(
                            child: pdf.Text(
                              "Job Description",
                              textAlign: pdf.TextAlign.center,
                            ),
                            padding: const pdf.EdgeInsets.all(5)),
                        pdf.Padding(
                            child: pdf.Text(
                              "Hours Completed",
                              textAlign: pdf.TextAlign.center,
                            ),
                            padding: const pdf.EdgeInsets.all(5)),
                        pdf.Padding(
                            child: pdf.Text(
                              "Cost",
                              textAlign: pdf.TextAlign.center,
                            ),
                            padding: const pdf.EdgeInsets.all(5)),
                      ]),
                  //Table Data
                  pdf.TableRow(children: []),
                ])),
        //Subtotal Info
        pdf.Padding(
          padding: const pdf.EdgeInsets.only(top: 20),
          child: pdf.SizedBox(
              child: pdf.Row(
                  crossAxisAlignment: pdf.CrossAxisAlignment.start,
                  mainAxisAlignment: pdf.MainAxisAlignment.end,
                  children: [
                pdf.Flexible(
                  child: pdf.RichText(
                      softWrap: true,
                      // TODO: place financials into spans
                      text: pdf.TextSpan(
                          style: pdf.TextStyle(
                              lineSpacing: 10,
                              decoration: pdf.TextDecoration.underline),
                          children: [
                            pdf.TextSpan(
                                style: pdf.TextStyle(
                                    fontWeight: pdf.FontWeight.bold,
                                    fontSize: 16),
                                children: [
                                  pdf.TextSpan(text: "Total Hours:   "),
                                  pdf.TextSpan(text: "${totalHours}"),
                                ]),
                            pdf.TextSpan(
                                style: pdf.TextStyle(
                                    fontWeight: pdf.FontWeight.bold,
                                    fontSize: 16),
                                children: [
                                  pdf.TextSpan(text: "\nTax Rate:   "),
                                  pdf.TextSpan(text: "${taxRate * 100}%"),
                                ]),
                            pdf.TextSpan(
                                style: pdf.TextStyle(
                                    fontWeight: pdf.FontWeight.bold,
                                    fontSize: 16),
                                children: [
                                  const pdf.TextSpan(text: "\nTax:   "),
                                  pdf.TextSpan(
                                      text: " \$${totalCost * taxRate} "),
                                ]),
                            pdf.TextSpan(
                                style: pdf.TextStyle(
                                    fontWeight: pdf.FontWeight.bold,
                                    fontSize: 16),
                                children: [
                                  const pdf.TextSpan(text: "\nBalance Due:   "),
                                  pdf.TextSpan(
                                      text:
                                          " \$${(totalCost) * (1 + taxRate)}"),
                                ]),
                          ])),
                ),
              ])),
        ),
        pdf.Divider(thickness: 0.01, color: PdfColor.fromHex("232323")),
        //Notes
        pdf.Padding(
          padding: const pdf.EdgeInsets.only(top: 20),
          child: pdf.SizedBox(
              child: pdf.Row(
                  crossAxisAlignment: pdf.CrossAxisAlignment.start,
                  mainAxisAlignment: pdf.MainAxisAlignment.start,
                  children: [
                pdf.Flexible(
                  child: pdf.RichText(
                      softWrap: true,
                      // TODO: place financials into spans
                      text: pdf.TextSpan(children: [
                        pdf.TextSpan(
                            style: pdf.TextStyle(
                                fontSize: 20,
                                fontWeight: pdf.FontWeight.bold,
                                lineSpacing: 10,
                                decoration: pdf.TextDecoration.underline),
                            text: "Notes:\n"),

                        pdf.TextSpan(
                            text: "-"), //TODO: insert notes from invoices
                      ])),
                ),
              ])),
        ),
      ]),
    ));

    return invoicePDF;
  }

  // creates invoices from a list of jobs and separate those that are from different clients
  static List<Invoice> compileInvoices(List<Job>? incomingJobs) {
    if (incomingJobs == null) {
      return [];
    }
    //copies the jobs
    List<Job> jobs = [];
    jobs.addAll(incomingJobs);

    List<Invoice> invoices = [];
    while (jobs.isNotEmpty) {
      // adds the matching jobs into a invoice
      invoices.add(Invoice(
          jobs: jobs
              .where((element) =>
                  (jobs.first.client == element.client) &&
                  (jobs.first.assignedRepresentative ==
                      element.assignedRepresentative))
              .toList()));
      // removes the added jobs from the list
      jobs.removeWhere((element) =>
          (jobs.first.client == element.client) &&
          (jobs.first.assignedRepresentative ==
              element.assignedRepresentative));
    }
    return invoices;
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
  List<Invoice>? invoices = ToMany<Invoice>();
  Report(
      {this.id,
      this.dateCreated,
      this.minDateAccountFor,
      this.maxDateAccountFor,
      this.notes,
      this.jobs,
      this.invoices});
  edit(
      {int? id,
      DateTime? dateCreated,
      DateTime? minDateAccountFor,
      DateTime? maxDateAccountFor,
      List<Job>? jobs,
      List<Invoice>? invoices,
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
    invoices != null ? this.invoices = invoices : null;
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

  addInvoices(List<Invoice> invoices) {
    //Insert
    invoices.addAll(invoices);
    save();
  }

  removeInvoices({List<int>? indexes, List<Invoice>? invoices}) {
    if (indexes != null) {
      indexes.map((index) {
        this.invoices?.removeAt(index);
      });
    } else if (invoices != null) {
      invoices.map((invoice) {
        this.invoices?.remove(invoice);
      });
    }
    save();
  }

  save() {
    TaskenDatabase.updateMain(record: this);
  }

  pdf.Document createReportPDF() {
    String missingInfoText = "Not Provided";
    pdf.ThemeData reportPDFTheme = pdf.ThemeData(
        defaultTextStyle: const pdf.TextStyle(fontSize: 15, lineSpacing: 2));
    //TODO: Get PDF settings from settings
    pdf.PageTheme reportPageTheme = pdf.PageTheme(
        orientation: pdf.PageOrientation.natural,
        pageFormat: PdfPageFormat.a4,
        margin: const pdf.EdgeInsets.fromLTRB(20, 10, 20, 10),
        theme: reportPDFTheme);

    final reportPDF = pdf.Document();
    reportPDF.addPage(pdf.Page(
      pageTheme: reportPageTheme,
      build: (context) => pdf.Column(children: [
        //Header
        pdf.SizedBox(
            child: pdf.Row(
          mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            pdf.Image(pdf.MemoryImage(File("assets/4912-sexy-squirt.png")
                .readAsBytesSync())), // TODO: Place the logo path from settings
            pdf.Spacer(),
            // User Info
            pdf.Flexible(
              child: pdf.RichText(
                  softWrap: true,
                  // TODO: place user info into spans
                  text: pdf.TextSpan(children: [
                    pdf.TextSpan(text: "fdjafjdajk\n"),
                    pdf.TextSpan(text: "fdafjkdaf\n"),
                    pdf.TextSpan(text: "fhjdafljkd\n"),
                    pdf.TextSpan(
                        text:
                            "fdajkfldkafk aflkaj klfakjfdafdakf jdakf adkf lkadfk daflkd alkfjdalkfjlkda klda  klfaldklkfad kldaklfklaxkldas kdaf kladkalkdfkalkff aklkfa\n"),
                    pdf.TextSpan(text: "klfafka\n"),
                    pdf.TextSpan(
                        style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold),
                        text:
                            "Date: ${DateTime.now().toLocal().year} - ${DateTime.now().toLocal().month} - ${DateTime.now().toLocal().day}"),
                  ])),
            )
          ],
        )),
        pdf.Divider(thickness: 0.01, color: PdfColor.fromHex("232323")),
        //Table
        pdf.Padding(
            padding: pdf.EdgeInsets.only(top: 10, bottom: 10),
            child: pdf.Table(
                border: pdf.TableBorder.all(color: PdfColor.fromHex("333333")),
                defaultVerticalAlignment: pdf.TableCellVerticalAlignment.middle,
                children: [
                  // Table Header
                  pdf.TableRow(
                      verticalAlignment: pdf.TableCellVerticalAlignment.middle,
                      children: [
                        pdf.Padding(
                            child: pdf.Text(
                              "Job Name",
                              textAlign: pdf.TextAlign.center,
                            ),
                            padding: const pdf.EdgeInsets.all(5)),
                        pdf.Padding(
                            child: pdf.Text(
                              "Job Description",
                              textAlign: pdf.TextAlign.center,
                            ),
                            padding: const pdf.EdgeInsets.all(5)),
                        pdf.Padding(
                            child: pdf.Text(
                              "Hours Completed",
                              textAlign: pdf.TextAlign.center,
                            ),
                            padding: const pdf.EdgeInsets.all(5)),
                        pdf.Padding(
                            child: pdf.Text(
                              "Cost",
                              textAlign: pdf.TextAlign.center,
                            ),
                            padding: const pdf.EdgeInsets.all(5)),
                      ]),
                  //Table Data
                  pdf.TableRow(children: []),
                ])),
        //Subtotal Info
        pdf.Padding(
          padding: const pdf.EdgeInsets.only(top: 20),
          child: pdf.SizedBox(
              child: pdf.Row(
                  crossAxisAlignment: pdf.CrossAxisAlignment.start,
                  mainAxisAlignment: pdf.MainAxisAlignment.end,
                  children: [
                pdf.Flexible(
                  child: pdf.RichText(
                      softWrap: true,
                      // TODO: place financials into spans
                      text: pdf.TextSpan(
                          style: pdf.TextStyle(
                              lineSpacing: 10,
                              decoration: pdf.TextDecoration.underline),
                          children: [
                            pdf.TextSpan(
                                style: pdf.TextStyle(
                                    fontWeight: pdf.FontWeight.bold,
                                    fontSize: 16),
                                children: [
                                  pdf.TextSpan(text: "Total Hours:   "),
                                  pdf.TextSpan(
                                      text:
                                          " \$- "), //TODO: place calculated hours
                                ]),
                            pdf.TextSpan(
                                style: pdf.TextStyle(
                                    fontWeight: pdf.FontWeight.bold,
                                    fontSize: 16),
                                children: [
                                  pdf.TextSpan(text: "\nRate:   "),
                                  pdf.TextSpan(
                                      text:
                                          " \$- "), //TODO: place rate, place hourly if hourly rate
                                ]),
                            pdf.TextSpan(
                                style: pdf.TextStyle(
                                    fontWeight: pdf.FontWeight.bold,
                                    fontSize: 16),
                                children: [
                                  pdf.TextSpan(text: "\nTax Rate:   "),
                                  pdf.TextSpan(
                                      text: " \$- "), //TODO: place tax rate
                                ]),
                            pdf.TextSpan(
                                style: pdf.TextStyle(
                                    fontWeight: pdf.FontWeight.bold,
                                    fontSize: 16),
                                children: [
                                  const pdf.TextSpan(text: "\nTax:   "),
                                  pdf.TextSpan(
                                      text:
                                          " \$- "), //TODO: place calculated tax
                                ]),
                            pdf.TextSpan(
                                style: pdf.TextStyle(
                                    fontWeight: pdf.FontWeight.bold,
                                    fontSize: 16),
                                children: [
                                  const pdf.TextSpan(text: "\nBalance Due:   "),
                                  pdf.TextSpan(
                                      text: " \$- "), //TODO: place balance due
                                ]),
                          ])),
                ),
              ])),
        ),
        pdf.Divider(thickness: 0.01, color: PdfColor.fromHex("232323")),
        //Notes
        pdf.Padding(
          padding: const pdf.EdgeInsets.only(top: 20),
          child: pdf.SizedBox(
              child: pdf.Row(
                  crossAxisAlignment: pdf.CrossAxisAlignment.start,
                  mainAxisAlignment: pdf.MainAxisAlignment.start,
                  children: [
                pdf.Flexible(
                  child: pdf.RichText(
                      softWrap: true,
                      // TODO: place financials into spans
                      text: pdf.TextSpan(children: [
                        pdf.TextSpan(
                            style: pdf.TextStyle(
                                fontSize: 20,
                                fontWeight: pdf.FontWeight.bold,
                                lineSpacing: 10,
                                decoration: pdf.TextDecoration.underline),
                            text: "Notes:\n"),

                        pdf.TextSpan(
                            text: "-"), //TODO: insert notes from reports
                      ])),
                ),
              ])),
        ),
      ]),
    ));

    return reportPDF;
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
      double? expenses,
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
    expenses != null ? this.expenses = expenses : null;
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

  /* TODO:-- Useless until solution found (See clickup task #1vdyabh) 
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

  double get timeElapsed {
    // in hours
    if (sessions == null) {
      return 0;
    }
    if (sessions!.isEmpty) {
      return 0;
    }
    int elapsed = 0;
    sessions?.forEach((e) => e.timeElapsed + elapsed);
    return (elapsed / (1000 * 60 * 60));
  }

  double get cost => useFlatRate ? flatRate ?? 0 : (rate ?? 0) * timeElapsed;
}

/*@JsonSerializable()*/
@Entity()
class Session {
  @Id()
  int? id;
  dynamic job = ToOne<Job>();
  int timeElapsed = 0; // in milliseconds
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
    timeElapsed = stopwatch?.elapsedMilliseconds ?? 0;
    save();
  }

  /* Stop Session Timer and Complete Session */
  stopTimer() {
    if (stopwatch!.isRunning) {
      stopwatch?.stop();
      timeElapsed = stopwatch?.elapsedMilliseconds ?? 0;
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
