import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import './navi.dart';

void main() {
  // パスのハッシュを削除するために追加
  setUrlStrategy(PathUrlStrategy());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // コンストラクタ
  const MyApp({Key? key}) : super(key: key);

  // アプリケーションのルートウィジェット
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cakebo',
      debugShowCheckedModeBanner: false,  // Debug の 表示を OFF
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.purple,
        ).copyWith(
          secondary: Colors.purple,
        ),
      ),
      initialRoute: '/', // デフォルトのルーティング
      // ルーティングの一覧を設定
      routes: {
        '/': (context) => const Navi(),
      },
      // 多言語化
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
      ],
      //home: const MyHomePage(title: 'cakebo'),
    );
  }
}
