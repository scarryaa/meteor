import 'package:meteor/features/editor/models/state.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/tabs/providers/tab_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'editor_manager.g.dart';

@riverpod
class EditorManager extends _$EditorManager {
  final Map<String, Editor> _editors = {};

  @override
  Map<String, EditorState> build() {
    return {};
  }

  Editor getOrCreateEditor(String path) {
    if (!_editors.containsKey(path)) {
      _editors[path] = Editor();
      state = {...state, path: _editors[path]!.state};
    }
    return _editors[path]!;
  }

  void removeEditor(String path) {
    _editors.remove(path);
    final newState = {...state};
    newState.remove(path);
    state = newState;
  }

  Editor? getActiveEditor() {
    final activeTab = ref.read(tabManagerProvider.notifier).getActiveTab();

    if (activeTab != null) {
      if (activeTab.path.isEmpty) return null;
      return getOrCreateEditor(activeTab.path);
    } else {
      return null;
    }
  }
}
