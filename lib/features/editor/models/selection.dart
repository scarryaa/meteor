import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meteor/shared/models/position.dart';

part 'selection.freezed.dart';

@freezed
class Selection with _$Selection {
  const factory Selection({
    @Default(Position(line: -1, column: -1)) Position anchor,
    @Default(Position(line: -1, column: -1)) Position focus,
  }) = _Selection;

  const Selection._();

  static const empty = Selection(
    anchor: Position(line: -1, column: -1),
    focus: Position(line: -1, column: -1),
  );

  Selection normalized() {
    return Selection(
      anchor: anchor > focus ? focus : anchor,
      focus: focus > anchor ? anchor : focus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! Selection) return false;

    return anchor == other.anchor && focus == other.focus;
  }

  @override
  int get hashCode => Object.hash(anchor, focus);
}
