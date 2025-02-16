import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meteor/shared/models/position.dart';

part 'selection.freezed.dart';

@freezed
class Selection with _$Selection {
  const factory Selection({
    @Default(Position(line: -1, column: -1)) Position anchor,
    @Default(Position(line: -1, column: -1)) Position focus,
  }) = _Selection;
}
