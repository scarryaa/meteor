import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/providers/measurer.dart';
import 'package:meteor/features/editor/services/editor_gesture_handler.dart';
import 'package:meteor/shared/providers/focus_node_by_key.dart';
import 'package:meteor/shared/providers/scroll_controller_by_key.dart';

class EditorGestureHandlerWidget extends ConsumerWidget {
  const EditorGestureHandlerWidget({
    super.key,
    required this.path,
    required this.child,
  });

  final Widget child;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = ref.read(editorProvider(path).notifier);
    final state = ref.watch(editorProvider(path));
    final metrics = ref.watch(editorMeasurerProvider);
    final vScrollController = ref.watch(
      scrollControllerByKeyProvider('editorVScrollController'),
    );
    final hScrollController = ref.watch(
      scrollControllerByKeyProvider('editorHScrollController'),
    );

    final EditorGestureHandler gestureHandler = EditorGestureHandler(
      context,
      editor,
      state,
      metrics,
      vScrollController,
      hScrollController,
    );

    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTapDown: (details) {
        ref.read(focusNodeByKeyProvider('editorFocusNode')).requestFocus();
        gestureHandler.handleTapDown(details);
      },
      onPanStart: (details) => gestureHandler.handlePanStart(details),
      onPanUpdate: (details) => gestureHandler.handlePanUpdate(details),
      child: child,
    );
  }
}
