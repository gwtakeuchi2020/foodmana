import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Controller {
  // ナビゲーションガード(ログイン情報がないとき、ログイン画面へ遷移)
  static void navigationGuard(BuildContext context) {
    if(FirebaseAuth.instance.currentUser == null) Navigator.pushNamed(context, '/');
  } 
}