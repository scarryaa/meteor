import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/providers/clipboard_manager.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/services/editor_keyboard_handler.dart';
import 'package:meteor/features/editor/tabs/providers/tab_manager.dart';
import 'package:meteor/features/editor/widgets/editor_scrollable_widget.dart';
import 'package:meteor/shared/providers/command_manager.dart';
import 'package:meteor/shared/providers/focus_node_by_key.dart';
import 'package:meteor/shared/providers/save_manager.dart';

class EditorWidget extends ConsumerStatefulWidget {
  const EditorWidget({super.key, required this.path});

  final String path;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => EditorWidgetState();
}

class EditorWidgetState extends ConsumerState<EditorWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final editor = ref.read(editorProvider(widget.path).notifier);
    final state = ref.watch(editorProvider(widget.path));
    final clipboardManager = ref.read(clipboardManagerProvider.notifier);
    final clipboardText = ref.watch(clipboardManagerProvider);
    final saveManager = ref.read(saveManagerProvider.notifier);
    final commandManager = ref.read(
      commandManagerProvider(widget.path).notifier,
    );
    final tabManager = ref.read(tabManagerProvider.notifier);
    final focusNode = ref.watch(focusNodeByKeyProvider('editorFocusNode'));

    final keyboardHandler = EditorKeyboardHandler(
      editor,
      tabManager,
      saveManager,
      commandManager,
      state,
      clipboardManager,
      clipboardText,
    );

    return LayoutBuilder(
      builder:
          (context, constraints) => GestureDetector(
            onTapDown: (_) => focusNode.requestFocus(),
            child: Focus(
              focusNode: focusNode,
              autofocus: true,
              onKeyEvent: keyboardHandler.handleKeyEvent,
              child: EditorScrollableWidget(
                path: widget.path,
                constraints: constraints,
              ),
            ),
          ),
    );
  }
}
