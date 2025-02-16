import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/models/line_buffer.dart';
import 'package:meteor/features/editor/providers/cursor_manager.dart';
import 'package:meteor/shared/models/cursor.dart';
import 'package:meteor/shared/models/position.dart';

void main() {
  late EditorCursorManager cursorManager;
  late LineBuffer buffer;

  group('EditorCursorManager', () {
    setUp(() {
      cursorManager = ProviderContainer().read(
        editorCursorManagerProvider.notifier,
      );

      buffer = LineBuffer(lines: ['hello', 'beautiful', 'moon']);
    });

    group('adjustAfterInsert', () {
      group('single-line insert', () {
        test('should adjust cursor correctly', () {
          final newCursor = cursorManager.adjustAfterInsert(Cursor(), [
            'hello',
          ], 0);

          expect(newCursor, Cursor(line: 0, column: 5));
        });
      });

      group('multi-line insert', () {
        test('should adjust cursor correctly', () {
          final newCursor = cursorManager.adjustAfterInsert(Cursor(), [
            'hello',
            'world',
          ], 1);

          expect(newCursor, Cursor(line: 1, column: 5));
        });
      });
    });

    group('adjustAfterDelete', () {
      group('single-line delete', () {
        test('should adjust cursor correctly', () {
          final newCursor = cursorManager.adjustAfterDelete(
            Position(line: 0, column: 2),
            Position(line: 0, column: 5),
            Position.zero,
          );

          expect(newCursor, Cursor(column: 2));
        });
      });

      group('multi-line delete', () {
        test('should adjust cursor correctly', () {
          final newCursor = cursorManager.adjustAfterDelete(
            Position(line: 0, column: 2),
            Position(line: 1, column: 5),
            Position.zero,
          );

          expect(newCursor, Cursor(column: 2));
        });
      });

      group('backspace', () {
        test('should adjust cursor correctly', () {
          final newCursor = cursorManager.adjustAfterDelete(
            Position(line: 0, column: 2),
            Position(line: 0, column: 5),
            Position(line: 1, column: 5),
          );

          expect(newCursor, Cursor(line: 1, column: 5));
        });
      });
    });

    group('moveLeft', () {
      test('should move left within line', () {
        final newCursor = cursorManager.moveLeft(
          buffer,
          Cursor(line: 1, column: 2),
        );

        expect(newCursor, Cursor(line: 1, column: 1, targetColumn: 1));
      });

      test('should do nothing at doc start', () {
        final newCursor = cursorManager.moveLeft(buffer, Cursor());

        expect(newCursor, Cursor());
      });

      test('should move to previous line at line start', () {
        final newCursor = cursorManager.moveLeft(
          buffer,
          Cursor(line: 1, column: 0),
        );

        expect(newCursor, Cursor(line: 0, column: 5, targetColumn: 5));
      });
    });

    group('moveRight', () {
      test('should move right within line', () {
        final newCursor = cursorManager.moveRight(
          buffer,
          Cursor(line: 1, column: 2),
        );

        expect(newCursor, Cursor(line: 1, column: 3, targetColumn: 3));
      });

      test('should do nothing at doc end', () {
        final newCursor = cursorManager.moveRight(
          buffer,
          Cursor(line: 2, column: 4, targetColumn: 4),
        );

        expect(newCursor, Cursor(line: 2, column: 4, targetColumn: 4));
      });

      test('should move to next line at line end', () {
        final newCursor = cursorManager.moveRight(
          buffer,
          Cursor(line: 0, column: 5),
        );

        expect(newCursor, Cursor(line: 1, column: 0, targetColumn: 0));
      });
    });

    group('moveUp', () {
      test('should move up a line', () {
        final newCursor = cursorManager.moveUp(
          buffer,
          Cursor(line: 1, column: 5, targetColumn: 5),
        );

        expect(newCursor, Cursor(line: 0, column: 5, targetColumn: 5));
      });

      test('should move to doc start at first line', () {
        final newCursor = cursorManager.moveUp(
          buffer,
          Cursor(line: 0, column: 5, targetColumn: 5),
        );

        expect(newCursor, Cursor(line: 0, column: 0, targetColumn: 0));
      });

      test('should maintain targetColumn when moving between lines', () {
        final cursor1 = cursorManager.moveUp(
          buffer,
          Cursor(line: 1, column: 9, targetColumn: 9),
        );
        final cursor2 = cursorManager.moveDown(buffer, cursor1);

        expect(cursor2, Cursor(line: 1, column: 9, targetColumn: 9));
      });
    });

    group('moveDown', () {
      test('should move down a line', () {
        final newCursor = cursorManager.moveDown(
          buffer,
          Cursor(line: 1, column: 5, targetColumn: 5),
        );

        expect(newCursor, Cursor(line: 2, column: 4, targetColumn: 5));
      });

      test('should move to doc end at last line', () {
        final newCursor = cursorManager.moveDown(
          buffer,
          Cursor(line: 2, column: 0),
        );

        expect(newCursor, Cursor(line: 2, column: 4, targetColumn: 4));
      });

      test('should maintain targetColumn when moving between lines', () {
        final cursor1 = cursorManager.moveDown(
          buffer,
          Cursor(line: 1, column: 9, targetColumn: 9),
        );
        final cursor2 = cursorManager.moveUp(buffer, cursor1);

        expect(cursor2, Cursor(line: 1, column: 9, targetColumn: 9));
      });
    });
  });
}
