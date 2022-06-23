import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasken/dbms/databasehandler.dart';
import 'package:tasken/models/models.dart';
import 'package:path/path.dart';

void main() async {
  setUp(() async {});
  test("Testing the compile invoice function", () async {
    Representative larry = Representative(id: 0, name: "Larry");
    Representative paul = Representative(id: 1, name: "Paul");
    Representative lisa = Representative(id: 2, name: "Lisa");

    Client companyA =
        Client(name: "Company A", id: 0, representatives: [larry]);
    Client companyB =
        Client(name: "Company B", id: 1, representatives: [paul, lisa]);
    Client companyC = Client(
      name: "Company C",
      id: 2,
    );

    List<Job> jobs = [
      Job(client: companyB, assignedRepresentative: paul),
      Job(client: companyB, assignedRepresentative: paul),
      Job(client: companyB, assignedRepresentative: lisa),
      Job(client: companyA, assignedRepresentative: larry),
      Job(client: companyC)
    ];

    List<Invoice> invoices = Invoice.compileInvoices(jobs);
    print(invoices[0].jobs!);
    print(invoices[0].jobs!);
    print(invoices[0].jobs!);
    print(invoices[0].jobs!);
    expect([
      Invoice(jobs: [jobs[0], jobs[1]]),
      Invoice(jobs: [jobs[2]]),
      Invoice(jobs: [jobs[3]]),
      Invoice(jobs: [jobs[4]]),
    ], invoices);
  });
}
