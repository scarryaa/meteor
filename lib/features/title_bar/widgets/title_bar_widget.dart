import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/features/file_explorer/providers/file_explorer_manager.dart';
import 'package:path/path.dart';

class TitleBarWidget extends ConsumerWidget {
  const TitleBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDirectoryPath =
        ref.watch(fileExplorerManagerProvider).currentDirectoryPath;

    return Container(
      height: 30,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0x25FFFFFF))),
      ),
      child: MoveWindow(
        child: Row(
          children: [
            SizedBox(width: Platform.isMacOS ? 68 : 8),
            TextButton(
              onPressed: () {
                ref
                    .read(fileExplorerManagerProvider.notifier)
                    .selectDirectory();
              },
              child: Text(
                basename(currentDirectoryPath ?? 'Select a directory'),
                style: TextStyle(color: const Color(0xA0FFFFFF)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
