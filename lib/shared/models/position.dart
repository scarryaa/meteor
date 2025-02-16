import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meteor/shared/models/cursor.dart';

part 'position.freezed.dart';

@freezed
class Position with _$Position {
  const factory Position({@Default(0) int line, @Default(0) int column}) =
      _Position;

  static const zero = Position(line: 0, column: 0);

  const Position._();

  factory Position.fromCursor(Cursor cursor) {
    return Position(line: cursor.line, column: cursor.column);
  }
}
