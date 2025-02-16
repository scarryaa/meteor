import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meteor/features/editor/models/state.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/shared/models/position.dart';

class EditorKeyboardHandler {
  final Editor editor;
  final EditorState state;

  EditorKeyboardHandler(this.editor, this.state);

  KeyEventResult handleKeyEvent(FocusNode node, KeyEvent event) {
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
}
