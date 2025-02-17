import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StatusBarWidget extends ConsumerWidget {
  const StatusBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: const Color(0x25FFFFFF))),
      ),
    );
  }
}
