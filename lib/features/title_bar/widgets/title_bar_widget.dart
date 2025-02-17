import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TitleBarWidget extends ConsumerWidget {
  const TitleBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0x25FFFFFF))),
      ),
      child: MoveWindow(),
    );
  }
}
