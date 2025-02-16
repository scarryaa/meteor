import 'package:meteor/features/editor/models/selection.dart';
import 'package:meteor/shared/models/cursor.dart';
import 'package:meteor/shared/models/position.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selection_manager.g.dart';

@riverpod
class EditorSelectionManager extends _$EditorSelectionManager {
  @override
  void build() {
    return;
  }

  Selection updateOrClearSelection(
    Cursor cursor,
    Selection selection, {
    bool extendSelection = false,
  }) {
    if (extendSelection) {
      return Selection(
        anchor: selection.anchor,
        focus: Position.fromCursor(cursor),
      );
    } else {
      return Selection.empty;
    }
  }
}
