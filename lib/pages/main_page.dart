import 'package:flutter/cupertino.dart';
import 'package:meteor/features/editor/widgets/editor_widget.dart';
import 'package:meteor/features/file_explorer/widgets/file_explorer_widget.dart';
import 'package:meteor/features/gutter/widgets/gutter_widget.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FileExplorerWidget(),
        GutterWidget(),
        Expanded(child: EditorWidget()),
      ],
    );
  }
}
