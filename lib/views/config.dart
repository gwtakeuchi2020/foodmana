import 'package:flutter/material.dart';

class ConfigScreen extends StatelessWidget{
  const ConfigScreen({Key? key}):super(key: key);

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink[200],
          title: const Text(
            'Config',
            style: TextStyle(fontSize: 16),
          ),
          automaticallyImplyLeading: false,
        ),
        body: const Center(child: Text('設定ページ'))
      );
  }
}