import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:meteor/features/file_explorer/models/file_item.dart';
import 'package:meteor/features/file_explorer/models/state.dart';
import 'package:meteor/shared/providers/focus_node_by_key.dart';
import 'package:meteor/shared/providers/scroll_controller_by_key.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

part 'file_explorer_manager.g.dart';

@riverpod
class FileExplorerManager extends _$FileExplorerManager {
  static const String _lastDirectoryKey = 'last_directory_path';

  @override
  FileExplorerState build() {
    _initializeDirectory();
    return const FileExplorerState();
  }

  void toggleOpen() {
    state = state.copyWith(isOpen: !state.isOpen);
  }

  Future<void> _initializeDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPath = prefs.getString(_lastDirectoryKey);

    if (lastPath != null && Directory(lastPath).existsSync()) {
      state = state.copyWith(currentDirectoryPath: lastPath);
      await loadFiles(lastPath);
    }
  }

  void scrollToSelected() {
    final scrollController = ref.read(
      scrollControllerByKeyProvider('fileExplorerScrollController'),
    );

    if (state.selectedItemPath == null) return;

    final selectedIndex = state.items.indexWhere(
      (item) => item.path == state.selectedItemPath,
    );
    if (selectedIndex == -1) return;

    const double itemHeight = 24.0;
    final double targetOffset = selectedIndex * itemHeight;

    final double currentOffset = scrollController.offset;
    final double viewportHeight = scrollController.position.viewportDimension;

    final double visibleStart = currentOffset;
    final double visibleEnd = currentOffset + viewportHeight;

    if (targetOffset < visibleStart || targetOffset > visibleEnd - itemHeight) {
      scrollController.jumpTo(
        (targetOffset - (viewportHeight / 2) + (itemHeight / 2)).clamp(
          0,
          scrollController.position.maxScrollExtent,
        ),
      );
    }
  }

  void moveUp() {
    if (state.selectedItemPath == null) {
      selectItem(state.items.first.path);
      return;
    }

    final currentIndex = state.items.indexWhere(
      (item) => item.path == state.selectedItemPath,
    );

    if (currentIndex > 0) {
      final newPath = state.items[currentIndex - 1].path;
      selectItem(newPath);
      scrollToSelected();
    }
  }

  void moveDown() {
    if (state.selectedItemPath == null) {
      selectItem(state.items.first.path);
      return;
    }

    final currentIndex = state.items.indexWhere(
      (item) => item.path == state.selectedItemPath,
    );

    if (currentIndex < state.items.length - 1) {
      final newPath = state.items[currentIndex + 1].path;
      selectItem(newPath);
      scrollToSelected();
    }
  }

  Future<void> selectDirectory() async {
    final newPath = await FilePicker.platform.getDirectoryPath();

    if (newPath != null) {
      state = state.copyWith(currentDirectoryPath: newPath);
      await loadFiles(newPath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastDirectoryKey, newPath);
    }
  }

  Future<void> loadFiles(String path) async {
    final directory = Directory(path);
    final entities = await directory.list().toList();

    final items =
        entities.map((entity) {
          final isDirectory = entity is Directory;
          return FileItem(isDirectory: isDirectory, path: entity.path);
        }).toList();

    items.sort((a, b) {
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;
      return p.basename(a.path).compareTo(p.basename(b.path));
    });

    state = state.copyWith(items: items);
  }

  void expandItem(String path) {
    final newItems = [...state.items];
    final itemIndex = newItems.indexWhere((item) => item.path == path);

    if (itemIndex == -1) return;

    if (!newItems[itemIndex].isDirectory) return;
    if (newItems[itemIndex].isExpanded) return moveDown();

    String currentPath = path;
    while (true) {
      final index = newItems.indexWhere((item) => item.path == currentPath);
      if (index == -1) break;

      if (!newItems[index].isExpanded) {
        toggleItemExpansion(newItems[index].path);
      }

      final parentPath = p.dirname(currentPath);
      if (parentPath == currentPath) break;
      currentPath = parentPath;
    }
  }

  void collapseItem(String path) {
    final newItems = [...state.items];
    final itemIndex = newItems.indexWhere((item) => item.path == path);

    if (itemIndex == -1) return;

    final currentLevel = newItems[itemIndex].level;

    for (int i = itemIndex; i >= 0; i--) {
      final item = newItems[i];
      if (item.isDirectory && item.level < currentLevel) {
        selectItem(item.path);
        if (item.isExpanded) {
          toggleItemExpansion(item.path);
        }
        return;
      }
    }
    return;
  }

  Future<void> toggleItemExpansion(String path) async {
    final newItems = [...state.items];
    final itemIndex = newItems.indexWhere((item) => item.path == path);

    if (itemIndex == -1) return;

    final item = newItems[itemIndex];
    if (!newItems[itemIndex].isDirectory) moveDown();

    final isExpanding = !item.isExpanded;
    newItems[itemIndex] = item.copyWith(isExpanded: isExpanding);

    if (isExpanding) {
      final directory = Directory(path);
      final entities = await directory.list().toList();

      final subItems =
          entities.map((entity) {
            final isDirectory = entity is Directory;
            return FileItem(
              isDirectory: isDirectory,
              path: entity.path,
              level: item.level + 1,
            );
          }).toList();

      subItems.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return p.basename(a.path).compareTo(p.basename(b.path));
      });

      newItems.insertAll(itemIndex + 1, subItems);
    } else {
      int i = itemIndex + 1;
      while (i < newItems.length && newItems[i].level > item.level) {
        newItems.removeAt(i);
      }
    }

    state = state.copyWith(items: newItems);
  }

  void selectItem(String path) {
    final focusNode = ref.watch(
      focusNodeByKeyProvider('fileExplorerFocusNode'),
    );
    focusNode.requestFocus();

    state = state.copyWith(
      selectedItemPath: path,
      items:
          state.items.map((item) {
            return item.copyWith(isSelected: item.path == path);
          }).toList(),
    );
  }
}
