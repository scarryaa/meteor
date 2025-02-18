import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meteor/features/file_explorer/providers/file_explorer_manager.dart';

class FileExplorerKeyboardHandler {
  final FileExplorerManager fileExplorerManager;

  FileExplorerKeyboardHandler(this.fileExplorerManager);

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
    }

    return KeyEventResult.ignored;
  }
}
