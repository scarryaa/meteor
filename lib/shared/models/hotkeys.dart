import 'dart:io';

enum Hotkey {
  modifier('⌘', '⌃', 'Command', 'Ctrl'),
  shift('⇧', '⇧', 'Shift', 'Shift'),
  alt('⌥', 'Alt', 'Option', 'Alt'),
  ctrl('⌃', '⌃', 'Control', 'Control');

  final String macSymbol;
  final String windowsSymbol;
  final String macPlainText;
  final String windowsPlainText;

  const Hotkey(
    this.macSymbol,
    this.windowsSymbol,
    this.macPlainText,
    this.windowsPlainText,
  );

  String get symbol {
    return Platform.isMacOS ? macSymbol : windowsSymbol;
  }

  String get plainText {
    return Platform.isMacOS ? macPlainText : windowsPlainText;
  }

  @override
  String toString() => symbol;
}
