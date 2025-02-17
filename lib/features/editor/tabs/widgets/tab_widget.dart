import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/tabs/providers/tab_manager.dart';

class TabWidget extends HookConsumerWidget {
  const TabWidget({
    super.key,
    required this.isActive,
    required this.isDirty,
    required this.path,
    required this.name,
  });

  final bool isActive;
  final bool isDirty;
  final String path;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = useState(false);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTapDown:
            (_) => ref.read(tabManagerProvider.notifier).setTabActive(path),
        onTertiaryTapDown:
            (_) => ref.read(tabManagerProvider.notifier).removeTabByPath(path),
        child: Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color:
                isActive
                    ? const Color(0x30FFFFFF)
                    : (isHovered.value
                        ? const Color(0x25FFFFFF)
                        : Colors.transparent),
            border: Border(right: BorderSide(color: const Color(0x25FFFFFF))),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDirtyIndicator(),
              const SizedBox(width: 16),
              Text(
                name,
                style: const TextStyle(
                  color: Color(0xF0FCFCFC),
                  fontSize: 15.0,
                ),
              ),
              const SizedBox(width: 8),
              _buildCloseButton(ref, isHovered.value),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton(WidgetRef ref, bool isTabHovered) {
    final isHovered = useState(false);

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTap: () {
          ref.read(tabManagerProvider.notifier).removeTabByPath(path);
        },
        child: Container(
          width: 16,
          height: 16,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                isHovered.value ? const Color(0x30FFFFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            isTabHovered ? Icons.close : null,
            size: 12,
            color: Color(0xF0FCFCFC),
          ),
        ),
      ),
    );
  }

  Widget _buildDirtyIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: ShapeDecoration(
        color: isDirty ? Colors.purple : Colors.transparent,
        shape: CircleBorder(),
      ),
    );
  }
}
