import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/tabs/providers/tab_manager.dart';
import 'package:meteor/features/editor/tabs/widgets/tab_bar_widget.dart';
import 'package:meteor/features/editor/widgets/editor_widget.dart';
import 'package:meteor/features/file_explorer/widgets/file_explorer_widget.dart';
import 'package:meteor/features/gutter/widgets/gutter_widget.dart';
import 'package:meteor/features/status_bar/widgets/status_bar_widget.dart';
import 'package:meteor/features/title_bar/widgets/title_bar_widget.dart';
import 'package:meteor/shared/providers/focus_node_by_key.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  KeyEventResult _handleKeyEvent(
    FocusNode node,
    KeyEvent event,
    WidgetRef ref,
  ) {
    final isMetaOrControlPressed =
        Platform.isMacOS
            ? HardwareKeyboard.instance.isMetaPressed
            : HardwareKeyboard.instance.isControlPressed;
    final tabManager = ref.read(tabManagerProvider.notifier);
    final editorFocusNode = ref.watch(
      focusNodeByKeyProvider('editorFocusNode'),
    );

    if (!node.hasFocus) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyN:
        if (isMetaOrControlPressed) {
          tabManager.addTab('');
          editorFocusNode.requestFocus();

          return KeyEventResult.handled;
        }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(tabManagerProvider);
    final tabManager = ref.read(tabManagerProvider.notifier);
    final activeTab = ref.read(tabManagerProvider.notifier).getActiveTab();
    final focusNode = useFocusNode();
    final editorFocusNode = ref.watch(
      focusNodeByKeyProvider('editorFocusNode'),
    );

    return Column(
      children: [
        TitleBarWidget(),
        Expanded(
          child: Row(
            children: [
              FileExplorerWidget(),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => focusNode.requestFocus(),
                  child: Focus(
                    focusNode: focusNode,
                    autofocus: true,
                    onKeyEvent:
                        (node, event) => _handleKeyEvent(node, event, ref),
                    child:
                        tabs.isEmpty
                            ? _buildEmptyView(tabManager, editorFocusNode)
                            : Column(
                              children: [
                                TabBarWidget(),
                                Expanded(
                                  child: Row(
                                    children: [
                                      GutterWidget(path: activeTab!.path),
                                      Expanded(
                                        child: EditorWidget(
                                          path: activeTab.path,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
        StatusBarWidget(),
      ],
    );
  }

  Widget _buildEmptyView(TabManager tabManager, FocusNode editorFocusNode) {
    return Center(
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tab, size: 64, color: const Color(0x70FFFFFF)),
          _buildNewTabButton(tabManager, editorFocusNode),
        ],
      ),
    );
  }

  Widget _buildNewTabButton(TabManager tabManager, FocusNode editorFocusNode) {
    final isHovered = useState(false);
    final isPressed = useState(false);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTapDown: (_) {
          isPressed.value = true;
        },
        onTap: () {
          tabManager.addTab('');
          editorFocusNode.requestFocus();
        },
        onTapUp: (_) => isPressed.value = false,
        onTapCancel: () => isPressed.value = false,
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            color:
                isPressed.value
                    ? const Color(0x28FFFFFF)
                    : isHovered.value
                    ? const Color(0x30FFFFFF)
                    : Colors.transparent,
          ),
          child: Text(
            'Open a new tab',
            style: TextStyle(color: const Color(0xFFFCFCFC)),
          ),
        ),
      ),
    );
  }
}
