import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

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
      title: 'Kakebo',
      debugShowCheckedModeBanner: false,  // Debug の 表示を OFF
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
        ).copyWith(
          secondary: Colors.green,
        ),
      ),
      home: const MyHomePage(title: 'Kakebo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // コンストラクタ
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title; // タイトル

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '右下のボタンを押下するとincrease(+1)する:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: '+1',
        child: const Icon(Icons.add),
      ),
    );
  }
}
