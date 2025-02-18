class SyntaxNode {
  final int start;
  final int end;
  final String type;
  final String text;
  final int depth;

  SyntaxNode({
    required this.start,
    required this.end,
    required this.type,
    required this.text,
    required this.depth,
  });
}
