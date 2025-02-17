import 'package:file_picker/file_picker.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/editor/tabs/providers/tab_manager.dart';
import 'package:meteor/shared/providers/file_manager.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'save_manager.g.dart';

@riverpod
class SaveManager extends _$SaveManager {
  @override
  void build() {
    return;
  }

  Future<void> save(String path, String content) async {
    final fileManager = ref.read(fileManagerProvider.notifier);

    fileManager.writeFileAsString(path, content);
    ref.read(tabManagerProvider.notifier).setTabDirty(path, isDirty: false);
    ref.read(editorProvider(path).notifier).setOriginalContent(content);
  }

  Future<void> saveAs(String path, String content) async {
    final newFilePath = await FilePicker.platform.saveFile();

    if (newFilePath != null) {
      ref.read(tabManagerProvider.notifier).updateTabPath(path, newFilePath);
      ref
          .read(tabManagerProvider.notifier)
          .updateTabName(path, basename(newFilePath));

      save(newFilePath, content);
    }
  }
}
