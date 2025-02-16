import 'dart:math';

import 'package:meteor/features/editor/interfaces/buffer.dart';
import 'package:meteor/features/editor/models/delete_result.dart';
import 'package:meteor/shared/models/position.dart';

class LineBuffer extends IBuffer {
  LineBuffer({List<String>? lines}) : _lines = lines ?? [''];

  final List<String> _lines;

  @override
  DeleteResult delete(Position start, Position end) {
    final newLines = List.of(_lines);

    if (start.column == -1 && start.line != 0) {
      // 'Backspace'
      return _mergeLines(start.line);
    } else if (start.column == -1 && start.line == 0) {
      return DeleteResult(newBuffer: this, mergePosition: Position.zero);
    }

    if (start.line == end.line) {
      // Single-line delete
      newLines[start.line] =
          newLines[start.line].substring(0, start.column) +
          newLines[start.line].substring(end.column);
    } else {
      // Multi-line delete
      // First line
      newLines[start.line] = newLines[start.line].substring(0, start.column);

      // Last line
      newLines[end.line] = newLines[end.line].substring(end.column);
      if (newLines[end.line].isEmpty) newLines.removeAt(end.line);

      // Middle lines
      newLines.removeRange(start.line + 1, end.line);
    }

    return DeleteResult(
      newBuffer: LineBuffer(lines: newLines),
      mergePosition: Position.zero,
    );
  }

  DeleteResult _mergeLines(int line) {
    final newLines = List.of(_lines);

    Position newPosition = Position(
      line: line - 1,
      column: getLineLength(line - 1),
    );
    newLines[line - 1] += newLines[line];
    newLines.removeAt(line);

    return DeleteResult(
      newBuffer: LineBuffer(lines: newLines),
      mergePosition: newPosition,
    );
  }

  @override
  String getLine(int line) {
    if (line > lineCount - 1 || line < 0) {
      throw RangeError('line cannot be greater than line count or less than 0');
    }

    return _lines[line];
  }

  @override
  int getLineLength(int line) {
    if (line > lineCount - 1 || line < 0) {
      throw RangeError('line cannot be greater than line count or less than 0');
    }

    return _lines[line].length;
  }

  @override
  IBuffer insert(Position position, String text) {
    if (position.line >= _lines.length ||
        position.line < 0 ||
        (position.column > _lines[position.line].length) ||
        position.column < 0) {
      throw RangeError('Invalid position');
    }

    final List<String> textLines = text.split('\n');
    final newlineCount = textLines.length - 1;
    final List<String> newLines = _lines.isEmpty ? [''] : List.of(_lines);

    if (_lines.isEmpty) {
      return LineBuffer(lines: textLines);
    }

    if (newlineCount == 0) {
      // Single-line insert
      newLines[position.line] =
          newLines[position.line].substring(0, position.column) +
          text +
          newLines[position.line].substring(position.column);
    } else {
      // Multi-line insert
      final rightPart = newLines[position.line].substring(position.column);

      // First line
      newLines[position.line] =
          newLines[position.line].substring(0, position.column) +
          textLines.first;

      // Middle and last lines
      newLines.insertAll(position.line + 1, textLines.skip(1));

      // Add the right part to the last inserted line
      newLines[position.line + newlineCount] += rightPart;
    }

    return LineBuffer(lines: newLines);
  }

  @override
  int get lineCount => _lines.length;

  @override
  int get longestLineLength =>
      _lines.fold(0, (sum, line) => max(sum, line.length));

  @override
  String toString() {
    return _lines.join('\n');
  }

  @override
  List<String> get lines => _lines;
}
