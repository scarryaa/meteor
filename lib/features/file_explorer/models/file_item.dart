import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_item.freezed.dart';

@freezed
class FileItem with _$FileItem {
  const factory FileItem({
    @Default(false) bool isSelected,
    @Default(false) bool isExpanded,
    required bool isDirectory,
    required String path,
  }) = _FileItem;
}
