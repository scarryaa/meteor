import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/file_explorer/models/file_item.dart';
import 'package:meteor/features/file_explorer/providers/file_explorer_manager.dart';
import 'package:meteor/shared/providers/scroll_controller_by_key.dart';
import 'package:path/path.dart';

class FileItemWidget extends ConsumerWidget {
  const FileItemWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fileExplorerManagerProvider);
    final basePath = state.currentDirectoryPath ?? '';
    final scrollController = ref.watch(
      scrollControllerByKeyProvider('fileExplorerScrollController'),
    );

    return ListView.builder(
      controller: scrollController,
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        final relativePathDepth = _calculateDepth(basePath, item.path);

        final isInHiddenDir = _isInHiddenDirectory(item.path);
        return _FileListItem(
          item: item,
          indentLevel: relativePathDepth,
          isInHiddenDir: isInHiddenDir,
        );
      },
    );
  }

  int _calculateDepth(String basePath, String itemPath) {
    final relativePath = relative(itemPath, from: basePath);
    return relativePath.split(separator).length - 1;
  }

  bool _isInHiddenDirectory(String path) {
    final parts = split(path);

    return parts.any((part) => part.startsWith('.'));
  }
}

class _FileListItem extends ConsumerWidget {
  final FileItem item;
  final int indentLevel;
  final bool isInHiddenDir;
  static const double indentWidth = 20.0;

  const _FileListItem({
    required this.item,
    required this.indentLevel,
    required this.isInHiddenDir,
  });

  bool get _isHidden => basename(item.path).startsWith('.') || isInHiddenDir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color textColor =
        _isHidden ? const Color(0x60FCFCFC) : const Color(0xC0FCFCFC);

    final Color iconColor =
        _isHidden ? const Color(0x40FCFCFC) : const Color(0x80FCFCFC);

    return MouseRegion(
      child: GestureDetector(
        onTap: () {
          ref.read(fileExplorerManagerProvider.notifier).selectItem(item.path);
          if (item.isDirectory) {
            ref
                .read(fileExplorerManagerProvider.notifier)
                .toggleItemExpansion(item.path);
          } else {
            ref
                .read(fileExplorerManagerProvider.notifier)
                .openInEditor(item.path);
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
              SizedBox(width: (0.5 + indentLevel) * indentWidth),
              if (item.isDirectory)
                Icon(
                  item.isExpanded ? Icons.folder_open : Icons.folder,
                  size: 16,
                  color: iconColor,
                )
              else
                Icon(Icons.insert_drive_file, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  basename(item.path),
                  style: TextStyle(color: textColor),
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
