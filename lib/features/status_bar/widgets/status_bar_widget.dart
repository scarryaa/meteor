import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/file_explorer/providers/file_explorer_manager.dart';

class StatusBarWidget extends HookConsumerWidget {
  const StatusBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: const Color(0x25FFFFFF))),
      ),
      child: Row(children: [_buildFileExplorerButton(ref)]),
    );
  }

  Widget _buildFileExplorerButton(WidgetRef ref) {
    final fileExplorerManager = ref.read(fileExplorerManagerProvider.notifier);
    final fileExplorerState = ref.watch(fileExplorerManagerProvider);

    return _buildButton(
      fileExplorerState.isOpen ? Icons.folder : Icons.folder_outlined,
      () {
        fileExplorerManager.toggleOpen();
      },
    );
  }

  Widget _buildButton(IconData icon, Function() onTap) {
    final isHovered = useState(false);
    final isPressed = useState(false);

    return Container(
      padding: EdgeInsets.all(5),
      child: GestureDetector(
        onTapDown: (_) {
          isPressed.value = true;
          onTap();
        },
        onTapUp: (_) => isPressed.value = false,
        onTapCancel: () => isPressed.value = false,
        child: MouseRegion(
          onEnter: (_) => isHovered.value = true,
          onExit: (_) => isHovered.value = false,
          child: Container(
            padding: EdgeInsets.all(5),
            color:
                isPressed.value
                    ? const Color(0x30FFFFFF)
                    : isHovered.value
                    ? const Color(0x40FFFFFF)
                    : Colors.transparent,
            child: Icon(icon, size: 12, color: const Color(0xFFFCFCFC)),
          ),
        ),
      ),
    );
  }
}
