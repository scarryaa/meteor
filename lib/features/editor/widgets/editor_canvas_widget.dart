import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/providers/measurer.dart';
import 'package:meteor/features/editor/widgets/editor_painter.dart';
import 'package:meteor/shared/providers/scroll_controller_by_key.dart';

class EditorCanvasWidget extends ConsumerWidget {
  const EditorCanvasWidget({
    super.key,
    required this.path,
    required this.constraints,
  });

  final BoxConstraints constraints;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(editorMeasurerProvider);
    final measurer = ref.read(editorMeasurerProvider.notifier);
    final state = ref.watch(editorProvider(path));
    final vScrollController = ref.watch(
      scrollControllerByKeyProvider('editorVScrollController'),
    );
    final hScrollController = ref.watch(
      scrollControllerByKeyProvider('editorHScrollController'),
    );
    final double vOffset =
        vScrollController.hasClients ? vScrollController.offset : 0;
    final double hOffset =
        hScrollController.hasClients ? hScrollController.offset : 0;

    final visibleLines = measurer.getVisibleLines(
      state.buffer,
      constraints.maxWidth,
      constraints.maxHeight,
      vOffset,
      hOffset,
    );

    return CustomPaint(
      willChange: true,
      isComplex: true,
      size: measurer.getSize(
        constraints,
        state.buffer.lineCount - 1,
        state.buffer.longestLineLength,
      ),
      painter: EditorPainter(
        lines: state.buffer.lines,
        cursor: state.cursor,
        selection: state.selection,
        metrics: metrics,
        visibleLines: visibleLines,
      ),
    );
  }
}
