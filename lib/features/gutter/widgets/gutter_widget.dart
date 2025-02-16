import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/gutter/providers/measurer.dart';
import 'package:meteor/features/gutter/widgets/gutter_painter.dart';
import 'package:meteor/shared/providers/scroll_controller_by_key.dart';

class GutterWidget extends ConsumerStatefulWidget {
  const GutterWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => GutterWidgetState();
}

class GutterWidgetState extends ConsumerState<GutterWidget> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addScrollListeners();
    });
  }

  void _addScrollListeners() {
    final gutterScrollController = ref.read(
      scrollControllerByKeyProvider('gutterVScrollController'),
    );
    final editorScrollController = ref.read(
      scrollControllerByKeyProvider('editorVScrollController'),
    );

    gutterScrollController.addListener(_syncEditorScroll);
    editorScrollController.addListener(_syncGutterScroll);
  }

  void _syncEditorScroll() {
    final gutterScrollController = ref.read(
      scrollControllerByKeyProvider('gutterVScrollController'),
    );
    final editorScrollController = ref.read(
      scrollControllerByKeyProvider('editorVScrollController'),
    );

    if (gutterScrollController.offset != editorScrollController.offset) {
      editorScrollController.jumpTo(gutterScrollController.offset);
    }
  }

  void _syncGutterScroll() {
    final gutterScrollController = ref.read(
      scrollControllerByKeyProvider('gutterVScrollController'),
    );
    final editorScrollController = ref.read(
      scrollControllerByKeyProvider('editorVScrollController'),
    );

    if (gutterScrollController.offset != editorScrollController.offset) {
      gutterScrollController.jumpTo(editorScrollController.offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final measurer = ref.read(gutterMeasurerProvider.notifier);
    final metrics = ref.watch(gutterMeasurerProvider);
    final vScrollController = ref.watch(
      scrollControllerByKeyProvider('gutterVScrollController'),
    );

    return LayoutBuilder(
      builder:
          (context, constraints) => ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(
              scrollbars: false,
              physics: ClampingScrollPhysics(),
              overscroll: false,
            ),
            child: SingleChildScrollView(
              controller: vScrollController,
              child: ListenableBuilder(
                listenable: vScrollController,
                builder: (context, child) {
                  final viewportHeight = constraints.maxHeight;
                  final double vOffset =
                      vScrollController.hasClients
                          ? vScrollController.offset
                          : 0;

                  final visibleLines = measurer.getVisibleLines(
                    state.buffer,
                    viewportHeight,
                    vOffset,
                  );

                  return CustomPaint(
                    willChange: true,
                    isComplex: true,
                    size: measurer.getSize(
                      constraints,
                      state.buffer.lineCount - 1,
                    ),
                    painter: GutterPainter(
                      cursor: state.cursor,
                      selection: state.selection,
                      metrics: metrics,
                      visibleLines: visibleLines,
                    ),
                  );
                },
              ),
            ),
          ),
    );
  }
}
