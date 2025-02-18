import 'dart:ffi' hide Size;
import 'dart:math';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:meteor/bindings/tree-sitter/tree_sitter_bindings.dart';
import 'package:meteor/features/editor/models/syntax_node.dart';
import 'package:meteor/features/editor/providers/tree_sitter_manager.dart';

class SyntaxHighlighter {
  final TreeSitterManager treeSitterManager;
  final Pointer<TSTree>? tree;

  SyntaxHighlighter({required this.treeSitterManager, required this.tree});

  TextStyle _getStyleForNode(String type) {
    switch (type) {
      // Keywords and declarations
      case 'class_definition':
      case 'const_builtin':
      case 'keyword':
        return const TextStyle(color: Color(0xFF81A1C1));

      // Control flow
      case 'return_statement':
      case 'if_statement':
      case 'for_statement':
      case 'while_statement':
      case 'switch_statement':
        return const TextStyle(color: Color(0xFFB48EAD));

      // Exception handling
      case 'try_statement':
      case 'catch_clause':
      case 'finally_clause':
        return const TextStyle(color: Color(0xFFD08770));

      // Types and classes
      case 'type_identifier':
      case 'built_in_type':
        return const TextStyle(color: Color(0xFF8FBCBB));

      // Functions and methods
      case 'function_signature':
      case 'method_declaration':
        return const TextStyle(color: Color(0xFF88C0D0));

      // Constructors
      case 'constructor_declaration':
        return const TextStyle(color: Color(0xFF5E81AC));

      // Variables and identifiers
      case 'identifier':
        return const TextStyle(color: Color(0xFFE5E9F0));

      // Special identifiers
      case 'label':
        return const TextStyle(color: Color(0xFFECEFF4));

      // Strings
      case 'string_literal':
      case 'string':
      case 'string_content':
        return const TextStyle(color: Color(0xFFA3BE8C));

      // Numbers
      case 'decimal_integer_literal':
      case 'decimal_floating_point_literal':
        return const TextStyle(color: Color(0xFFBF616A));

      // Special numbers
      case 'hex_integer_literal':
      case 'integer_literal':
        return const TextStyle(color: Color(0xFFD08770));

      // Comments
      case 'comment':
      case 'line_comment':
        return const TextStyle(color: Color(0xFF7B88A1));

      case 'block_comment':
      case 'documentation_comment':
        return const TextStyle(color: Color(0xFF677691));

      // Operators
      case 'operator':
        return const TextStyle(color: Color(0xFFEBCB8B));

      // Selectors and arguments
      case 'selector':
      case 'unconditional_assignable_selector':
        return const TextStyle(color: Color(0xFF96B4EB));

      case 'argument_part':
      case 'arguments':
        return const TextStyle(color: Color(0xFFB9A9D9));

      // Named arguments
      case 'named_argument':
        return const TextStyle(color: Color(0xFF93C7C0));

      default:
        return const TextStyle(color: Color(0xFFD8DEE9));
    }
  }

  List<TextSpan> highlightText(
    String visibleText,
    String fullText,
    int visibleStart,
  ) {
    if (visibleText.isEmpty) {
      return [const TextSpan(text: '')];
    }

    final List<SyntaxNode> flatNodes = _getFlatNodes(
      visibleText,
      fullText,
      visibleStart,
    );

    // Sort nodes by start position
    flatNodes.sort((a, b) => a.start.compareTo(b.start));

    final List<TextSpan> spans = [];
    int currentPos = 0;

    for (final node in flatNodes) {
      if (node.start > currentPos) {
        spans.add(
          TextSpan(
            text: visibleText.substring(currentPos, node.start),
            style: const TextStyle(color: Color(0xFFFCFCFC)),
          ),
        );
      }

      spans.add(TextSpan(text: node.text, style: _getStyleForNode(node.type)));

      currentPos = node.end;
    }

    if (currentPos < visibleText.length) {
      spans.add(
        TextSpan(
          text: visibleText.substring(currentPos),
          style: const TextStyle(color: Color(0xFFFCFCFC)),
        ),
      );
    }

    return spans;
  }

  List<SyntaxNode> _getFlatNodes(
    String visibleText,
    String fullText,
    int visibleStart,
  ) {
    if (tree == null) return [];

    final List<SyntaxNode> flatNodes = [];
    final TSNode rootNode = treeSitterManager.treeSitter.ts_tree_root_node(
      tree!,
    );
    final int visibleEnd = visibleStart + visibleText.length;

    void flattenNodes(TSNode node, int depth) {
      if (!treeSitterManager.treeSitter.ts_node_is_named(node)) return;

      final int nodeStart = treeSitterManager.treeSitter.ts_node_start_byte(
        node,
      );
      final int nodeEnd = treeSitterManager.treeSitter.ts_node_end_byte(node);

      if (nodeEnd < visibleStart || nodeStart > visibleEnd) return;

      final String type =
          treeSitterManager.treeSitter
              .ts_node_type(node)
              .cast<Utf8>()
              .toDartString();

      final int intersectStart = max(nodeStart, visibleStart);
      final int intersectEnd = min(nodeEnd, visibleEnd);

      if (intersectStart < intersectEnd) {
        final int relativeStart = intersectStart - visibleStart;
        final int relativeEnd = intersectEnd - visibleStart;

        if (relativeStart >= 0 &&
            relativeEnd <= visibleText.length &&
            relativeStart < relativeEnd) {
          flatNodes.add(
            SyntaxNode(
              start: relativeStart,
              end: relativeEnd,
              type: type,
              text: visibleText.substring(relativeStart, relativeEnd),
              depth: depth,
            ),
          );
        }
      }

      final int childCount = treeSitterManager.treeSitter.ts_node_child_count(
        node,
      );
      for (int i = 0; i < childCount; i++) {
        flattenNodes(
          treeSitterManager.treeSitter.ts_node_child(node, i),
          depth + 1,
        );
      }
    }

    flattenNodes(rootNode, 0);

    // Sort by depth (descending) and start position
    flatNodes.sort((a, b) {
      final int depthCompare = b.depth.compareTo(a.depth);
      return depthCompare != 0 ? depthCompare : a.start.compareTo(b.start);
    });

    // Remove overlapping nodes
    final List<SyntaxNode> nonOverlappingNodes = [];
    for (final node in flatNodes) {
      if (nonOverlappingNodes.isEmpty ||
          node.start >= nonOverlappingNodes.last.end) {
        nonOverlappingNodes.add(node);
      }
    }

    return nonOverlappingNodes;
  }
}
