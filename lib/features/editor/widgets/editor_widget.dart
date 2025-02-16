import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/models/state.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/widgets/editor_painter.dart';
import 'package:meteor/shared/models/position.dart';

class EditorWidget extends ConsumerWidget {
  const EditorWidget({super.key});

  KeyEventResult _handleKeyEvent(
    FocusNode node,
    KeyEvent event,
    Editor editor,
    EditorState state,
  ) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.enter:
        editor.insert(Position.fromCursor(state.cursor), '\n');
        return KeyEventResult.handled;

      case LogicalKeyboardKey.backspace:
        editor.delete(
          Position(line: state.cursor.line, column: state.cursor.column - 1),
          Position.fromCursor(state.cursor),
        );
        return KeyEventResult.handled;

      default:
        if (event.character != null) {
          editor.insert(Position.fromCursor(state.cursor), event.character!);
          return KeyEventResult.handled;
        }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = ref.read(editorProvider.notifier);
    final state = ref.watch(editorProvider);

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) => _handleKeyEvent(node, event, editor, state),
      child: CustomPaint(painter: EditorPainter(lines: state.buffer.lines)),
    );
  }
}
