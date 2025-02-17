import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meteor/features/editor/interfaces/buffer.dart';
import 'package:meteor/features/gutter/models/metrics.dart';
import 'package:meteor/shared/models/visible_lines.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'measurer.g.dart';

@riverpod
class GutterMeasurer extends _$GutterMeasurer {
  late TextPainter _textPainter;
  late GutterMetrics _metrics;

  @override
  GutterMetrics build() {
    _textPainter =
        TextPainter(textDirection: TextDirection.ltr)
          ..text = TextSpan(
            text: '1',
            style: TextStyle(
              fontSize: 15.0,
              height: 1.5,
              fontFamily: 'MesloLGL Nerd Font Mono',
            ),
          )
          ..layout();

    _metrics = GutterMetrics(
      charWidth: _textPainter.width,
      lineHeight: _textPainter.height,
      widthPadding: 70,
      heightPadding: _textPainter.height * 5,
    );

    return _metrics;
  }

  Size getSize(BoxConstraints? constraints, int lineCount) {
    double contentHeight = lineCount * _metrics.lineHeight;
    double contentWidth = lineCount.toString().length * _metrics.charWidth;

    double width = contentWidth + _metrics.widthPadding;
    double height = contentHeight + _metrics.heightPadding;

    if (constraints != null) {
      height = max(height, constraints.maxHeight);
    }

    return Size(width, height);
  }

  VisibleLines getVisibleLines(
    IBuffer buffer,
    double viewportHeight,
    double vScrollOffset,
  ) {
    final firstVisibleLine = (vScrollOffset / _metrics.lineHeight).floor();
    final lastVisibleLine = min(
      ((viewportHeight + vScrollOffset) / _metrics.lineHeight).ceil(),
      buffer.lineCount,
    );

    return VisibleLines(
      firstVisibleLine: firstVisibleLine,
      lastVisibleLine: lastVisibleLine,
      firstVisibleChar: null,
      lastVisibleChar: null,
    );
  }
}
