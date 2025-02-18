import 'dart:ffi' hide Size;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meteor/bindings/tree-sitter/tree_sitter_bindings.dart';
import 'package:meteor/features/editor/models/metrics.dart';
import 'package:meteor/features/editor/models/selection.dart';
import 'package:meteor/features/editor/providers/tree_sitter_manager.dart';
import 'package:meteor/features/editor/services/syntax_highlighter.dart';
import 'package:meteor/shared/models/cursor.dart';
import 'package:meteor/shared/models/visible_lines.dart';

class EditorPainter extends CustomPainter {
  EditorPainter({
    required List<String> lines,
    required Cursor cursor,
    required Selection selection,
    required EditorMetrics metrics,
    required VisibleLines visibleLines,
    required TreeSitterManager treeSitterManager,
    required Pointer<TSTree> tree,
  }) : _syntaxHighlighter = SyntaxHighlighter(
         treeSitterManager: treeSitterManager,
         tree: tree,
       ),
       _textPainter = TextPainter(textDirection: TextDirection.ltr),
       _lines = lines,
       _cursor = cursor,
       _selection = selection,
       _metrics = metrics,
       _visibleLines = visibleLines;

  final TextPainter _textPainter;
  final List<String> _lines;
  final Cursor _cursor;
  final Selection _selection;
  final EditorMetrics _metrics;
  final VisibleLines _visibleLines;

  final SyntaxHighlighter _syntaxHighlighter;

  static const fontFamily = 'MesloLGL Nerd Font Mono';
  static const fontSize = 15.0;
  static const lineHeight = 1.5;
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

  String _getVisibleText(String line) {
    final int start = min(_visibleLines.firstVisibleChar!, line.length);
    final int end = min(_visibleLines.lastVisibleChar!, line.length);
    return line.substring(start, end);
  }

  void _drawText(Canvas canvas, Size size) {
    for (
      int lineIndex = _visibleLines.firstVisibleLine;
      lineIndex < min(_visibleLines.lastVisibleLine, _lines.length);
      lineIndex++
    ) {
      final String currentLine = _lines[lineIndex];
      final String visibleText = _getVisibleText(currentLine);

      int contextStart = _lines.take(lineIndex).join('\n').length;
      if (lineIndex > 0) {
        contextStart += 1;
      }
      contextStart += _visibleLines.firstVisibleChar!;

      final List<TextSpan> highlightedSpans = _syntaxHighlighter.highlightText(
        visibleText,
        _lines.join('\n'),
        contextStart,
      );

      _textPainter
        ..text = TextSpan(
          children: highlightedSpans,
          style: const TextStyle(
            fontSize: fontSize,
            fontFamily: fontFamily,
            height: lineHeight,
          ),
        )
        ..layout(maxWidth: size.width)
        ..paint(canvas, Offset(0, (lineIndex) * _metrics.lineHeight));
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

    // Early return if selection is completely outside visible region
    if (normalized.focus.line < _visibleLines.firstVisibleLine &&
            normalized.anchor.line < _visibleLines.firstVisibleLine ||
        normalized.focus.line > _visibleLines.lastVisibleLine &&
            normalized.anchor.line > _visibleLines.lastVisibleLine) {
      return;
    }

    if (normalized.anchor.line == normalized.focus.line) {
      // Single-line selection
      if (normalized.anchor.line < _visibleLines.firstVisibleLine ||
          normalized.anchor.line >= _visibleLines.lastVisibleLine) {
        return;
      }

      final lineLength = _lines[normalized.anchor.line].length;

      double left = normalized.anchor.column * _metrics.charWidth;
      double top = normalized.anchor.line * _metrics.lineHeight;
      double width = min(
        (normalized.focus.column - normalized.anchor.column) *
            _metrics.charWidth,
        (lineLength - normalized.anchor.column) * _metrics.charWidth,
      );

      canvas.drawRect(
        Rect.fromLTWH(left, top, width, selectionHeight),
        selectionPaint,
      );
    } else {
      // Multi-line selection

      // First line
      final cursorOnFirstLine = _cursor.line == normalized.anchor.line;
      if (normalized.anchor.line >= _visibleLines.firstVisibleLine &&
          normalized.anchor.line < _visibleLines.lastVisibleLine) {
        final firstLineLength = _lines[normalized.anchor.line].length;

        double firstLeft = normalized.anchor.column * _metrics.charWidth;
        double firstTop = normalized.anchor.line * _metrics.lineHeight;
        double firstWidth = max(
          cursorOnFirstLine ? 0 : _metrics.charWidth,
          (firstLineLength - normalized.anchor.column) * _metrics.charWidth,
        );

        canvas.drawRect(
          Rect.fromLTWH(firstLeft, firstTop, firstWidth, selectionHeight),
          selectionPaint,
        );
      }

      // Middle lines
      for (
        int i = max(normalized.anchor.line + 1, _visibleLines.firstVisibleLine);
        i < min(normalized.focus.line, _visibleLines.lastVisibleLine);
        i++
      ) {
        final lineLength = _lines[i].length;

        double left = 0;
        double top = i * _metrics.lineHeight;
        double width = max(_metrics.charWidth, lineLength * _metrics.charWidth);

        canvas.drawRect(
          Rect.fromLTWH(left, top, width, selectionHeight),
          selectionPaint,
        );
      }

      // Last line
      final cursorOnLastLine = _cursor.line == normalized.focus.line;
      if (normalized.focus.line >= _visibleLines.firstVisibleLine &&
          normalized.focus.line < _visibleLines.lastVisibleLine) {
        final lastLineLength = _lines[normalized.focus.line].length;

        double lastLeft = 0;
        double lastTop = normalized.focus.line * _metrics.lineHeight;
        double lastWidth = min(
          normalized.focus.column * _metrics.charWidth,
          lastLineLength * _metrics.charWidth,
        );

        if (normalized.focus.column == 0 && !cursorOnLastLine) {
          lastWidth = max(_metrics.charWidth, lastWidth);
        }

        canvas.drawRect(
          Rect.fromLTWH(lastLeft, lastTop, lastWidth, selectionHeight),
          selectionPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant EditorPainter oldDelegate) {
    return _lines != oldDelegate._lines ||
        _cursor != oldDelegate._cursor ||
        _selection != oldDelegate._selection ||
        _metrics != oldDelegate._metrics ||
        _visibleLines != oldDelegate._visibleLines;
  }
}
