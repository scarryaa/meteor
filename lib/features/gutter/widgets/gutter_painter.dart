import 'package:flutter/material.dart';
import 'package:meteor/features/editor/models/selection.dart';
import 'package:meteor/features/gutter/models/metrics.dart';
import 'package:meteor/shared/models/cursor.dart';
import 'package:meteor/shared/models/visible_lines.dart';

class GutterPainter extends CustomPainter {
  GutterPainter({
    required Cursor cursor,
    required Selection selection,
    required GutterMetrics metrics,
    required VisibleLines visibleLines,
  }) : _textPainter = TextPainter(textDirection: TextDirection.ltr),
       _cursor = cursor,
       _selection = selection,
       _metrics = metrics,
       _visibleLines = visibleLines;

  final TextPainter _textPainter;
  final Cursor _cursor;
  final Selection _selection;
  final GutterMetrics _metrics;
  final VisibleLines _visibleLines;

  @override
  void paint(Canvas canvas, Size size) {
    _drawLines(canvas, size);
  }

  void _drawLines(Canvas canvas, Size size) {
    for (
      int i = _visibleLines.firstVisibleLine;
      i < _visibleLines.lastVisibleLine;
      i++
    ) {
      bool isHighlighted =
          i == _cursor.line ||
          (i >= _selection.normalized().anchor.line &&
              i <= _selection.normalized().focus.line);

      _textPainter
        ..text = TextSpan(
          text: (i + 1).toString(),
          style: TextStyle(
            color:
                isHighlighted
                    ? const Color(0xFFFFFFFF)
                    : const Color(0x50FFFFFF),
            fontFamily: 'MesloLGL Nerd Font Mono',
            height: 1.5,
            fontSize: 15.0,
          ),
        )
        ..layout()
        ..paint(
          canvas,
          Offset(
            (size.width - _textPainter.width - _metrics.charWidth) / 2,
            _metrics.lineHeight * i,
          ),
        );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
