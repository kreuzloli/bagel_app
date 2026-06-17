import 'package:bagel_app/pages/home_page.dart';
import 'package:bagel_app/pages/message_page.dart';
import 'package:bagel_app/pages/mine_page.dart';
import 'package:bagel_app/pages/publish_page.dart';
import 'package:bagel_app/pages/search_page.dart';
import 'package:flutter/material.dart';

/// App 主框架
///
/// 这个组件负责：
///
/// - 显示顶部标题栏
/// - 显示底部导航栏
/// - 根据底部导航切换不同页面
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  /// 当前选中的底部导航索引
  int _currentIndex = 0;

  /// 每个底部导航对应的页面标题
  // final List<String> _titles = const <String>[
  //   'Home',
  //   'Search',
  //   'Publish',
  //   'Chat',
  //   'Mine',
  // ];

  /// 每个底部导航对应的页面内容
  final List<Widget> _pages = const <Widget>[
    HomePage(),
    SearchPage(),
    PublishPage(),
    MessagePage(),
    MinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(_titles[_currentIndex]),
      //   centerTitle: true,
      // ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFFF2442),
        unselectedItemColor: const Color(0xFF999999),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        /// fixed 表示 5 个按钮都显示文字。 如果不设置，超过 3 个 item 时，Flutter 默认会变成 shifting 样式。
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Publish',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mine',
          ),
        ],
      ),
    );
  }
}
