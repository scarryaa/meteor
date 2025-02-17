import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meteor/features/file_explorer/models/file_item.dart';

part 'state.freezed.dart';

@freezed
class FileExplorerState with _$FileExplorerState {
  const factory FileExplorerState({
    String? currentDirectoryPath,
    @Default([]) List<FileItem> items,
    @Default({}) Set<String> expandedPaths,
  }) = _FileExplorerState;
}
