import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/tabs/providers/tab_manager.dart';
import 'package:meteor/features/editor/tabs/widgets/tab_bar_widget.dart';
import 'package:meteor/features/editor/widgets/editor_widget.dart';
import 'package:meteor/features/file_explorer/widgets/file_explorer_widget.dart';
import 'package:meteor/features/gutter/widgets/gutter_widget.dart';
import 'package:meteor/features/title_bar/widgets/title_bar_widget.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(tabManagerProvider);
    final tabManager = ref.read(tabManagerProvider.notifier);
    final activeTab = ref.read(tabManagerProvider.notifier).getActiveTab();

    return Column(
      children: [
        TitleBarWidget(),
        Expanded(
          child: Row(
            children: [
              FileExplorerWidget(),
              Expanded(
                child:
                    tabs.isEmpty
                        ? _buildEmptyView(tabManager)
                        : Column(
                          children: [
                            TabBarWidget(),
                            Expanded(
                              child: Row(
                                children: [
                                  GutterWidget(path: activeTab!.path),
                                  Expanded(
                                    child: EditorWidget(path: activeTab.path),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView(TabManager tabManager) {
    return Center(
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tab, size: 64, color: const Color(0x60FFFFFF)),
          TextButton(
            onPressed: () {
              tabManager.addTab('');
            },
            child: Text('Open a new tab'),
          ),
        ],
      ),
    );
  }
}
