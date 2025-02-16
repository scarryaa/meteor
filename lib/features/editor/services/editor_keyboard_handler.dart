import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/models/state.dart';
import 'package:meteor/features/editor/providers/clipboard_manager.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/shared/models/position.dart';

class EditorKeyboardHandler {
  final Editor editor;
  final EditorState state;
  final ClipboardManager clipboardManager;
  final AsyncValue<String?> clipboardText;

  EditorKeyboardHandler(
    this.editor,
    this.state,
    this.clipboardManager,
    this.clipboardText,
  );

  Future<void> _handlePaste() async {
    final text = clipboardText.value;

    if (text != null) {
      editor.insert(Position.fromCursor(state.cursor), text);
    }
  }

  bool _handleShortcutKeys(
    KeyEvent event,
    bool isShiftPressed,
    bool isMetaOrControlPressed,
  ) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyA:
        if (isMetaOrControlPressed) {
          // Select all
          editor.selectAll();
          return true;
        }
      case LogicalKeyboardKey.keyC:
        if (isMetaOrControlPressed) {
          // Copy
          final text = editor.getSelectedText();
          clipboardManager.setText(text);
          return true;
        }
      case LogicalKeyboardKey.keyX:
        if (isMetaOrControlPressed) {
          // Cut
          final text = editor.getSelectedText();
          clipboardManager.setText(text);
          editor.deleteSelectedText();
          return true;
        }
      case LogicalKeyboardKey.keyV:
        if (isMetaOrControlPressed) {
          // Paste
          _handlePaste();
          return true;
        }
    }

    return false;
  }

  bool _handleArrowKeys(KeyEvent event, bool isShiftPressed) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        editor.moveLeft(extendSelection: isShiftPressed);
        return true;
      case LogicalKeyboardKey.arrowRight:
        editor.moveRight(extendSelection: isShiftPressed);
        return true;
      case LogicalKeyboardKey.arrowUp:
        editor.moveUp(extendSelection: isShiftPressed);
        return true;
      case LogicalKeyboardKey.arrowDown:
        editor.moveDown(extendSelection: isShiftPressed);
        return true;
    }

    return false;
  }

  KeyEventResult handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
    final isMetaOrControlPressed =
        Platform.isMacOS
            ? HardwareKeyboard.instance.isMetaPressed
            : HardwareKeyboard.instance.isControlPressed;

    if (_handleShortcutKeys(event, isShiftPressed, isMetaOrControlPressed)) {
      return KeyEventResult.handled;
    }

    if (_handleArrowKeys(event, isShiftPressed)) {
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
