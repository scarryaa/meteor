import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/tabs/providers/tab_manager.dart';
import 'package:meteor/features/editor/tabs/widgets/tab_widget.dart';

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

            IconButton(
              icon: const Icon(Icons.add, size: 16),
              onPressed: () => tabManager.addTab(''),
              style: IconButton.styleFrom(
                minimumSize: const Size(35, 35),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
