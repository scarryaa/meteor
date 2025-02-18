import 'package:flutter/material.dart';
import 'package:meteor/shared/models/hotkeys.dart';

class DesktopTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final List<Hotkey>? hotkeys;
  final String? hotkeyLetter;
  final Duration? waitDuration;
  final EdgeInsets padding;
  final double verticalOffset;

  const DesktopTooltip({
    super.key,
    required this.child,
    required this.message,
    this.hotkeys,
    this.hotkeyLetter,
    this.waitDuration = const Duration(milliseconds: 500),
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.verticalOffset = 20,
  });

  @override
  State<DesktopTooltip> createState() => _DesktopTooltipState();
}

class _DesktopTooltipState extends State<DesktopTooltip> {
  OverlayEntry? _overlayEntry;

  String? get _hotkeyText {
    if (widget.hotkeys == null || widget.hotkeyLetter == null) return null;
    return '${widget.hotkeys!.map((h) => h.symbol).join('')}${widget.hotkeyLetter!.toUpperCase()}';
  }

  String _getPlainTextHotkey() {
    if (widget.hotkeys == null || widget.hotkeyLetter == null) return '';
    return '${widget.hotkeys!.map((h) => h.plainText).join(' + ')} + ${widget.hotkeyLetter!.toUpperCase()}';
  }

  void _showHotkeyTooltip(BuildContext context, Offset position) {
    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            left: position.dx,
            top: position.dy + 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0x40FFFFFF),
                    width: 0.5,
                  ),
                  color: const Color(0xFF101010),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getPlainTextHotkey(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xAAFFFFFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeHotkeyTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeHotkeyTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      richMessage:
          _hotkeyText == null
              ? TextSpan(
                text: widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              )
              : TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MouseRegion(
                          onEnter:
                              (event) =>
                                  _showHotkeyTooltip(context, event.position),
                          onExit: (_) => _removeHotkeyTooltip(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0x40FFFFFF),
                                width: 0.5,
                              ),
                              color: const Color(0xFF101010),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _hotkeyText!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xAAFFFFFF),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      preferBelow: true,
      waitDuration: widget.waitDuration,
      verticalOffset: widget.verticalOffset,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x40FFFFFF), width: 0.5),
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: widget.padding,
      child: widget.child,
    );
  }
}
