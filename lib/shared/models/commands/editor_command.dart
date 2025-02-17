import 'package:meteor/features/editor/models/state.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/shared/interfaces/command.dart';

class EditorCommand extends Command {
  EditorCommand(this.editor, this.beforeState);

  final Editor editor;
  final EditorState beforeState;
  EditorState? afterState;

  @override
  void execute() {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    afterState = editor.state;
  }

  @override
  void undo() {
    editor.setState(beforeState);
  }
}
