import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meteor/features/editor/interfaces/buffer.dart';
import 'package:meteor/shared/models/cursor.dart';

part 'state.freezed.dart';

@freezed
class EditorState with _$EditorState {
  const factory EditorState({
    required IBuffer buffer,
    @Default(Cursor()) Cursor cursor,
  }) = _EditorState;
}
