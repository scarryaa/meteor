import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/providers/cursor_manager.dart';
import 'package:meteor/shared/models/cursor.dart';
import 'package:meteor/shared/models/position.dart';

void main() {
  late EditorCursorManager cursorManager;

  group('EditorCursorManager', () {
    setUp(() {
      cursorManager = ProviderContainer().read(
        editorCursorManagerProvider.notifier,
      );
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
  });
}
