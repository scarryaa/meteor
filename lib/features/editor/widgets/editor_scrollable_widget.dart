// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/tabs/providers/scroll_position_store.dart';
import 'package:meteor/features/editor/widgets/editor_canvas_widget.dart';
import 'package:meteor/features/editor/widgets/editor_gesture_handler_widget.dart';
import 'package:meteor/shared/providers/scroll_controller_by_key.dart';

class EditorScrollableWidget extends ConsumerStatefulWidget {
  const EditorScrollableWidget({
    super.key,
    required this.path,
    required this.constraints,
  });

  final BoxConstraints constraints;
  final String path;

  @override
  ConsumerState<EditorScrollableWidget> createState() =>
      _EditorScrollableWidgetState();
}

class _EditorScrollableWidgetState
    extends ConsumerState<EditorScrollableWidget> {
  @override
  void didUpdateWidget(EditorScrollableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        restoreScrollPosition();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      restoreScrollPosition();
    });
  }

  void restoreScrollPosition() {
    final position = ref.read(scrollPositionStoreProvider)[widget.path];
    if (position != null) {
      final vScrollController = ref.read(
        scrollControllerByKeyProvider('editorVScrollController'),
      );
      final hScrollController = ref.read(
        scrollControllerByKeyProvider('editorHScrollController'),
      );

      vScrollController.jumpTo(position.vertical);
      hScrollController.jumpTo(position.horizontal);
    } else {
      final vScrollController = ref.read(
        scrollControllerByKeyProvider('editorVScrollController'),
      );
      final hScrollController = ref.read(
        scrollControllerByKeyProvider('editorHScrollController'),
      );
      final gutterScrollController = ref.read(
        scrollControllerByKeyProvider('gutterVScrollController'),
      );

      vScrollController.jumpTo(0);
      hScrollController.jumpTo(0);
      vScrollController.notifyListeners();
      hScrollController.notifyListeners();
      gutterScrollController.notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vScrollController = ref.watch(
      scrollControllerByKeyProvider('editorVScrollController'),
    );
    final hScrollController = ref.watch(
      scrollControllerByKeyProvider('editorHScrollController'),
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        ref
            .read(scrollPositionStoreProvider.notifier)
            .savePosition(
              widget.path,
              vScrollController.offset,
              hScrollController.offset,
            );
        return false;
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        child: Scrollbar(
          controller: vScrollController,
          child: Scrollbar(
            controller: hScrollController,
            notificationPredicate: (notification) => notification.depth == 1,
            child: ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(
                scrollbars: false,
                physics: const ClampingScrollPhysics(),
                overscroll: false,
              ),
              child: SingleChildScrollView(
                controller: vScrollController,
                child: SingleChildScrollView(
                  controller: hScrollController,
                  scrollDirection: Axis.horizontal,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.text,
                    child: EditorGestureHandlerWidget(
                      path: widget.path,
                      child: ListenableBuilder(
                        listenable: Listenable.merge([
                          vScrollController,
                          hScrollController,
                        ]),
                        builder:
                            (context, child) => EditorCanvasWidget(
                              path: widget.path,
                              constraints: widget.constraints,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
