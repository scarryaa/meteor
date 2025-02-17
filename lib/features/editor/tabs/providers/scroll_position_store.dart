import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scroll_position_store.g.dart';

@Riverpod(keepAlive: true)
class ScrollPositionStore extends _$ScrollPositionStore {
  @override
  Map<String, ({double vertical, double horizontal})> build() {
    return {};
  }

  void savePosition(String path, double vertical, double horizontal) {
    state = {...state, path: (vertical: vertical, horizontal: horizontal)};
  }

  ({double vertical, double horizontal})? getPosition(String path) {
    return state[path];
  }

  void removePosition(String path) {
    state = Map.from(state)..remove(path);
  }
}
