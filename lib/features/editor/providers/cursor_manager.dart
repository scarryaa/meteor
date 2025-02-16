import 'package:meteor/shared/models/cursor.dart';
import 'package:meteor/shared/models/position.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cursor_manager.g.dart';

@riverpod
class EditorCursorManager extends _$EditorCursorManager {
  @override
  void build() {
    return;
  }

  Cursor adjustAfterInsert(
    Cursor cursor,
    List<String> textLines,
    int newlineCount,
  ) {
    Cursor? newCursor;

    if (newlineCount == 0) {
      // Single-line insert
      newCursor = cursor.copyWith(
        column: cursor.column + textLines.first.length,
      );
    } else {
      // Multi-line insert
      newCursor = cursor.copyWith(
        line: cursor.line + newlineCount,
        column: textLines.last.length,
      );
    }

    return newCursor;
  }

  Cursor adjustAfterDelete(
    Position start,
    Position end,
    Position mergePosition,
  ) {
    Cursor? newCursor;

    if (start.line == end.line) {
      // Single-line delete
      newCursor = Cursor.fromPosition(start);
    } else {
      // Multi-line delete
      newCursor = Cursor.fromPosition(start);
    }

    if (mergePosition != Position.zero) {
      newCursor = Cursor.fromPosition(mergePosition);
    }

    return newCursor;
  }
}
