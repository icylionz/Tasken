import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:objectbox/objectbox.dart';
import 'package:tasken/Tools/customtools.dart';
import 'package:json_annotation/json_annotation.dart';
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
  Invoice(
      {this.id,
      this.name,
      this.dateCreated,
      this.currency,
      this.notes,
      this.jobs,
      this.status});

  
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
  }

  delete() {
    if (id != null) {
      /* Delete */
    }
  }

  addJob(Job job) {
    //Insert
  }

  removeJob({int? index, Job? job}) {
    if (index != null) {
      
    } else if (job != null) {
      
    }
  }

  printInvoicePDF() {}
}

/*@JsonSerializable()*/
@Entity()
class InvoiceStatus {
  @Id()
  int? id;
  String? name;
  String? description;
  InvoiceStatus({this.id, this.name, this.description});

  
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
}

/*@JsonSerializable()*/
@Entity()
class Job {
  @Id()
  int? id;
  String? name;
  double? rate;
  double? flatRate;
  bool useFlatRate = false;
  DateTime? dateCreated;
  int? inactivityTimeoutPeriod;
  bool timerLocked = false;
  dynamic client = ToOne<Client>();
  dynamic status = ToOne<JobStatus>();
  dynamic type = ToOne<JobType>();
  dynamic assignedRepresentative = ToOne<Representative>();
  String? notes;
  @Backlink('job')
  List<Session>? sessions = ToMany<Session>();
  Job(
      {this.id,
      this.name,
      this.rate,
      this.flatRate,
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
    /* Add a new session if the previous one has been stopped or there are no sessions */
    if (sessions!.isEmpty || sessions!.last.dateTimeEnded != null) {
      /* create new session */
     
    }

    try {
      sessions?.last
          .startTimer(inactivityTimeoutPeriod: inactivityTimeoutPeriod ?? 0);
    } catch (e) {
      throw const TimerException(
          "Inactivity Timeout Functionality not available. Please contact the developers or reinstall the app.");
    }
    /* wait for inactivity to be too long */
  }

  pauseTimer() {
    sessions?.last.pauseTimer();
  }

  stopTimer() {
    sessions?.last.stopTimer();
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
  }
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
    stopwatch = CustomStopwatch(initialMilliseconds: timeElapsed);
  }

  
  /* Saves the model in the database */

  /* Start Session Timer */
  startTimer({int inactivityTimeoutPeriod = 0}) {
    dateTimeStarted ??= DateTime.now();
   /*  stopwatch.start(); */
    if (inactivityTimeoutPeriod > 0) {
      try {
        _listenForInactivity(inactivityTimeoutPeriod);
      } catch (e) {
        /* stopwatch.stop(); */
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
        /* if (!stopwatch.isRunning) break; */
      }
    } catch (e) {
      throw const TimerException(
          "Inactivity Timeout Functionality not available. Please contact the developers or reinstall the app.");
    }
  }

  /* Pause Session Timer */
  pauseTimer() {
   /*  stopwatch.stop();
    
    save(); */
  }

  /* Stop Session Timer and Complete Session */
  stopTimer() {
   /*  stopwatch.stop();
    dateTimeEnded = DateTime.now();
    /* Save Session Value */
    save(); */
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

  delete() {
    if (id != null) {
      /* delete sql database record */
     
    }
  }
}

/*@JsonSerializable()*/
@Entity()
class JobType {
  @Id()
  int? id;
  String? name;
  double? defaultRate;
  double? defaultFlatRate;
  String? description;
  JobType(
      {this.id,
      this.name,
      this.defaultFlatRate,
      this.defaultRate,
      this.description});

  
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
  dynamic client = ToOne<Client>();
  Representative(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.notes,
      this.address,
      this.client});

}
