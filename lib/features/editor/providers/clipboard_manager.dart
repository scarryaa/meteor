import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clipboard_manager.g.dart';

@riverpod
class ClipboardManager extends _$ClipboardManager {
  @override
  Future<String> build() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    return clipboardData?.text ?? '';
  }

  Future<void> setText(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));

      state = AsyncValue.data(text);
    } on PlatformException catch (e) {
      state = AsyncValue.error(
        'Failed to set clipboard: ${e.message}',
        StackTrace.current,
      );
    }
  }

  Future<void> clear() async {
    await setText('');
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      state = AsyncValue.data(clipboardData?.text ?? '');
    } on PlatformException catch (e) {
      state = AsyncValue.error(
        'Failed to read clipboard: ${e.message}',
        StackTrace.current,
      );
    }
  }
}
