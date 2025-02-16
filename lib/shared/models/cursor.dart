import 'package:freezed_annotation/freezed_annotation.dart';

part 'cursor.freezed.dart';

@freezed
class Cursor with _$Cursor {
  const factory Cursor({
    @Default(0) int line,
    @Default(0) int column,
    @Default(0) int targetColumn,
  }) = _Cursor;
}
