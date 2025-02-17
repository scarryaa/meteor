import 'package:flutter/material.dart';
import 'package:meteor/features/dialogs/unsaved_changes_dialog/models/dialog_button.type.dart';

class UnsavedChangesDialogWidget extends StatelessWidget {
  const UnsavedChangesDialogWidget({
    super.key,
    required this.fileName,
    required this.onSave,
    required this.onDiscard,
    required this.onCancel,
  });

  final String fileName;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: const Color(0xFF000000),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0x30FFFFFF)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unsaved Changes',
                style: TextStyle(
                  color: const Color(0xFFFCFCFC),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Do you want to save the changes made to "$fileName"?',
                style: TextStyle(color: const Color(0xE5FCFCFC), fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _DialogButton(
                    label: 'Cancel',
                    onPressed: onCancel,
                    type: DialogButtonType.secondary,
                  ),
                  const SizedBox(width: 8),
                  _DialogButton(
                    label: "Don't Save",
                    onPressed: onDiscard,
                    type: DialogButtonType.destructive,
                  ),
                  const SizedBox(width: 8),
                  _DialogButton(
                    label: 'Save',
                    onPressed: onSave,
                    type: DialogButtonType.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatefulWidget {
  const _DialogButton({
    required this.label,
    required this.onPressed,
    required this.type,
  });

  final String label;
  final VoidCallback onPressed;
  final DialogButtonType type;

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool isHovered = false;
  bool isPressed = false;

  Color get backgroundColor {
    switch (widget.type) {
      case DialogButtonType.primary:
        if (isPressed) return Colors.deepPurple[600]!;
        if (isHovered) return Colors.deepPurple[700]!;
        return Colors.deepPurple;

      case DialogButtonType.secondary:
        if (isPressed) return const Color(0x28FFFFFF);
        if (isHovered) return const Color(0x30FFFFFF);
        return Colors.transparent;

      case DialogButtonType.destructive:
        if (isPressed) return const Color(0x28FFFFFF);
        if (isHovered) return const Color(0x30FFFFFF);
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),
        onTap: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
            border:
                widget.type != DialogButtonType.primary
                    ? Border.all(color: const Color(0x40FFFFFF))
                    : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(color: const Color(0xFFFCFCFC), fontSize: 14),
          ),
        ),
      ),
    );
  }
}
