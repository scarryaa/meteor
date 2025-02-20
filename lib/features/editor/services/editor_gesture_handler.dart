import 'package:flutter/material.dart';
import 'package:meteor/features/editor/models/metrics.dart';
import 'package:meteor/features/editor/models/state.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/shared/models/position.dart';

class EditorGestureHandler {
  final BuildContext context;
  final EditorState state;
  final Editor editor;
  final EditorMetrics metrics;
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;

  EditorGestureHandler(
    this.context,
    this.editor,
    this.state,
    this.metrics,
    this.verticalScrollController,
    this.horizontalScrollController,
  );

  Position _positionFromOffset(Offset offset) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset adjustedOffset = renderBox.globalToLocal(offset);

    adjustedOffset = Offset(adjustedOffset.dx, adjustedOffset.dy);

    final targetLine = (adjustedOffset.dy / metrics.lineHeight).floor();
    final targetColumn = (adjustedOffset.dx / metrics.charWidth).floor();

    final clampedLine = targetLine.clamp(0, state.buffer.lineCount - 1);
    final clampedColumn = targetColumn.clamp(
      0,
      state.buffer.getLineLength(clampedLine),
    );

    return Position(line: clampedLine, column: clampedColumn);
  }

  void handleTapDown(TapDownDetails details) {
    Position position = _positionFromOffset(details.globalPosition);

    editor.moveTo(position);
  }

  void handlePanStart(DragStartDetails details) {
    Position position = _positionFromOffset(details.globalPosition);

    editor.moveTo(position);
  }

  void handlePanUpdate(DragUpdateDetails details) {
    Position position = _positionFromOffset(details.globalPosition);

    editor.moveTo(position, extendSelection: true);
  }
}
