import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/providers/measurer.dart';
import 'package:meteor/features/editor/services/editor_gesture_handler.dart';

class EditorGestureHandlerWidget extends ConsumerWidget {
  const EditorGestureHandlerWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = ref.read(editorProvider.notifier);
    final state = ref.watch(editorProvider);
    final metrics = ref.watch(editorMeasurerProvider);

    final EditorGestureHandler gestureHandler = EditorGestureHandler(
      context,
      editor,
      state,
      metrics,
    );

    return GestureDetector(
      onTapDown: (details) => gestureHandler.handleTapDown(details),
      onPanStart: (details) => gestureHandler.handlePanStart(details),
      onPanUpdate: (details) => gestureHandler.handlePanUpdate(details),
      child: child,
    );
  }
}
