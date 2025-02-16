import 'package:flutter/material.dart';
import 'package:meteor/features/editor/widgets/editor_painter.dart';

class EditorWidget extends StatelessWidget {
  const EditorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: EditorPainter(lines: ['Hello world!']));
  }
}
