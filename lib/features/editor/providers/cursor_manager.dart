import 'dart:math';

import 'package:meteor/features/editor/interfaces/buffer.dart';
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

  Cursor moveLeft(IBuffer buffer, Cursor cursor) {
    if (cursor.column > 0) {
      // Move left within line
      return cursor.copyWith(
        column: cursor.column - 1,
        targetColumn: cursor.column - 1,
      );
    } else if (cursor.line > 0) {
      // Move to previous line
      final previousLineLength = buffer.getLineLength(cursor.line - 1);

      return cursor.copyWith(
        line: cursor.line - 1,
        column: previousLineLength,
        targetColumn: previousLineLength,
      );
    }

    return cursor;
  }

  Cursor moveRight(IBuffer buffer, Cursor cursor) {
    if (cursor.column < buffer.getLineLength(cursor.line)) {
      // Move right within line
      return cursor.copyWith(
        column: cursor.column + 1,
        targetColumn: cursor.column + 1,
      );
    } else if (cursor.line < buffer.lineCount - 1) {
      // Move to next line
      return cursor.copyWith(line: cursor.line + 1, column: 0, targetColumn: 0);
    }

    return cursor;
  }

  Cursor moveUp(IBuffer buffer, Cursor cursor) {
    if (cursor.line > 0) {
      // Move up a line
      return cursor.copyWith(
        line: cursor.line - 1,
        column: min(cursor.targetColumn, buffer.getLineLength(cursor.line - 1)),
      );
    } else {
      // Move to document start
      return Cursor();
    }
  }

  Cursor moveDown(IBuffer buffer, Cursor cursor) {
    if (cursor.line < buffer.lineCount - 1) {
      // Move down a line
      return cursor.copyWith(
        line: cursor.line + 1,
        column: min(cursor.targetColumn, buffer.getLineLength(cursor.line + 1)),
      );
    } else {
      // Move to end of document
      final lastLineIndex = buffer.lineCount - 1;
      final lastLineLength = buffer.getLineLength(lastLineIndex);
      return Cursor(
        line: lastLineIndex,
        column: lastLineLength,
        targetColumn: lastLineLength,
      );
    }
  }
}
