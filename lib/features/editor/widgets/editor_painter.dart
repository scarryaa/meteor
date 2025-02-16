import 'package:flutter/material.dart';
import 'package:meteor/features/editor/models/metrics.dart';
import 'package:meteor/shared/models/cursor.dart';

class EditorPainter extends CustomPainter {
  EditorPainter({
    required List<String> lines,
    required Cursor cursor,
    required EditorMetrics metrics,
  }) : _textPainter = TextPainter(textDirection: TextDirection.ltr),
       _lines = lines,
       _cursor = cursor,
       _metrics = metrics;

  final TextPainter _textPainter;
  final List<String> _lines;
  final Cursor _cursor;
  final EditorMetrics _metrics;

  static const fontFamily = 'MesloLGL Nerd Font Mono';
  static const fontSize = 15.0;
  static const fontColor = Color(0xFFFCFCFC);

  static final cursorPaint = Paint()..color = Colors.purple;
  static const cursorWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    _drawText(canvas, size);
    _drawCursor(canvas, size);
  }

  void _drawText(Canvas canvas, Size size) {
    for (int i = 0; i < _lines.length; i++) {
      _textPainter
        ..text = TextSpan(
          text: _lines[i],
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: fontFamily,
            color: fontColor,
          ),
        )
        ..layout()
        ..paint(canvas, Offset(0, i * _textPainter.height));
    }
  }

  void _drawCursor(Canvas canvas, Size size) {
    final double left = _cursor.column * _metrics.charWidth;
    final double top = _cursor.line * _metrics.lineHeight;
    final double cursorHeight = _metrics.lineHeight;

    canvas.drawRect(
      Rect.fromLTWH(left, top, cursorWidth, cursorHeight),
      cursorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
