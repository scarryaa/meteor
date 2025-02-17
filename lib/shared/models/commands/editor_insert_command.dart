import 'package:meteor/features/editor/models/state.dart';
import 'package:meteor/shared/models/commands/editor_command.dart';
import 'package:meteor/shared/models/position.dart';

class EditorInsertCommand extends EditorCommand {
  EditorInsertCommand(
    super.editor,
    super.beforeState,
    this.position,
    this.text,
  );

  final Position position;
  final String text;

  @override
  // ignore: overridden_fields
  EditorState? afterState;

  @override
  void execute() {
    if (afterState != null) {
      editor.setState(afterState!);
      return;
    }

    editor.insert(position, text);
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    afterState = editor.state;
  }

  @override
  void undo() {
    editor.setState(beforeState);
  }
}
