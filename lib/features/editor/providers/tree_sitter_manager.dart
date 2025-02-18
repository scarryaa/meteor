import 'dart:io';

import 'package:meteor/bindings/tree-sitter/tree_sitter_bindings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

part 'tree_sitter_manager.g.dart';

@riverpod
class TreeSitterManager extends _$TreeSitterManager {
  late final ffi.DynamicLibrary _dylib;
  late final TreeSitter _treeSitter;
  late final ffi.Pointer<TSParser> _parser;

  @override
  void build() {
    _dylib = _loadLibrary();
    _treeSitter = TreeSitter(_dylib);
    _parser = _treeSitter.ts_parser_new();

    ref.onDispose(() {
      _treeSitter.ts_parser_delete(_parser);
    });
  }

  ffi.Pointer<TSLanguage> getLanguage(String languageName) {
    final Directory current = Directory.current;
    final String rootDir = current.path;
    final String bindingsPath =
        Platform.isWindows ? '$rootDir\\native' : '$rootDir/native';

    ffi.DynamicLibrary langLib;
    if (Platform.isMacOS) {
      langLib = ffi.DynamicLibrary.open(
        '$bindingsPath/libtree-sitter-$languageName.dylib',
      );
    } else if (Platform.isWindows) {
      langLib = ffi.DynamicLibrary.open(
        '$bindingsPath\\tree-sitter-$languageName.dll',
      );
    } else if (Platform.isLinux) {
      langLib = ffi.DynamicLibrary.open(
        '$bindingsPath/libtree-sitter-$languageName.so',
      );
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    final languageFunction = langLib.lookupFunction<
      ffi.Pointer<TSLanguage> Function(),
      ffi.Pointer<TSLanguage> Function()
    >('tree_sitter_$languageName');

    return languageFunction();
  }

  ffi.DynamicLibrary _loadLibrary() {
    final Directory current = Directory.current;
    final String rootDir = current.path;

    final String bindingsPath =
        Platform.isWindows ? '$rootDir\\native' : '$rootDir/native';

    if (Platform.isMacOS) {
      return ffi.DynamicLibrary.open('$bindingsPath/libtree-sitter.dylib');
    } else if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('$bindingsPath\\tree-sitter.dll');
    } else if (Platform.isLinux) {
      return ffi.DynamicLibrary.open('$bindingsPath/libtree-sitter.so');
    }

    throw UnsupportedError('Unsupported platform');
  }

  void setLanguage(ffi.Pointer<TSLanguage> language) {
    if (!_treeSitter.ts_parser_set_language(_parser, language)) {
      throw StateError('Failed to set parser language');
    }
  }

  ffi.Pointer<TSTree> parseString(String text) {
    final textPointer = text.toNativeUtf8();
    try {
      return _treeSitter.ts_parser_parse_string(
        _parser,
        ffi.nullptr,
        textPointer.cast(),
        text.length,
      );
    } finally {
      malloc.free(textPointer);
    }
  }

  ffi.Pointer<TSParser> get parser => _parser;

  TreeSitter get treeSitter => _treeSitter;
}
