import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_manager.g.dart';

@riverpod
class FileManager extends _$FileManager {
  @override
  void build() {
    return;
  }

  String readFileAsString(String path) {
    File file = File(path);
    return file.readAsStringSync();
  }

  List<String> readFileAsLines(String path) {
    File file = File(path);
    return file.readAsLinesSync();
  }
}
