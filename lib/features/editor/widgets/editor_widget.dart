import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/providers/measurer.dart';
import 'package:meteor/features/editor/services/editor_keyboard_handler.dart';
import 'package:meteor/features/editor/widgets/editor_painter.dart';

class EditorWidget extends ConsumerWidget {
  const EditorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = ref.read(editorProvider.notifier);
    final state = ref.watch(editorProvider);
    final metrics = ref.watch(editorMeasurerProvider);
    final measurer = ref.read(editorMeasurerProvider.notifier);

    final keyboardHandler = EditorKeyboardHandler(editor, state);

    return LayoutBuilder(
      builder:
          (context, constraints) => Focus(
            autofocus: true,
            onKeyEvent: keyboardHandler.handleKeyEvent,
            child: CustomPaint(
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
            ),
          ),
    );
  }
}
