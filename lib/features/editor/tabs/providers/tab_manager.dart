import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart' hide Tab;
import 'package:meteor/features/dialogs/unsaved_changes_dialog/widgets/unsaved_changes_dialog_widget.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/tabs/models/tab.dart';
import 'package:meteor/features/editor/tabs/providers/scroll_position_store.dart';
import 'package:meteor/shared/providers/focus_node_by_key.dart';
import 'package:meteor/shared/providers/save_manager.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_manager.g.dart';

@riverpod
class TabManager extends _$TabManager {
  @override
  List<Tab> build() {
    return [];
  }

  Future<bool> showUnsavedChangesDialog(
    BuildContext context,
    String path,
  ) async {
    final tab = state.firstWhere((tab) => tab.path == path);
    if (!tab.isDirty) return true;

    final completer = Completer<bool>();

    showDialog(
      context: context,
      barrierColor: const Color(0x80000000),
      builder:
          (context) => UnsavedChangesDialogWidget(
            fileName: tab.name,
            onSave: () {
              Navigator.of(context).pop();
              ref
                  .read(saveManagerProvider.notifier)
                  .save(path, ref.read(editorProvider(path)).buffer.toString());
              completer.complete(true);
            },
            onDiscard: () {
              Navigator.of(context).pop();
              completer.complete(true);
            },
            onCancel: () {
              Navigator.of(context).pop();
              completer.complete(false);
            },
          ),
    );

    return completer.future;
  }

  Tab? getActiveTab() {
    if (state.isEmpty || !state.any((tab) => tab.isActive)) {
      return null;
    }

    return state.firstWhere((tab) => tab.isActive);
  }

  bool hasTab(String path) {
    return state.indexWhere((tab) => tab.path == path) != -1;
  }

  void removeTabByPath(String path) {
    final index = state.indexWhere((tab) => tab.path == path);

    if (index != -1) {
      final newState = [...state];
      newState.removeAt(index);

      if (newState.isNotEmpty && !newState.any((tab) => tab.isActive)) {
        newState.last = newState.last.copyWith(isActive: true);
      }

      ref.read(scrollPositionStoreProvider.notifier).removePosition(path);
      ref.invalidate(editorProvider(path));

      state = newState;
    }

    if (state.isEmpty) {
      ref.read(focusNodeByKeyProvider('editorFocusNode')).unfocus();

      // TODO find a better method?
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(focusNodeByKeyProvider('mainFocusNode')).requestFocus();
      });
    }
  }

  void addTab(String path, {String name = 'Untitled'}) {
    // Check if path is empty
    if (path.isEmpty) {
      path = 'meteor-tmp-${Random().nextInt(999999999)}';
    }

    // Check if tab already exists
    if (state.any((tab) => tab.path == path)) {
      state =
          state
              .map(
                (tab) =>
                    tab.path == path
                        ? tab.copyWith(isActive: true)
                        : tab.copyWith(isActive: false),
              )
              .toList();
      return;
    }

    final newTab = Tab(path: path, name: name, isActive: true);

    state = [...state.map((tab) => tab.copyWith(isActive: false)), newTab];
  }

  void removeTab(int index) {
    final newState = [...state];
    newState.removeAt(index);

    if (newState.isNotEmpty && !newState.any((tab) => tab.isActive)) {
      newState.last = newState.last.copyWith(isActive: true);
    }

    state = newState;
  }

  void setTabActive(String path) {
    state =
        state.map((tab) => tab.copyWith(isActive: tab.path == path)).toList();
  }

  void setTabDirty(String path, {required bool isDirty}) {
    state =
        state
            .map(
              (tab) => tab.path == path ? tab.copyWith(isDirty: isDirty) : tab,
            )
            .toList();
  }

  void updateTabPath(String oldPath, String newPath) {
    final oldEditorState = ref.read(editorProvider(oldPath));

    final scrollStore = ref.read(scrollPositionStoreProvider.notifier);
    final scrollPosition = scrollStore.getPosition(oldPath);
    if (scrollPosition != null) {
      scrollStore.removePosition(oldPath);
      scrollStore.savePosition(
        newPath,
        scrollPosition.vertical,
        scrollPosition.horizontal,
      );
    }

    state =
        state
            .map(
              (tab) => tab.path == oldPath ? tab.copyWith(path: newPath) : tab,
            )
            .toList();

    ref.invalidate(editorProvider(oldPath));

    ref.read(editorProvider(newPath).notifier).state = oldEditorState;
    updateTabName(newPath, basename(newPath));
  }

  void updateTabName(String path, String newName) {
    state =
        state
            .map((tab) => tab.path == path ? tab.copyWith(name: newName) : tab)
            .toList();
  }
}
