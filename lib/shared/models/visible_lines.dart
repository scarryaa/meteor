import 'package:freezed_annotation/freezed_annotation.dart';

part 'visible_lines.freezed.dart';

@freezed
class VisibleLines with _$VisibleLines {
  const factory VisibleLines({
    required int firstVisibleLine,
    required int lastVisibleLine,
    required int? firstVisibleChar,
    required int? lastVisibleChar,
  }) = _VisibleLines;
}
