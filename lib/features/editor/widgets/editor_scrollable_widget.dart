import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/widgets/editor_canvas_widget.dart';
import 'package:meteor/features/editor/widgets/editor_gesture_handler_widget.dart';
import 'package:meteor/shared/providers/scroll_controller_by_key.dart';

class EditorScrollableWidget extends ConsumerWidget {
  const EditorScrollableWidget({super.key, required this.constraints});

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vScrollController = ref.watch(
      scrollControllerByKeyProvider('editorVScrollController'),
    );
    final hScrollController = ref.watch(
      scrollControllerByKeyProvider('editorHScrollController'),
    );

    return Scrollbar(
      controller: vScrollController,
      child: Scrollbar(
        controller: hScrollController,
        notificationPredicate: (notification) => notification.depth == 1,
        child: ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(
            scrollbars: false,
            physics: ClampingScrollPhysics(),
            overscroll: false,
          ),
          child: SingleChildScrollView(
            controller: vScrollController,
            child: SingleChildScrollView(
              controller: hScrollController,
              scrollDirection: Axis.horizontal,
              child: EditorGestureHandlerWidget(
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    vScrollController,
                    hScrollController,
                  ]),
                  builder:
                      (context, child) =>
                          EditorCanvasWidget(constraints: constraints),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
