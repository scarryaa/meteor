import 'package:meteor/features/editor/models/delete_result.dart';
import 'package:meteor/shared/models/position.dart';

abstract class IBuffer {
  IBuffer insert(Position position, String text);
  DeleteResult delete(Position start, Position end);

  int get lineCount;
  int get longestLineLength;
  List<String> get lines;

  String getLine(int line);
  int getLineLength(int line);
}
