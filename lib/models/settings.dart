import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

@JsonSerializable()
class Settings {
  //User Info
  static String? userName;
  static String? address;
  static String? phone;
  static String? email;

  //PDF Settings
  static PageOrientation?
      orientation; // 0 - natural, 1 - landscape, 2 - portrait
  static PdfPageFormat? format; //

  static load() {
    File jsonFile = File("settings.json");
    Map<String, dynamic> jsonMap = jsonDecode(jsonFile.readAsStringSync());

    userName = jsonMap["userName"];
    address = jsonMap["address"];
    phone = jsonMap["phone"];
    email = jsonMap["email"];
    orientation = PageOrientation.values[jsonMap["orientation"]];
    format = jsonMap["format"] == "a4"
        ? PdfPageFormat.a4
        : jsonMap["format"] == "a3"
            ? PdfPageFormat.a3
            : jsonMap["format"] == "a5"
                ? PdfPageFormat.a5
                : jsonMap["format"] == "a6"
                    ? PdfPageFormat.a6
                    : jsonMap["format"] == "legal"
                        ? PdfPageFormat.legal
                        : jsonMap["format"] == "letter"
                            ? PdfPageFormat.letter
                            : jsonMap["format"] == "roll57"
                                ? PdfPageFormat.roll57
                                : jsonMap["format"] == "roll80"
                                    ? PdfPageFormat.roll80
                                    : jsonMap["format"] == "standard"
                                        ? PdfPageFormat.standard
                                        : null;
  }

  static save() async {
    Map<String, dynamic> jsonMap = {
      "userName": userName,
      "address": address,
      "phone": phone,
      "email": email,
      "orientation": orientation?.index,
      "format": format == PdfPageFormat.a4
          ? "a4"
          : format == PdfPageFormat.a3
              ? "a3"
              : format == PdfPageFormat.a5
                  ? "a5"
                  : format == PdfPageFormat.a6
                      ? "a6"
                      : format == PdfPageFormat.legal
                          ? "legal"
                          : format == PdfPageFormat.letter
                              ? "letter"
                              : format == PdfPageFormat.roll57
                                  ? "roll57"
                                  : format == PdfPageFormat.roll80
                                      ? "roll80"
                                      : format == PdfPageFormat.standard
                                          ? "standard"
                                          : null,
    };

    File jsonFile = File("settings.json")..writeAsString(jsonEncode(jsonMap));
  }
}
