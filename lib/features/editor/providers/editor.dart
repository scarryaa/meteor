import 'package:meteor/features/editor/models/line_buffer.dart';
import 'package:meteor/features/editor/models/selection.dart';
import 'package:meteor/features/editor/models/state.dart';
import 'package:meteor/features/editor/providers/cursor_manager.dart';
import 'package:meteor/features/editor/providers/selection_manager.dart';
import 'package:meteor/features/editor/tabs/providers/tab_manager.dart';
import 'package:meteor/shared/models/cursor.dart';
import 'package:meteor/shared/models/position.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'editor.g.dart';

@Riverpod(keepAlive: true)
class Editor extends _$Editor {
  @override
  EditorState build(String path) {
    return EditorState(buffer: LineBuffer(), originalContent: '');
  }

  void setState(EditorState newState) {
    state = newState;
  }

  void setOriginalContent(String content) {
    state = state.copyWith(originalContent: content);
  }

  void setLines(List<String> lines) {
    state = state.copyWith(
      buffer: LineBuffer(lines: lines),
      originalContent: lines.join('\n'),
    );
  }

  void selectLine(int line, {bool extendSelection = false}) {
    final newSelection = ref
        .read(editorSelectionManagerProvider.notifier)
        .selectLine(
          state.buffer,
          state.selection,
          line,
          extendSelection: extendSelection,
        );

    state = state.copyWith(
      selection: newSelection,
      cursor:
          newSelection.anchor.line > line
              ? Cursor(line: line, column: 0)
              : Cursor(line: line, column: state.buffer.getLineLength(line)),
    );
  }

  String getSelectedText() {
    return ref
        .read(editorSelectionManagerProvider.notifier)
        .getSelectedText(state.buffer, state.cursor, state.selection);
  }

  void selectAll() {
    final lastLineIndex = state.buffer.lineCount - 1;
    final lastLineLength = state.buffer.getLineLength(lastLineIndex);

    state = state.copyWith(
      selection: ref
          .read(editorSelectionManagerProvider.notifier)
          .selectAll(state.buffer),
      cursor: state.cursor.copyWith(
        line: lastLineIndex,
        column: lastLineLength,
        targetColumn: lastLineLength,
      ),
    );
  }

  void deleteSelectedText() {
    if (state.selection != Selection.empty) {
      final Position selectionAnchor = state.selection.normalized().anchor;

      final res = ref
          .read(editorSelectionManagerProvider.notifier)
          .deleteSelectedText(state.buffer, state.selection);

      state = state.copyWith(
        buffer: res.newBuffer,
        cursor:
            res.mergePosition == Position.zero
                ? Cursor.fromPosition(selectionAnchor)
                : Cursor.fromPosition(res.mergePosition),
        selection: res.newSelection,
      );
    }
  }

  void insert(Position position, String text) {
    if (state.selection != Selection.empty) {
      position = state.selection.normalized().anchor;

      final res = ref
          .read(editorSelectionManagerProvider.notifier)
          .deleteSelectedText(state.buffer, state.selection);

      state = state.copyWith(
        buffer: res.newBuffer,
        cursor:
            res.mergePosition == Position.zero
                ? Cursor.fromPosition(position)
                : Cursor.fromPosition(res.mergePosition),
        selection: res.newSelection,
      );
    }

    final List<String> textLines = text.split('\n');
    final int newlineCount = textLines.length - 1;

    final Cursor newCursor = ref
        .read(editorCursorManagerProvider.notifier)
        .adjustAfterInsert(state.cursor, textLines, newlineCount);
    final newBuffer = state.buffer.insert(position, text);

    state = state.copyWith(buffer: newBuffer, cursor: newCursor);

    _updateTabDirtyState();
  }

  void delete(Position start, Position end) {
    if (state.selection != Selection.empty) {
      final Position selectionAnchor = state.selection.normalized().anchor;
      final res = ref
          .read(editorSelectionManagerProvider.notifier)
          .deleteSelectedText(state.buffer, state.selection);

      state = state.copyWith(
        buffer: res.newBuffer,
        cursor:
            res.mergePosition == Position.zero
                ? Cursor.fromPosition(selectionAnchor)
                : Cursor.fromPosition(res.mergePosition),
        selection: res.newSelection,
      );
      _updateTabDirtyState();
      return;
    }

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

    _updateTabDirtyState();
  }

  void _updateTabDirtyState() {
    ref
        .read(tabManagerProvider.notifier)
        .setTabDirty(
          path,
          isDirty: state.originalContent != state.buffer.toString(),
        );
  }

  void _updateOrClearSelection(bool extendSelection) {
    state = state.copyWith(
      selection: ref
          .read(editorSelectionManagerProvider.notifier)
          .updateOrClearSelection(
            state.cursor,
            state.selection,
            extendSelection: extendSelection,
          ),
    );
  }

  void moveLeft({bool extendSelection = false}) {
    _updateOrClearSelection(extendSelection);

    final cursorManager = ref.read(editorCursorManagerProvider.notifier);
    state = state.copyWith(
      cursor: cursorManager.moveLeft(state.buffer, state.cursor),
    );

    _updateOrClearSelection(extendSelection);
  }

  void moveRight({bool extendSelection = false}) {
    _updateOrClearSelection(extendSelection);

    final cursorManager = ref.read(editorCursorManagerProvider.notifier);
    state = state.copyWith(
      cursor: cursorManager.moveRight(state.buffer, state.cursor),
    );

    _updateOrClearSelection(extendSelection);
  }

  void moveUp({bool extendSelection = false}) {
    _updateOrClearSelection(extendSelection);

    final cursorManager = ref.read(editorCursorManagerProvider.notifier);
    state = state.copyWith(
      cursor: cursorManager.moveUp(state.buffer, state.cursor),
    );

    _updateOrClearSelection(extendSelection);
  }

  void moveDown({bool extendSelection = false}) {
    _updateOrClearSelection(extendSelection);

    final cursorManager = ref.read(editorCursorManagerProvider.notifier);
    state = state.copyWith(
      cursor: cursorManager.moveDown(state.buffer, state.cursor),
    );

    _updateOrClearSelection(extendSelection);
  }

  void moveTo(Position position, {bool extendSelection = false}) {
    _updateOrClearSelection(extendSelection);

    final cursorManager = ref.read(editorCursorManagerProvider.notifier);
    state = state.copyWith(
      cursor: cursorManager.moveTo(state.buffer, position),
    );

    _updateOrClearSelection(extendSelection);
  }
}
