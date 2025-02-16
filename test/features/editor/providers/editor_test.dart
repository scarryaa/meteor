import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/models/line_buffer.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/shared/models/cursor.dart';
import 'package:meteor/shared/models/position.dart';

void main() {
  late Editor editor;

  group('EditorProvider', () {
    setUp(() {
      editor = ProviderContainer().read(editorProvider.notifier);
      editor.state = editor.state.copyWith(
        buffer: LineBuffer(lines: ['hello', 'beautiful', 'moon']),
      );
    });

    group('insert', () {
      group('into an empty buffer', () {
        setUp(() {
          editor.state = editor.state.copyWith(buffer: LineBuffer());
        });

        group('single-line', () {
          test('should insert correctly', () {
            editor.insert(Position.zero, 'hello');

            expect(editor.state.buffer.toString(), 'hello');
            expect(editor.state.cursor, Cursor(line: 0, column: 5));
          });
        });

        group('multi-line', () {
          test('should insert correctly', () {
            editor.insert(Position.zero, 'hello\nbeautiful\nmoon');

            expect(editor.state.buffer.toString(), 'hello\nbeautiful\nmoon');
            expect(editor.state.cursor, Cursor(line: 2, column: 4));
          });
        });
      });

      group('into a non-empty buffer', () {
        group('single-line', () {
          group('should insert correctly', () {
            test('at the beginning', () {
              editor.insert(Position.zero, 'hello');

              expect(
                editor.state.buffer.toString(),
                'hellohello\nbeautiful\nmoon',
              );
              expect(editor.state.cursor, Cursor(line: 0, column: 5));
            });

            test('in the middle', () {
              editor.state = editor.state.copyWith(
                cursor: Cursor(line: 0, column: 5),
              );

              editor.insert(Position(line: 0, column: 5), 'hello');
              expect(
                editor.state.buffer.toString(),
                'hellohello\nbeautiful\nmoon',
              );
              expect(editor.state.cursor, Cursor(line: 0, column: 10));
            });

            test('at the end', () {
              editor.state = editor.state.copyWith(
                cursor: Cursor(line: 2, column: 4),
              );

              editor.insert(Position(line: 2, column: 4), 'hello');
              expect(
                editor.state.buffer.toString(),
                'hello\nbeautiful\nmoonhello',
              );
              expect(editor.state.cursor, Cursor(line: 2, column: 9));
            });
          });
        });

        group('mutli-line', () {
          group('should insert correctly', () {
            test('at the beginning', () {
              editor.insert(Position.zero, 'hello\nworld\n');

              expect(
                editor.state.buffer.toString(),
                'hello\nworld\nhello\nbeautiful\nmoon',
              );
              expect(editor.state.cursor, Cursor(line: 2, column: 0));
            });

            test('in the middle', () {
              editor.state = editor.state.copyWith(
                cursor: Cursor(line: 0, column: 5),
              );

              editor.insert(Position(line: 0, column: 5), 'hello\nthere\nmy');
              expect(
                editor.state.buffer.toString(),
                'hellohello\nthere\nmy\nbeautiful\nmoon',
              );
              expect(editor.state.cursor, Cursor(line: 2, column: 2));
            });

            test('at the end', () {
              editor.state = editor.state.copyWith(
                cursor: Cursor(line: 2, column: 4),
              );

              editor.insert(
                Position(line: 2, column: 4),
                'hello\nthere\neveryone',
              );
              expect(
                editor.state.buffer.toString(),
                'hello\nbeautiful\nmoonhello\nthere\neveryone',
              );
              expect(editor.state.cursor, Cursor(line: 4, column: 8));
            });
          });
        });
      });
    });

    group('delete', () {
      test('backspace', () {
        editor.delete(
          Position(line: 1, column: -1),
          Position(line: 1, column: 0),
        );

        expect(editor.state.buffer.toString(), 'hellobeautiful\nmoon');
        expect(editor.state.cursor, Cursor(line: 0, column: 5));
      });

      test('start or end out of range (throws)', () {
        // start cannot be greater than end
        expect(
          () => editor.delete(Position(line: 10, column: 5), Position.zero),
          throwsRangeError,
        );
        // start line cannot be negative
        expect(
          () => editor.delete(
            Position(line: -1, column: 0),
            Position(line: 0, column: 0),
          ),
          throwsRangeError,
        );
        // end line cannot be negative
        expect(
          () => editor.delete(
            Position(line: 0, column: 0),
            Position(line: -1, column: 0),
          ),
          throwsRangeError,
        );
        // start column cannot be greater than buffer line length
        expect(
          () => editor.delete(
            Position(line: 0, column: 100),
            Position(line: 0, column: 0),
          ),
          throwsRangeError,
        );
        // end column cannot be greater than buffer line length
        expect(
          () => editor.delete(
            Position(line: 0, column: 0),
            Position(line: 0, column: 100),
          ),
          throwsRangeError,
        );
      });

      test('same start and end does nothing', () {
        editor.delete(Position.zero, Position.zero);

        expect(editor.state.buffer.toString(), 'hello\nbeautiful\nmoon');
        expect(editor.state.cursor, Cursor());
      });

      test('in an empty buffer (throws)', () {
        editor.state = editor.state.copyWith(buffer: LineBuffer());

        expect(
          () => editor.delete(
            Position(line: 0, column: 0),
            Position(line: 1, column: 5),
          ),
          throwsRangeError,
        );
      });

      group('mutli-line buffer', () {
        group('single-line', () {
          test('at the start', () {
            editor.delete(Position.zero, Position(line: 0, column: 5));

            expect(editor.state.buffer.toString(), '\nbeautiful\nmoon');
            expect(editor.state.cursor, Cursor());
          });

          test('in the middle', () {
            editor.delete(
              Position(line: 1, column: 0),
              Position(line: 1, column: 9),
            );

            expect(editor.state.buffer.toString(), 'hello\n\nmoon');
            expect(editor.state.cursor, Cursor(line: 1, column: 0));
          });

          test('at the end (throws)', () {
            expect(
              () => editor.delete(
                Position(line: 2, column: 4),
                Position(line: 2, column: 5),
              ),
              throwsRangeError,
            );
          });
        });

        group('mutli-line', () {
          test('at the start', () {
            editor.delete(Position.zero, Position(line: 1, column: 9));

            expect(editor.state.buffer.toString(), '\nmoon');
            expect(editor.state.cursor, Cursor());
          });

          test('in the middle', () {
            editor.delete(
              Position(line: 1, column: 0),
              Position(line: 2, column: 4),
            );

            expect(editor.state.buffer.toString(), 'hello\n');
            expect(editor.state.cursor, Cursor(line: 1, column: 0));
          });

          test('at the end (throws)', () {
            expect(
              () => editor.delete(
                Position(line: 2, column: 4),
                Position(line: 3, column: 5),
              ),
              throwsRangeError,
            );
          });
        });
      });
    });
  });
}
