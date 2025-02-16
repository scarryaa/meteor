import 'package:meteor/features/editor/models/line_buffer.dart';
import 'package:meteor/features/editor/models/state.dart';
import 'package:meteor/features/editor/providers/cursor_manager.dart';
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

    final Cursor newCursor = ref
        .read(editorCursorManagerProvider.notifier)
        .adjustAfterInsert(state.cursor, textLines, newlineCount);
    final newBuffer = state.buffer.insert(position, text);

    state = state.copyWith(buffer: newBuffer, cursor: newCursor);
  }

  void delete(Position start, Position end) {
    if (start > end) {
      throw RangeError('start position cannot be greater than end position');
    }

    if (start.line > state.buffer.lineCount ||
        end.line > state.buffer.lineCount) {
      throw RangeError(
        'start line or end line cannot be greater than buffer line count',
      );
    }

    if (start.line < 0 || end.line < 0) {
      throw RangeError('start or end line cannot be less than 0');
    }

    if (start.column > state.buffer.getLineLength(start.line) ||
        end.column > state.buffer.getLineLength(end.line)) {
      throw RangeError(
        'start column or end column cannot be greater than buffer target line length',
      );
    }

    if (start.line == 0 && start.column == -1) {
      return;
    }

    final result = state.buffer.delete(start, end);
    final newCursor = ref
        .read(editorCursorManagerProvider.notifier)
        .adjustAfterDelete(start, end, result.mergePosition);

    state = state.copyWith(buffer: result.newBuffer, cursor: newCursor);
  }
}
