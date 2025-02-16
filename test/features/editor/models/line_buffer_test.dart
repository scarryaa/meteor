import 'package:flutter_test/flutter_test.dart';
import 'package:meteor/features/editor/models/line_buffer.dart';
import 'package:meteor/shared/models/position.dart';

void main() {
  late LineBuffer buffer;

  group('LineBuffer', () {
    setUp(() {
      buffer = LineBuffer(lines: ['hello', 'beautiful', 'moon']);
    });

    group('getLine', () {
      test('should throw if Position out of range', () {
        expect(() => buffer.getLine(-1), throwsRangeError);
        expect(() => buffer.getLine(100), throwsRangeError);
      });

      test('should correctly return line', () {
        expect(buffer.getLine(0), 'hello');
      });
    });

    group('getLineLength', () {
      test('should throw if Position out of range', () {
        expect(() => buffer.getLineLength(-1), throwsRangeError);
        expect(() => buffer.getLineLength(100), throwsRangeError);
      });

      test('should correctly return line length', () {
        expect(buffer.getLineLength(0), 5);
      });
    });

    group('lineCount', () {
      test('should return correct line count', () {
        expect(buffer.lineCount, 3);
      });
    });

    group('longestLineLength', () {
      test('should return correct longest line length', () {
        expect(buffer.longestLineLength, 9);
      });
    });

    group('insert', () {
      test('should throw on invalid position', () {
        expect(
          () => buffer.insert(Position(line: -1, column: 0), ''),
          throwsRangeError,
        );

        expect(
          () => buffer.insert(Position(line: 0, column: -1), ''),
          throwsRangeError,
        );

        expect(
          () => buffer.insert(Position(line: 100, column: 0), ''),
          throwsRangeError,
        );
      });

      group('should insert correctly', () {
        group('multi-line', () {
          test('in an empty buffer', () {
            buffer = LineBuffer();

            final newBuffer = buffer.insert(Position.zero, 'hello\nworld');

            expect(newBuffer.toString(), 'hello\nworld');
          });
        });

        group('single-line', () {
          test('in an empty buffer', () {
            buffer = LineBuffer();

            final newBuffer = buffer.insert(Position.zero, 'hello world');

            expect(newBuffer.toString(), 'hello world');
          });
        });

        group('in a non-empty buffer', () {
          group('single-line', () {
            test('at the start', () {
              final newBuffer = buffer.insert(Position.zero, 'hello there ');

              expect(
                newBuffer.toString(),
                'hello there hello\nbeautiful\nmoon',
              );
            });

            test('in the middle', () {
              final newBuffer = buffer.insert(
                Position(line: 0, column: 5),
                ' there',
              );

              expect(newBuffer.toString(), 'hello there\nbeautiful\nmoon');
            });

            test('at the end', () {
              final newBuffer = buffer.insert(
                Position(line: 2, column: 4),
                ' how are you?',
              );

              expect(
                newBuffer.toString(),
                'hello\nbeautiful\nmoon how are you?',
              );
            });
          });

          group('multi-line', () {
            test('at the start', () {
              final newBuffer = buffer.insert(Position.zero, 'hello\nthere\n');

              expect(
                newBuffer.toString(),
                'hello\nthere\nhello\nbeautiful\nmoon',
              );
            });

            test('in the middle', () {
              final newBuffer = buffer.insert(
                Position(line: 1, column: 0),
                'there\nmy ',
              );

              expect(newBuffer.toString(), 'hello\nthere\nmy beautiful\nmoon');
            });

            test('at the end', () {
              final newBuffer = buffer.insert(
                Position(line: 2, column: 4),
                'how\nare\nyou?',
              );

              expect(
                newBuffer.toString(),
                'hello\nbeautiful\nmoonhow\nare\nyou?',
              );
            });
          });
        });
      });
    });

    group('delete', () {
      group('should delete correctly', () {
        group('empty buffer', () {
          setUp(() {
            buffer = LineBuffer();
          });

          test('should do nothing', () {
            final result = buffer.delete(Position.zero, Position.zero);
            expect(result.newBuffer.toString(), '');
          });
        });

        group('non-empty buffer', () {
          group('single-line', () {
            test('backspace', () {
              final result = buffer.delete(
                Position(line: 1, column: -1),
                Position(line: 0, column: 0),
              );

              expect(result.newBuffer.toString(), 'hellobeautiful\nmoon');
              expect(result.mergePosition, Position(line: 0, column: 5));
            });

            test('at the beginning', () {
              final result = buffer.delete(
                Position.zero,
                Position(line: 0, column: 5),
              );

              expect(result.newBuffer.toString(), '\nbeautiful\nmoon');
            });

            test('in the middle', () {
              final result = buffer.delete(
                Position(line: 1, column: 0),
                Position(line: 1, column: 9),
              );

              expect(result.newBuffer.toString(), 'hello\n\nmoon');
            });
          });

          group('multi-line', () {
            test('at the beginning', () {
              final result = buffer.delete(
                Position.zero,
                Position(line: 1, column: 9),
              );

              expect(result.newBuffer.toString(), '\nmoon');
            });

            test('in the middle', () {
              final result = buffer.delete(
                Position(line: 1, column: 0),
                Position(line: 2, column: 4),
              );

              expect(result.newBuffer.toString(), 'hello\n');
            });
          });
        });
      });
    });
  });
}
