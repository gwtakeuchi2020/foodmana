import 'package:flutter/material.dart';
class AppBarWiget {
  // アプリケーションバー
  static AppBar appbar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: Colors.pink[200],
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/'), 
          icon: const Icon(Icons.logout),
          splashRadius: 2,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}