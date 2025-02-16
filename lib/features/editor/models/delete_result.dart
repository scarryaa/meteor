import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meteor/features/editor/interfaces/buffer.dart';
import 'package:meteor/shared/models/position.dart';

part 'delete_result.freezed.dart';

@freezed
class DeleteResult with _$DeleteResult {
  const factory DeleteResult({
    required IBuffer newBuffer,
    required Position mergePosition,
  }) = _DeleteResult;
}
