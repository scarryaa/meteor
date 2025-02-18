import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:meteor/features/file_explorer/models/file_item.dart';
import 'package:meteor/features/file_explorer/models/state.dart';
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

  Future<void> toggleItemExpansion(String path) async {
    final newItems = [...state.items];
    final itemIndex = newItems.indexWhere((item) => item.path == path);

    if (itemIndex == -1) return;

    final item = newItems[itemIndex];
    if (!item.isDirectory) return;

    newItems[itemIndex] = item.copyWith(isExpanded: !item.isExpanded);

    if (newItems[itemIndex].isExpanded) {
      final directory = Directory(path);
      final entities = await directory.list().toList();

      final subItems =
          entities.map((entity) {
            final isDirectory = entity is Directory;
            return FileItem(isDirectory: isDirectory, path: entity.path);
          }).toList();

      subItems.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return p.basename(a.path).compareTo(p.basename(b.path));
      });

      newItems.insertAll(itemIndex + 1, subItems);
    } else {
      final basePath = path + Platform.pathSeparator;
      newItems.removeWhere(
        (item) => item.path.startsWith(basePath) && item.path != path,
      );
    }

    state = state.copyWith(items: newItems);
  }

  void selectItem(String path) {
    state = state.copyWith(
      items:
          state.items.map((item) {
            return item.copyWith(isSelected: item.path == path);
          }).toList(),
    );
  }
}
