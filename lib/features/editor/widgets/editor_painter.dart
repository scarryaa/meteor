import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meteor/features/editor/models/metrics.dart';
import 'package:meteor/features/editor/models/selection.dart';
import 'package:meteor/shared/models/cursor.dart';

class EditorPainter extends CustomPainter {
  EditorPainter({
    required List<String> lines,
    required Cursor cursor,
    required Selection selection,
    required EditorMetrics metrics,
  }) : _textPainter = TextPainter(textDirection: TextDirection.ltr),
       _lines = lines,
       _cursor = cursor,
       _selection = selection,
       _metrics = metrics;

  final TextPainter _textPainter;
  final List<String> _lines;
  final Cursor _cursor;
  final Selection _selection;
  final EditorMetrics _metrics;

  static const fontFamily = 'MesloLGL Nerd Font Mono';
  static const fontSize = 15.0;
  static const fontColor = Color(0xFFFCFCFC);

  static final cursorPaint = Paint()..color = Colors.purple;
  static const cursorWidth = 2.0;

  static final selectionPaint =
      Paint()..color = Colors.purple.withValues(alpha: 0.3);

  @override
  void paint(Canvas canvas, Size size) {
    _drawText(canvas, size);
    _drawCursor(canvas, size);
    _drawSelection(canvas, size);
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

  void _drawSelection(Canvas canvas, Size size) {
    final normalized = _selection.normalized();

    if (normalized == Selection.empty) return;

    final selectionHeight = _metrics.lineHeight;

    if (normalized.anchor.line == normalized.focus.line) {
      // Single-line selection

      double left = normalized.anchor.column * _metrics.charWidth;
      double top = normalized.anchor.line * _metrics.lineHeight;
      double width =
          (_lines[normalized.anchor.line].length - normalized.anchor.column) *
          _metrics.charWidth;

      canvas.drawRect(
        Rect.fromLTWH(left, top, width, selectionHeight),
        selectionPaint,
      );
    } else {
      // Multi-line selection

      // First line
      final cursorOnFirstLine = _cursor.line == normalized.anchor.line;
      double firstLeft = normalized.anchor.column * _metrics.charWidth;
      double firstTop = normalized.anchor.line * _metrics.lineHeight;
      double firstWidth =
          cursorOnFirstLine
              ? (_lines[normalized.anchor.line].length -
                      normalized.anchor.column) *
                  _metrics.charWidth
              : max(
                _metrics.charWidth,
                (_lines[normalized.anchor.line].length -
                        normalized.anchor.column) *
                    _metrics.charWidth,
              );

      canvas.drawRect(
        Rect.fromLTWH(firstLeft, firstTop, firstWidth, selectionHeight),
        selectionPaint,
      );

      // Middle lines
      for (int i = normalized.anchor.line + 1; i < normalized.focus.line; i++) {
        double left = 0;
        double top = i * _metrics.lineHeight;
        double width = max(
          _metrics.charWidth,
          _lines[i].length * _metrics.charWidth,
        );

        canvas.drawRect(
          Rect.fromLTWH(left, top, width, selectionHeight),
          selectionPaint,
        );
      }

      // Last line
      final cursorOnLastLine = _cursor.line == normalized.focus.line;
      double lastLeft = 0;
      double lastTop = normalized.focus.line * _metrics.lineHeight;
      double lastWidth =
          cursorOnLastLine
              ? normalized.focus.column * _metrics.charWidth
              : max(
                normalized.focus.column * _metrics.charWidth,
                _metrics.charWidth,
              );

      canvas.drawRect(
        Rect.fromLTWH(lastLeft, lastTop, lastWidth, selectionHeight),
        selectionPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
