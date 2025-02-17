import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/providers/clipboard_manager.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/services/editor_keyboard_handler.dart';
import 'package:meteor/features/editor/widgets/editor_scrollable_widget.dart';

class EditorWidget extends ConsumerWidget {
  const EditorWidget({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = ref.read(editorProvider(path).notifier);
    final state = ref.watch(editorProvider(path));
    final clipboardManager = ref.read(clipboardManagerProvider.notifier);
    final clipboardText = ref.watch(clipboardManagerProvider);

    final keyboardHandler = EditorKeyboardHandler(
      editor,
      state,
      clipboardManager,
      clipboardText,
    );

    return LayoutBuilder(
      builder:
          (context, constraints) => Focus(
            autofocus: true,
            onKeyEvent: keyboardHandler.handleKeyEvent,
            child: EditorScrollableWidget(path: path, constraints: constraints),
          ),
    );
  }
}
