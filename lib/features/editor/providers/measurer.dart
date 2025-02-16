import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meteor/features/editor/models/metrics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'measurer.g.dart';

@riverpod
class EditorMeasurer extends _$EditorMeasurer {
  late TextPainter _textPainter;
  late EditorMetrics _metrics;

  @override
  EditorMetrics build() {
    _textPainter =
        TextPainter(textDirection: TextDirection.ltr)
          ..text = TextSpan(
            text: 'M',
            style: TextStyle(
              fontSize: 15.0,
              fontFamily: 'MesloLGL Nerd Font Mono',
            ),
          )
          ..layout();

    _metrics = EditorMetrics(
      charWidth: _textPainter.width,
      lineHeight: _textPainter.height,
      widthPadding: _textPainter.width * 10,
      heightPadding: _textPainter.height * 5,
    );

    return _metrics;
  }

  Size getSize(
    BoxConstraints? constraints,
    int lineCount,
    int longestLineLength,
  ) {
    double contentHeight = lineCount * _metrics.lineHeight;
    double contentWidth = longestLineLength * _metrics.charWidth;

    double width = contentWidth + _metrics.widthPadding;
    double height = contentHeight + _metrics.heightPadding;

    if (constraints != null) {
      width = max(width, constraints.maxWidth);
      height = max(height, constraints.maxHeight);
    }

    return Size(width, height);
  }
}
