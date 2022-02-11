import 'dart:io';

import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:tasken/Tools/customtools.dart';

class TaskenDatabase {
  final Store mainStore;

  static Store get mainBoxes => mainStore ?? openStore();
}
