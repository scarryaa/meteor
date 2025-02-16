import 'package:meteor/features/editor/models/line_buffer.dart';
import 'package:meteor/features/editor/models/state.dart';
import 'package:meteor/shared/models/cursor.dart';
import 'package:meteor/shared/models/position.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'editor.g.dart';

@riverpod
class Editor extends _$Editor {
  @override
  EditorState build() {
    return EditorState(buffer: LineBuffer());
  }

  void insert(Position position, String text) {
    final List<String> textLines = text.split('\n');
    final int newlineCount = textLines.length - 1;
    Cursor? newCursor;

    if (newlineCount == 0) {
      // Single-line insert
      newCursor = state.cursor.copyWith(
        column: state.cursor.column + textLines.first.length,
      );
    } else {
      // Multi-line insert
      newCursor = state.cursor.copyWith(
        line: state.cursor.line + newlineCount,
        column: textLines.last.length,
      );
    }

    final newBuffer = state.buffer.insert(position, text);

    state = state.copyWith(buffer: newBuffer, cursor: newCursor);
  }

  void delete(Position start, Position end) {
    Cursor? newCursor;

    if (start.line == 0 && start.column == -1) {
      return;
    }

    if (start.line == end.line) {
      // Single-line delete
      newCursor = Cursor.fromPosition(start);
    } else {
      // Multi-line delete
      newCursor = Cursor.fromPosition(start);
    }

    final result = state.buffer.delete(start, end);

    if (result.mergePosition != Position.zero) {
      newCursor = Cursor.fromPosition(result.mergePosition);
    }

    state = state.copyWith(buffer: result.newBuffer, cursor: newCursor);
  }
}
