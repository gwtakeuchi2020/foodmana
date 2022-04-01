import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core/firebase_core.dart';
import './navi.dart';
import './auth.dart';

Future<void> main() async{
  // パスのハッシュを削除するために追加
  setUrlStrategy(PathUrlStrategy());
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBswQ5X2497-7k5lba8pAPyDooEgU74KN4",
      appId: "1:439358050548:web:b0d5ba1eb24cca5d358ea1",
      messagingSenderId: "439358050548",
      projectId: "foodmana-37c5e",
      authDomain: "foodmana-37c5e.firebaseapp.com",
      storageBucket: "foodmana-37c5e.appspot.com",
      measurementId: "G-KWJEXEYKFW"
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // コンストラクタ
  const MyApp({Key? key}) : super(key: key);

  // アプリケーションのルートウィジェット
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'foodmana',
      debugShowCheckedModeBanner: false,  // Debug の 表示を OFF
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.pink,
        ).copyWith(
          secondary: Colors.pink[200],
        ),
      ),
      initialRoute: '/', // デフォルトのルーティング
      // ルーティングの一覧を設定
      routes: {
        '/': (context) => const Auth(),
        '/navi': (context) => const Navi(),
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
