import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/editor/models/state.dart';
import 'package:meteor/features/editor/providers/editor.dart';
import 'package:meteor/features/gutter/models/metrics.dart';
import 'package:meteor/features/gutter/providers/measurer.dart';
import 'package:meteor/features/gutter/widgets/gutter_painter.dart';
import 'package:meteor/shared/models/position.dart';
import 'package:meteor/shared/providers/scroll_controller_by_key.dart';

class GutterWidget extends ConsumerStatefulWidget {
  const GutterWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => GutterWidgetState();
}

class GutterWidgetState extends ConsumerState<GutterWidget> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addScrollListeners();
    });
  }

  void _addScrollListeners() {
    final gutterScrollController = ref.read(
      scrollControllerByKeyProvider('gutterVScrollController'),
    );
    final editorScrollController = ref.read(
      scrollControllerByKeyProvider('editorVScrollController'),
    );

    gutterScrollController.addListener(_syncEditorScroll);
    editorScrollController.addListener(_syncGutterScroll);
  }

  void _syncEditorScroll() {
    final gutterScrollController = ref.read(
      scrollControllerByKeyProvider('gutterVScrollController'),
    );
    final editorScrollController = ref.read(
      scrollControllerByKeyProvider('editorVScrollController'),
    );

    if (gutterScrollController.offset != editorScrollController.offset) {
      editorScrollController.jumpTo(gutterScrollController.offset);
    }
  }

  void _syncGutterScroll() {
    final gutterScrollController = ref.read(
      scrollControllerByKeyProvider('gutterVScrollController'),
    );
    final editorScrollController = ref.read(
      scrollControllerByKeyProvider('editorVScrollController'),
    );

    if (gutterScrollController.offset != editorScrollController.offset) {
      gutterScrollController.jumpTo(editorScrollController.offset);
    }
  }

  Position _positionFromOffset(
    Offset offset,
    GutterMetrics metrics,
    EditorState state,
  ) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset adjustedOffset = renderBox.globalToLocal(offset);

    adjustedOffset = Offset(adjustedOffset.dx, adjustedOffset.dy);

    final targetLine = (adjustedOffset.dy / metrics.lineHeight).floor();
    final targetColumn = (adjustedOffset.dx / metrics.charWidth).floor();

    final clampedLine = targetLine.clamp(0, state.buffer.lineCount - 1);
    final clampedColumn = targetColumn.clamp(
      0,
      state.buffer.getLineLength(clampedLine),
    );

    return Position(line: clampedLine, column: clampedColumn);
  }

  void _handleTapDown(
    TapDownDetails details,
    EditorState state,
    Editor editor,
    GutterMetrics metrics,
  ) {
    Position position = _positionFromOffset(
      details.globalPosition,
      metrics,
      state,
    );
    editor.selectLine(position.line);
  }

  void _handlePanStart(
    DragStartDetails details,
    EditorState state,
    Editor editor,
    GutterMetrics metrics,
  ) {
    Position position = _positionFromOffset(
      details.globalPosition,
      metrics,
      state,
    );
    editor.selectLine(position.line);
  }

  void _handlePanUpdate(
    DragUpdateDetails details,
    EditorState state,
    Editor editor,
    GutterMetrics metrics,
  ) {
    Position position = _positionFromOffset(
      details.globalPosition,
      metrics,
      state,
    );
    editor.selectLine(position.line, extendSelection: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final editor = ref.read(editorProvider.notifier);
    final measurer = ref.read(gutterMeasurerProvider.notifier);
    final metrics = ref.watch(gutterMeasurerProvider);
    final vScrollController = ref.watch(
      scrollControllerByKeyProvider('gutterVScrollController'),
    );

    return LayoutBuilder(
      builder:
          (context, constraints) => ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(
              scrollbars: false,
              physics: ClampingScrollPhysics(),
              overscroll: false,
            ),
            child: SingleChildScrollView(
              controller: vScrollController,
              child: ListenableBuilder(
                listenable: vScrollController,
                builder: (context, child) {
                  final viewportHeight = constraints.maxHeight;
                  final double vOffset =
                      vScrollController.hasClients
                          ? vScrollController.offset
                          : 0;

                  final visibleLines = measurer.getVisibleLines(
                    state.buffer,
                    viewportHeight,
                    vOffset,
                  );

                  return GestureDetector(
                    onTapDown:
                        (details) =>
                            _handleTapDown(details, state, editor, metrics),
                    onPanStart:
                        (details) =>
                            _handlePanStart(details, state, editor, metrics),
                    onPanUpdate:
                        (details) =>
                            _handlePanUpdate(details, state, editor, metrics),
                    child: CustomPaint(
                      willChange: true,
                      isComplex: true,
                      size: measurer.getSize(
                        constraints,
                        state.buffer.lineCount - 1,
                      ),
                      painter: GutterPainter(
                        cursor: state.cursor,
                        selection: state.selection,
                        metrics: metrics,
                        visibleLines: visibleLines,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
    );
  }
}
