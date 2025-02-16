import 'package:meteor/features/editor/interfaces/buffer.dart';
import 'package:meteor/features/editor/models/selection.dart';
import 'package:meteor/features/editor/models/selection_delete_result.dart';
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
        anchor:
            selection.anchor == Position(line: -1, column: -1)
                ? Position.fromCursor(cursor)
                : selection.anchor,
        focus: Position.fromCursor(cursor),
      );
    } else {
      return Selection.empty;
    }
  }

  SelectionDeleteResult deleteSelectedText(
    IBuffer buffer,
    Selection selection,
  ) {
    final normalized = selection.normalized();
    final result = buffer.delete(normalized.anchor, normalized.focus);

    return SelectionDeleteResult(
      newBuffer: result.newBuffer,
      newSelection: Selection.empty,
      mergePosition: result.mergePosition,
    );
  }
}
