import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:system_tray/system_tray.dart';
import 'package:tasken/dbms/databasehandler.dart';
import 'models/models.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pdf;
import 'package:path/path.dart';

Future<void> main() async {
  pdf.ThemeData invoicePDFTheme = pdf.ThemeData(
      defaultTextStyle: const pdf.TextStyle(fontSize: 15, lineSpacing: 2));
  pdf.PageTheme invoicePageTheme = pdf.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pdf.EdgeInsets.fromLTRB(20, 10, 20, 10),
      theme: invoicePDFTheme);

  final invoicePDF = pdf.Document();

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
          // Client Info
          pdf.Flexible(
            child: pdf.RichText(
                softWrap: true,
                // TODO: place client info into spans
                text: pdf.TextSpan(children: [
                  pdf.TextSpan(text: "fjdahlojf\n"),
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
                    // TODO: place user info into spans
                    text: pdf.TextSpan(children: [
                      pdf.TextSpan(
                          text: "Bill to:\n",
                          style: pdf.TextStyle(
                              fontWeight: pdf.FontWeight.bold, fontSize: 16)),
                      pdf.TextSpan(text: "fjdahlojf\n"),
                      pdf.TextSpan(text: "fdafjkdaf\n"),
                      pdf.TextSpan(text: "fhjdafljkd\n"),
                      pdf.TextSpan(
                          text:
                              "fdajkfldkafk aflkaj klfakjfdafdakf jdakf adkf lkadfk daflkd alkfjdalkfjlkda klda  klfaldklkfad kldaklfklaxkldas kdaf kladkalkdfkalkff aklkfa\n"),
                      pdf.TextSpan(text: "klfafka\n"),
                    ])),
              ),
              pdf.RichText(
                  text: pdf.TextSpan(
                text: "\nInvoice #${1}", // TODO: set to id after testing,
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

      //Notes
    ]),
  ));

  File(join("storage", "test.pdf")).writeAsBytesSync(await invoicePDF.save());

  runApp(const MyApp());
  // Initialize DB adapter
  TaskenDatabase.init();
  print("Directory being used: ${Directory.current.path}");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: SfPdfViewer.file(
        File(join("storage", "test.pdf")),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
