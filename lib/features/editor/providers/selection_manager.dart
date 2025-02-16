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

  Selection selectAll(IBuffer buffer) {
    return Selection(
      anchor: Position.zero,
      focus: Position(
        line: buffer.lineCount - 1,
        column: buffer.getLineLength(buffer.lineCount - 1),
      ),
    );
  }

  String getSelectedText(IBuffer buffer, Cursor cursor, Selection selection) {
    if (selection == Selection.empty) return buffer.getLine(cursor.line);

    final normalized = selection.normalized();

    if (normalized.anchor.line == normalized.focus.line) {
      // Single-line selection
      return buffer
          .getLine(normalized.anchor.line)
          .substring(normalized.anchor.column, normalized.focus.column);
    } else {
      // Multi-line selection
      StringBuffer sb = StringBuffer();

      // First line
      sb.writeln(
        buffer
            .getLine(normalized.anchor.line)
            .substring(normalized.anchor.column),
      );

      // Middle lines
      for (int i = normalized.anchor.line + 1; i < normalized.focus.line; i++) {
        sb.writeln(buffer.getLine(i));
      }

      // Last line
      sb.write(
        buffer
            .getLine(normalized.focus.line)
            .substring(0, normalized.focus.column),
      );

      return sb.toString();
    }
  }
}
