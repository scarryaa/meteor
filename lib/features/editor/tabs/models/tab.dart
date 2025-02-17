import 'package:freezed_annotation/freezed_annotation.dart';

part 'tab.freezed.dart';

@freezed
class Tab with _$Tab {
  const factory Tab({
    required String name,
    required String path,
    @Default(false) bool isDirty,
    @Default(true) bool isActive,
  }) = _Tab;
}
