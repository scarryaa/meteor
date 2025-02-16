import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/services/editor_keyboard_handler.dart';
import 'package:meteor/features/editor/widgets/editor_painter.dart';

class EditorWidget extends ConsumerWidget {
  const EditorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = ref.read(editorProvider.notifier);
    final state = ref.watch(editorProvider);

    final keyboardHandler = EditorKeyboardHandler(editor, state);

    return Focus(
      autofocus: true,
      onKeyEvent: keyboardHandler.handleKeyEvent,
      child: CustomPaint(painter: EditorPainter(lines: state.buffer.lines)),
    );
  }
}
