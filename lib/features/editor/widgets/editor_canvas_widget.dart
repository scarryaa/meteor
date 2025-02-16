import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/providers/measurer.dart';
import 'package:meteor/features/editor/widgets/editor_painter.dart';

class EditorCanvasWidget extends ConsumerWidget {
  const EditorCanvasWidget({super.key, required this.constraints});

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(editorMeasurerProvider);
    final measurer = ref.read(editorMeasurerProvider.notifier);
    final state = ref.watch(editorProvider);

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
        metrics: metrics,
      ),
    );
  }
}
