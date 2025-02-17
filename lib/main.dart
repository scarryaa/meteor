import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meteor/pages/main_page.dart';

void main() {
  runApp(ProviderScope(child: const MeteorApp()));

  doWhenWindowReady(() {
    const initialSize = Size(600, 450);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MeteorApp extends StatelessWidget {
  const MeteorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'meteor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        scrollbarTheme: ScrollbarThemeData(
          radius: Radius.zero,
          thumbColor: WidgetStatePropertyAll(const Color(0x50FFFFFF)),
          mainAxisMargin: 0,
          crossAxisMargin: 0,
          thickness: WidgetStatePropertyAll(12.0),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Material(type: MaterialType.transparency, child: const MainPage()),
    );
  }
}
