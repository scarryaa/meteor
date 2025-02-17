import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'focus_node_by_key.g.dart';

@riverpod
class FocusNodeByKey extends _$FocusNodeByKey {
  @override
  FocusNode build(String key) {
    FocusNode focusNode = FocusNode();

    ref.onDispose(() => focusNode.dispose());

    return focusNode;
  }
}
