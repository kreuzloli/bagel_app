import 'package:bagel_app/pages/login_page.dart';
import 'package:flutter/material.dart';

/// 我的页
class MinePage extends StatelessWidget {
  const MinePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(child: Text('我的页面', style: TextStyle(fontSize: 28))),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text('登录'),
        ),
      ],
    );
  }
}
