import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/bindings/tree-sitter/tree_sitter_bindings.dart';
import 'package:meteor/features/editor/providers/clipboard_manager.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/providers/measurer.dart';
import 'package:meteor/features/editor/providers/tree_sitter_manager.dart';
import 'package:meteor/features/editor/services/editor_keyboard_handler.dart';
import 'package:meteor/features/editor/tabs/providers/tab_manager.dart';
import 'package:meteor/features/editor/widgets/editor_scrollable_widget.dart';
import 'package:meteor/features/file_explorer/providers/file_explorer_manager.dart';
import 'package:meteor/shared/providers/command_manager.dart';
import 'package:meteor/shared/providers/focus_node_by_key.dart';
import 'package:meteor/shared/providers/save_manager.dart';
import 'package:meteor/shared/providers/scroll_controller_by_key.dart';
import 'package:path/path.dart';

class EditorWidget extends ConsumerStatefulWidget {
  const EditorWidget({super.key, required this.path});

  final String path;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => EditorWidgetState();
}

class EditorWidgetState extends ConsumerState<EditorWidget> {
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
    final fileExplorerManager = ref.read(fileExplorerManagerProvider.notifier);
    final vScrollController = ref.watch(
      scrollControllerByKeyProvider('editorVScrollController'),
    );
    final hScrollController = ref.watch(
      scrollControllerByKeyProvider('editorHScrollController'),
    );
    final metrics = ref.watch(editorMeasurerProvider);

    final treeSitterManager = ref.read(treeSitterManagerProvider.notifier);
    final language = treeSitterManager.getLanguage(
      widget.path.contains('.') ? basename(widget.path).split('.').last : '',
    );

    Pointer<TSTree>? tree;
    if (language != null) {
      treeSitterManager.setLanguage(language);
      tree = treeSitterManager.parseString(state.buffer.toString());
    }

    final keyboardHandler = EditorKeyboardHandler(
      ref,
      widget.path,
      context,
      editor,
      fileExplorerManager,
      tabManager,
      saveManager,
      commandManager,
      state,
      clipboardManager,
      clipboardText,
    );

    return LayoutBuilder(
      builder:
          (context, constraints) => Focus(
            focusNode: focusNode,
            autofocus: true,
            onKeyEvent:
                (node, event) => keyboardHandler.handleKeyEvent(
                  node,
                  event,
                  vScrollController,
                  hScrollController,
                  metrics,
                  constraints.maxWidth,
                  constraints.maxHeight,
                ),
            child: MouseRegion(
              cursor: SystemMouseCursors.text,
              child: EditorScrollableWidget(
                path: widget.path,
                constraints: constraints,
                tree: tree,
                treeSitterManager: treeSitterManager,
              ),
            ),
          ),
    );
  }
}
