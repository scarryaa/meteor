// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/models/metrics.dart';
import 'package:meteor/features/editor/models/state.dart';
import 'package:meteor/features/editor/providers/clipboard_manager.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/tabs/providers/tab_manager.dart';
import 'package:meteor/features/file_explorer/providers/file_explorer_manager.dart';
import 'package:meteor/shared/models/commands/editor_delete_command.dart';
import 'package:meteor/shared/models/commands/editor_insert_command.dart';
import 'package:meteor/shared/models/position.dart';
import 'package:meteor/shared/providers/command_manager.dart';
import 'package:meteor/shared/providers/save_manager.dart';
import 'package:meteor/shared/providers/scroll_controller_by_key.dart';

class EditorKeyboardHandler {
  final WidgetRef ref;
  final String path;
  final BuildContext context;
  final Editor editor;
  final SaveManager saveManager;
  final TabManager tabManager;
  final EditorState state;
  final FileExplorerManager fileExplorerManager;
  final CommandManager commandManager;
  final ClipboardManager clipboardManager;
  final AsyncValue<String?> clipboardText;

  EditorKeyboardHandler(
    this.ref,
    this.path,
    this.context,
    this.editor,
    this.fileExplorerManager,
    this.tabManager,
    this.saveManager,
    this.commandManager,
    this.state,
    this.clipboardManager,
    this.clipboardText,
  );

  Future<void> _handleCloseTab() async {
    final canClose = await tabManager.showUnsavedChangesDialog(
      context,
      tabManager.getActiveTab()!.path,
    );
    if (canClose) {
      tabManager.removeTabByPath(tabManager.getActiveTab()!.path);
    }
  }

  Future<void> _handlePaste(
    ScrollController vScrollController,
    ScrollController hScrollController,
    EditorMetrics metrics,
    double viewportWidth,
    double viewportHeight,
  ) async {
    final text = clipboardText.value;

    if (text != null) {
      commandManager.execute(
        EditorInsertCommand(
          editor,
          state,
          Position.fromCursor(state.cursor),
          text,
        ),
      );

      _scrollToCursor(
        ref,
        vScrollController,
        hScrollController,
        metrics,
        viewportWidth,
        viewportHeight,
        delayed: true,
      );
    }
  }

