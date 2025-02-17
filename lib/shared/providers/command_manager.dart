import 'package:meteor/shared/models/commands/editor_command.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'command_manager.g.dart';

@Riverpod(keepAlive: true)
class CommandManager extends _$CommandManager {
  final List<EditorCommand> _commandHistory = [];
  final List<EditorCommand> _redoStack = [];

  @override
  void build(String path) {
    return;
  }

  void execute(EditorCommand command) {
    command.execute();
    _commandHistory.add(command);
    _redoStack.clear();
  }

  void undo() {
    if (_commandHistory.isNotEmpty) {
      final command = _commandHistory.removeLast();
      command.undo();
      _redoStack.add(command);
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      final command = _redoStack.removeLast();
      command.execute();
      _commandHistory.add(command);
    }
  }

  bool get canUndo => _commandHistory.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
}
