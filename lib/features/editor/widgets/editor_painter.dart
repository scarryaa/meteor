import 'package:flutter/material.dart';

class EditorPainter extends CustomPainter {
  EditorPainter({required List<String> lines})
    : _textPainter = TextPainter(textDirection: TextDirection.ltr),
      _lines = lines;

  final TextPainter _textPainter;
  final List<String> _lines;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _lines.length; i++) {
      _textPainter
        ..text = TextSpan(
          text: _lines[i],
          style: TextStyle(
            fontSize: 15.0,
            fontFamily: 'MesloLGL Nerd Font Mono',
            color: const Color(0xFFFCFCFC),
          ),
        )
        ..layout()
        ..paint(canvas, Offset(0, i * _textPainter.height));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
