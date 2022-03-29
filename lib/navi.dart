import 'package:flutter/material.dart';
import './views/home.dart';
import 'views/chart.dart';
import './views/config.dart';

// ホームクラス
class Navi extends StatefulWidget {
  // コンストラクタ
  const Navi({Key? key}): super(key: key);

  @override
  State<Navi> createState() => _NaviState();
}

// 状態管理クラス
class _NaviState extends State<Navi> with SingleTickerProviderStateMixin{
  late PageController _pageController; // ページ切り替え用コントローラーの定義
  int _screen = 0;  // ページインデックス保存用

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _screen); // コントローラの作成
  }

  @override
  void dispose() {
    _pageController.dispose();  // コントローラ破棄
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => {
          setState(() => _screen = index),  // ページインデックスを更新
        },
        // ページ下部のナビゲーションメニューに相当する各ページビュー
        children: const [
          HomeScreen(),
          GraphScreen(),
          ConfigScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        // 現在のページインデックス
        currentIndex: _screen,
        onTap: (index) {
          setState(() {
            _screen = index;
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: 'グラフ'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}