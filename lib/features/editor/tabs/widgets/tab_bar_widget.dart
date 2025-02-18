import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/tabs/providers/tab_manager.dart';
import 'package:meteor/features/editor/tabs/widgets/tab_widget.dart';
import 'package:meteor/shared/models/hotkeys.dart';
import 'package:meteor/shared/widgets/desktop_tooltip/widgets/desktop_tooltip.dart';

class TabBarWidget extends HookConsumerWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(tabManagerProvider);
    final tabManager = ref.watch(tabManagerProvider.notifier);
    final scrollController = useScrollController();

    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          scrollController.jumpTo(
            (scrollController.offset + event.scrollDelta.dy).clamp(
              0,
              scrollController.position.maxScrollExtent,
            ),
          );
        }
      },
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: const Color(0x25FFFFFF))),
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      tabs
                          .map(
                            (tab) => TabWidget(
                              isActive: tab.isActive,
                              isDirty: tab.isDirty,
                              name: tab.name,
                              path: tab.path,
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
            DesktopTooltip(
              message: 'Add tab',
              hotkeys: [Hotkey.modifier],
              hotkeyLetter: 'N',
              child: _buildAddTabButton(tabManager, scrollController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTabButton(
    TabManager tabManager,
    ScrollController scrollController,
  ) {
    final isHovered = useState(false);

    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: const Color(0x25FFFFFF))),
      ),
      padding: const EdgeInsets.all(7.5),
      child: GestureDetector(
        onTapDown: (_) {
          tabManager.addTab('');

          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          });
        },
        child: MouseRegion(
          onEnter: (_) => isHovered.value = true,
          onExit: (_) => isHovered.value = false,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color:
                  isHovered.value
                      ? const Color(0x40FFFFFF)
                      : Colors.transparent,
            ),
            child: Icon(Icons.add, size: 16, color: Color(0xA0FFFFFF)),
          ),
        ),
      ),
    );
  }
}
