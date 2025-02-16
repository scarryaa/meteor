import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meteor/features/editor/models/state.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/shared/models/position.dart';

class EditorKeyboardHandler {
  final Editor editor;
  final EditorState state;

  EditorKeyboardHandler(this.editor, this.state);

  bool _handleArrowKeys(KeyEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        editor.moveLeft();
        return true;
      case LogicalKeyboardKey.arrowRight:
        editor.moveRight();
        return true;
      case LogicalKeyboardKey.arrowUp:
        editor.moveUp();
        return true;
      case LogicalKeyboardKey.arrowDown:
        editor.moveDown();
        return true;
    }

    return false;
  }

  KeyEventResult handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (_handleArrowKeys(event)) {
      return KeyEventResult.handled;
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
