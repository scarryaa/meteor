import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/file_explorer/providers/file_explorer_manager.dart';
import 'package:meteor/features/file_explorer/widgets/file_item_widget.dart';
import 'package:meteor/shared/providers/focus_node_by_key.dart';

class FileExplorerWidget extends HookConsumerWidget {
  const FileExplorerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fileExplorerManagerProvider);
    final focusNode = ref.watch(
      focusNodeByKeyProvider('fileExplorerFocusNode'),
    );

    return state.isOpen
        ? GestureDetector(
          onTapDown: (_) => focusNode.requestFocus(),
          child: Focus(
            focusNode: focusNode,
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: const Color(0x25FFFFFF)),
                ),
              ),
              child: _buildContent(ref),
            ),
          ),
        )
        : SizedBox.shrink();
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
          _buildOpenDirectoryButton(ref),
        ],
      ),
    );
  }

  Widget _buildOpenDirectoryButton(WidgetRef ref) {
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
          ref.read(fileExplorerManagerProvider.notifier).selectDirectory();
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
            'Select a directory',
            style: TextStyle(color: const Color(0xFFFCFCFC)),
          ),
        ),
      ),
    );
  }

  Widget _buildPopulatedView() {
    return FileItemWidget();
  }
}
