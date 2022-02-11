import 'dart:io' show Platform, Directory;
import 'package:path/path.dart' as path;
import 'dart:ffi' as ffi;

import 'package:tasken/Tools/generated_bindings.dart';

class CustomStopwatch extends Stopwatch {

  int initialMilliseconds;
  CustomStopwatch({this.initialMilliseconds = 0});
  int get totalMilliseconds => initialMilliseconds + elapsedMilliseconds;
}

class CustomSystemTools {
  late int Function() idleTime;
  CustomSystemTools() {
    idleTime = CustomSystemTools.getIdleFunction();
  }
  static getIdleFunction() {
    var libraryPath = path.join(
        Directory.current.path, 'lib', 'Tools', 'CustomFunctions.dylib');
    if (Platform.isMacOS) {
      libraryPath = path.join(
          Directory.current.path, 'lib', 'Tools', 'CustomFunctions.dylib');
    } else if (Platform.isWindows) {
      libraryPath = path.join(
          Directory.current.path, 'lib', 'Tools', 'CustomFunctions.dll');
    }
    final dynamic dylib = ffi.DynamicLibrary.open(libraryPath);
    if (dylib == null) {
      throw DynamicLibraryException(
          "Dynamic Library was not found", libraryPath.toString());
    }
    return OSInterFaceLibrary(dylib).sysIdleTime;
  }
}

class DynamicLibraryException implements Exception {
  final String message;
  final String attemptedPath;
  const DynamicLibraryException(this.message, this.attemptedPath);
  @override
  String toString() {
    return "$message. Dynamic Library was expected to be found at [$attemptedPath].";
  }
}

class TimerException implements Exception {
  final String message;
  const TimerException(this.message);
  @override
  String toString() {
    return message;
  }
}

class Filter {
  String criteriaName;
  MathSign condition;
  String parameter;

  Filter(this.criteriaName, this.condition, this.parameter);


}

enum MathSign {
  equal,
  lessThan,
  moreThan,
  lessThanAndEqual,
  moreThanAndEqual,
  notEqual,
  contains}
