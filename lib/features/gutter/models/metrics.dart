import 'package:freezed_annotation/freezed_annotation.dart';

part 'metrics.freezed.dart';

@freezed
class GutterMetrics with _$GutterMetrics {
  const factory GutterMetrics({
    @Default(0) double width,
    @Default(0) double height,
    @Default(0) double widthPadding,
    @Default(0) double heightPadding,
    @Default(0) double charWidth,
    @Default(0) double lineHeight,
  }) = _EditorMetrics;
}
