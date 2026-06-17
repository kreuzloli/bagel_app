import 'package:bagel_app/shell/main_shell.dart';
import 'package:flutter/material.dart';

class BagelApp extends StatelessWidget {
  const BagelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bagel',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        /// 使用 Material 3 风格。
        useMaterial3: true,
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: const Color(0xFFE94B5F),
        // ),
        /// 主题种子色, Flutter 会根据这个颜色生成一套配色。
        colorSchemeSeed: const Color(0xFFFF7AA2),

        /// 页面默认背景色。
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      ),
      home: const MainShell(),
    );
  }
}
