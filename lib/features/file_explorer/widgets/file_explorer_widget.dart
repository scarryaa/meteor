import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/file_explorer/providers/file_explorer_manager.dart';
import 'package:meteor/features/file_explorer/widgets/file_item_widget.dart';

class FileExplorerWidget extends ConsumerWidget {
  const FileExplorerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: const Color(0x25FFFFFF))),
      ),
      child: _buildContent(ref),
    );
  }

  Widget _buildContent(WidgetRef ref) {
    final state = ref.watch(fileExplorerManagerProvider);

    return state.currentDirectoryPath == null
        ? _buildEmptyView(ref)
        : _buildPopulatedView();
  }

  Widget _buildEmptyView(WidgetRef ref) {
    return Center(
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_rounded, size: 64, color: const Color(0x70FFFFFF)),
          TextButton(
            onPressed: () {
              ref.read(fileExplorerManagerProvider.notifier).selectDirectory();
            },
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(EdgeInsets.all(8)),
            ),
            child: Text('Select a directory'),
          ),
        ],
      ),
    );
  }

  Widget _buildPopulatedView() {
    return FileItemWidget();
  }
}
