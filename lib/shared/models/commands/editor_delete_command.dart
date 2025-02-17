import 'package:meteor/features/editor/models/selection.dart';
import 'package:meteor/features/editor/models/state.dart';
import 'package:meteor/shared/models/commands/editor_command.dart';
import 'package:meteor/shared/models/position.dart';

class EditorDeleteCommand extends EditorCommand {
  EditorDeleteCommand(super.editor, super.beforeState, this.start, this.end);

  final Position start;
  final Position end;

  @override
  // ignore: overridden_fields
  EditorState? afterState;

  @override
  void execute() {
    if (afterState != null) {
      editor.setState(afterState!);
      return;
    }

    if (beforeState.selection != Selection.empty) {
      editor.deleteSelectedText();
    } else {
      editor.delete(start, end);
    }

    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    afterState = editor.state;
  }

  @override
  void undo() {
    editor.setState(beforeState);
  }
}
