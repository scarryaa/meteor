import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scroll_controller_by_key.g.dart';

@riverpod
class ScrollControllerByKey extends _$ScrollControllerByKey {
  @override
  ScrollController build(String key) {
    ScrollController scrollController = ScrollController();

    ref.onDispose(() => scrollController.dispose());

    return scrollController;
  }
}
