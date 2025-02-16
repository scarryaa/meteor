import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meteor/shared/models/position.dart';

part 'cursor.freezed.dart';

@freezed
class Cursor with _$Cursor {
  const factory Cursor({
    @Default(0) int line,
    @Default(0) int column,
    @Default(0) int targetColumn,
  }) = _Cursor;

  const Cursor._();

  factory Cursor.fromPosition(Position position) {
    return Cursor(line: position.line, column: position.column);
  }

  operator >(Cursor other) {
    if (line == other.line) return column > other.column;
    return line > other.line;
  }

  operator >=(Cursor other) {
    if (line == other.line) return column >= other.column;
    return line >= other.line;
  }

  operator <(Cursor other) {
    if (line == other.line) return column < other.column;
    return line < other.line;
  }

  operator <=(Cursor other) {
    if (line == other.line) return column <= other.column;
    return line <= other.line;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Cursor) return false;

    return line == other.line &&
        column == other.column &&
        targetColumn == other.targetColumn;
  }

  @override
  int get hashCode => Object.hash(line, column, targetColumn);
}
