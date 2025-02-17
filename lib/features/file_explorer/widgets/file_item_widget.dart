import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/tabs/providers/tab_manager.dart';
import 'package:meteor/features/file_explorer/models/file_item.dart';
import 'package:meteor/features/file_explorer/providers/file_explorer_manager.dart';
import 'package:meteor/shared/providers/file_manager.dart';
import 'package:path/path.dart';

class FileItemWidget extends ConsumerWidget {
  const FileItemWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fileExplorerManagerProvider);
    final basePath = state.currentDirectoryPath ?? '';

    return ListView.builder(
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        final relativePathDepth = _calculateDepth(basePath, item.path);
        return _FileListItem(item: item, indentLevel: relativePathDepth);
      },
    );
  }

  int _calculateDepth(String basePath, String itemPath) {
    final relativePath = relative(itemPath, from: basePath);
    return relativePath.split(separator).length - 1;
  }
}

class _FileListItem extends ConsumerWidget {
  final FileItem item;
  final int indentLevel;
  static const double indentWidth = 20.0;

  const _FileListItem({required this.item, required this.indentLevel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MouseRegion(
      child: GestureDetector(
        onTap: () {
          ref.read(fileExplorerManagerProvider.notifier).selectItem(item.path);
          if (item.isDirectory) {
            ref
                .read(fileExplorerManagerProvider.notifier)
                .toggleItemExpansion(item.path);
          } else {
            if (!ref.read(tabManagerProvider.notifier).hasTab(item.path)) {
              final lines = ref
                  .read(fileManagerProvider.notifier)
                  .readFileAsLines(item.path);

              ref
                  .read(tabManagerProvider.notifier)
                  .addTab(item.path, name: basename(item.path));
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(editorProvider(item.path).notifier).setLines(lines);
              });
            } else {
              ref
                  .read(tabManagerProvider.notifier)
                  .addTab(item.path, name: basename(item.path));
            }
          }
        },
        child: Container(
          height: 24,
          color:
              item.isSelected
                  ? Colors.purple.withValues(alpha: 0.3)
                  : Colors.transparent,
          child: Row(
            children: [
              SizedBox(width: indentLevel * indentWidth),
              if (item.isDirectory)
                Icon(
                  item.isExpanded ? Icons.folder_open : Icons.folder,
                  size: 16,
                  color: const Color(0x80FCFCFC),
                )
              else
                Icon(
                  Icons.insert_drive_file,
                  size: 16,
                  color: const Color(0x80FCFCFC),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  basename(item.path),
                  style: const TextStyle(color: Color(0xC0FCFCFC)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
