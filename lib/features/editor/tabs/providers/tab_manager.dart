import 'dart:math';

import 'package:meteor/features/editor/tabs/models/tab.dart';
import 'package:meteor/features/editor/tabs/providers/scroll_position_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_manager.g.dart';

@riverpod
class TabManager extends _$TabManager {
  @override
  List<Tab> build() {
    return [];
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

      state = newState;
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

  void updateTabName(String path, String newName) {
    state =
        state
            .map((tab) => tab.path == path ? tab.copyWith(name: newName) : tab)
            .toList();
  }
}
