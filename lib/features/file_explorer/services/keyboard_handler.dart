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

    final isMetaOrControlPressed =
        Platform.isMacOS
            ? HardwareKeyboard.instance.isMetaPressed
            : HardwareKeyboard.instance.isControlPressed;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyB:
        if (isMetaOrControlPressed) {
          fileExplorerManager.toggleOpen();
          return KeyEventResult.handled;
        }
    }

    return KeyEventResult.ignored;
  }
}
