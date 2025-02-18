import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meteor/features/file_explorer/models/state.dart';
import 'package:meteor/features/file_explorer/providers/file_explorer_manager.dart';

class FileExplorerKeyboardHandler {
  final FileExplorerManager fileExplorerManager;
  final FileExplorerState state;

  FileExplorerKeyboardHandler(this.fileExplorerManager, this.state);

  KeyEventResult handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final isAltPressed = HardwareKeyboard.instance.isAltPressed;
    final isMetaOrControlPressed =
        Platform.isMacOS
            ? HardwareKeyboard.instance.isMetaPressed
            : HardwareKeyboard.instance.isControlPressed;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
        if (state.selectedItemPath != null) {
          final item = fileExplorerManager.getItemByPath(
            state.selectedItemPath!,
          );

          if (!item.isDirectory) {
            fileExplorerManager.openInEditor(state.selectedItemPath!);
          } else {
            fileExplorerManager.toggleItemExpansion(state.selectedItemPath!);
          }
        }
        return KeyEventResult.handled;

      case LogicalKeyboardKey.keyO:
        if (isMetaOrControlPressed) {
          if (isAltPressed) {
            fileExplorerManager.selectDirectory();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        }
        return KeyEventResult.ignored;

      case LogicalKeyboardKey.keyB:
        if (isMetaOrControlPressed) {
          fileExplorerManager.toggleOpen();
          return KeyEventResult.handled;
        }

      case LogicalKeyboardKey.arrowLeft:
        if (state.selectedItemPath != null) {
          fileExplorerManager.collapseItem(state.selectedItemPath!);
        }
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        if (state.selectedItemPath != null) {
          fileExplorerManager.expandItem(state.selectedItemPath!);
        }
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        fileExplorerManager.moveUp();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        fileExplorerManager.moveDown();
        return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
