import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meteor/features/editor/interfaces/buffer.dart';
import 'package:meteor/features/editor/models/selection.dart';
import 'package:meteor/shared/models/position.dart';

part 'selection_delete_result.freezed.dart';

@freezed
class SelectionDeleteResult with _$SelectionDeleteResult {
  const factory SelectionDeleteResult({
    required Selection newSelection,
    required IBuffer newBuffer,
    required Position mergePosition,
  }) = _SelectionDeleteResult;
}