  void _scrollToCursor(
    WidgetRef ref,
    ScrollController vScrollController,
    ScrollController hScrollController,
    EditorMetrics metrics,
    double viewportWidth,
    double viewportHeight, {
    bool delayed = false,
  }) {
    if (delayed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final newState = ref.read(editorProvider(path));
        scrollToCursor(
          newState,
          vScrollController,
          hScrollController,
          metrics,
          viewportWidth,
          viewportHeight,
        );

        vScrollController.notifyListeners();
        hScrollController.notifyListeners();
        ref
            .read(scrollControllerByKeyProvider('gutterVScrollController'))
            .notifyListeners();
      });
    } else {
      final newState = ref.read(editorProvider(path));
      scrollToCursor(
        newState,
        vScrollController,
        hScrollController,
        metrics,
        viewportWidth,
        viewportHeight,
      );

      vScrollController.notifyListeners();
      hScrollController.notifyListeners();
      ref
          .read(scrollControllerByKeyProvider('gutterVScrollController'))
          .notifyListeners();
    }
  }

  void scrollToCursor(
    EditorState state,
    ScrollController vScrollController,
    ScrollController hScrollController,
    EditorMetrics metrics,
    double viewportWidth,
    double viewportHeight,
  ) {
    double lineHeight = metrics.lineHeight;
    double charWidth = metrics.charWidth;

    final cursorY = state.cursor.line * lineHeight;
    final cursorX = state.cursor.column * charWidth;

    if (cursorY < vScrollController.offset + metrics.heightPadding) {
      vScrollController.jumpTo(
        (cursorY - metrics.heightPadding).clamp(
          0,
          vScrollController.position.maxScrollExtent,
        ),
      );
    } else if (cursorY + metrics.heightPadding >
        vScrollController.offset + viewportHeight - lineHeight) {
      vScrollController.jumpTo(
        (cursorY - viewportHeight + lineHeight + metrics.heightPadding).clamp(
          0,
          vScrollController.position.maxScrollExtent,
        ),
      );
    }

    if (cursorX < hScrollController.offset + metrics.widthPadding) {
      hScrollController.jumpTo(
        (cursorX - metrics.widthPadding).clamp(
          0,
          hScrollController.position.maxScrollExtent,
        ),
      );
    } else if (cursorX + metrics.widthPadding >
        hScrollController.offset + viewportWidth - charWidth * 2) {
      hScrollController.jumpTo(
        (cursorX - viewportWidth + charWidth * 2 + metrics.widthPadding).clamp(
          0,
          hScrollController.position.maxScrollExtent,
        ),
      );
    }
  }

  bool _handleShortcutKeys(
    KeyEvent event,
    bool isShiftPressed,
    bool isMetaOrControlPressed,
    bool isAltPressed,
    ScrollController vScrollController,
    ScrollController hScrollController,
    EditorMetrics metrics,
    double viewportWidth,
    double viewportHeight,
    WidgetRef ref,
  ) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyO:
        if (isMetaOrControlPressed) {
          if (isAltPressed) {
            fileExplorerManager.selectDirectory();
            return true;
          }
          return false;
        }
        return false;

      case LogicalKeyboardKey.keyB:
        if (isMetaOrControlPressed) {
          fileExplorerManager.toggleOpen();
          return true;
        }

      case LogicalKeyboardKey.keyW:
        if (isMetaOrControlPressed) {
          _handleCloseTab();
          return true;
        }
        return false;

      case LogicalKeyboardKey.keyN:
        if (isMetaOrControlPressed) {
          // Open tab
          tabManager.addTab('');
          return true;
        }
        return false;

      case LogicalKeyboardKey.keyZ:
        if (isMetaOrControlPressed) {
          if (isShiftPressed) {
            // Redo
            commandManager.redo();

            _scrollToCursor(
              ref,
              vScrollController,
              hScrollController,
              metrics,
              viewportWidth,
              viewportHeight,
              delayed: true,
            );
            return true;
          } else {
            // Undo
            commandManager.undo();

            _scrollToCursor(
              ref,
              vScrollController,
              hScrollController,
              metrics,
              viewportWidth,
              viewportHeight,
              delayed: true,
            );

            return true;
          }
        }
        return false;

      case LogicalKeyboardKey.keyS:
        if (isMetaOrControlPressed) {
          if (isShiftPressed) {
            // Save As
            saveManager.saveAs(editor.path, state.buffer.toString());
            return true;
          } else {
            // Save
            saveManager.save(editor.path, state.buffer.toString());
            return true;
          }
        }
        return false;

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
          commandManager.execute(
            EditorDeleteCommand(
              editor,
              state,
              Position(
                line: state.cursor.line,
                column: state.cursor.column - 1,
              ),
              Position.fromCursor(state.cursor),
            ),
          );

          _scrollToCursor(
            ref,
            vScrollController,
            hScrollController,
            metrics,
            viewportWidth,
            viewportHeight,
            delayed: true,
          );
          return true;
        }
      case LogicalKeyboardKey.keyV:
        if (isMetaOrControlPressed) {
          // Paste
          _handlePaste(
            vScrollController,
            hScrollController,
            metrics,
            viewportWidth,
            viewportHeight,
          );
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

  KeyEventResult handleKeyEvent(
    FocusNode node,
    KeyEvent event,
    ScrollController vScrollController,
    ScrollController hScrollController,
    EditorMetrics metrics,
    double viewportWidth,
    double viewportHeight,
  ) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final isAltPressed = HardwareKeyboard.instance.isAltPressed;
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
    final isMetaOrControlPressed =
        Platform.isMacOS
            ? HardwareKeyboard.instance.isMetaPressed
            : HardwareKeyboard.instance.isControlPressed;

    if (_handleShortcutKeys(
      event,
      isShiftPressed,
      isMetaOrControlPressed,
      isAltPressed,
      vScrollController,
      hScrollController,
      metrics,
      viewportWidth,
      viewportHeight,
      ref,
    )) {
      return KeyEventResult.handled;
    }

    if (_handleArrowKeys(event, isShiftPressed)) {
      _scrollToCursor(
        ref,
        vScrollController,
        hScrollController,
        metrics,
        viewportWidth,
        viewportHeight,
      );
      return KeyEventResult.handled;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.enter:
        commandManager.execute(
          EditorInsertCommand(
            editor,
            state,
            Position.fromCursor(state.cursor),
            '\n',
          ),
        );

        _scrollToCursor(
          ref,
          vScrollController,
          hScrollController,
          metrics,
          viewportWidth,
          viewportHeight,
          delayed: true,
        );
        return KeyEventResult.handled;

      case LogicalKeyboardKey.backspace:
        commandManager.execute(
          EditorDeleteCommand(
            editor,
            state,
            Position(line: state.cursor.line, column: state.cursor.column - 1),
            Position.fromCursor(state.cursor),
          ),
        );

        _scrollToCursor(
          ref,
          vScrollController,
          hScrollController,
          metrics,
          viewportWidth,
          viewportHeight,
          delayed: true,
        );
        return KeyEventResult.handled;

      default:
        if (event.character != null) {
          commandManager.execute(
            EditorInsertCommand(
              editor,
              state,
              Position.fromCursor(state.cursor),
              event.character!,
            ),
          );

          _scrollToCursor(
            ref,
            vScrollController,
            hScrollController,
            metrics,
            viewportWidth,
            viewportHeight,
          );
          return KeyEventResult.handled;
        }
    }

    return KeyEventResult.ignored;
  }
}
